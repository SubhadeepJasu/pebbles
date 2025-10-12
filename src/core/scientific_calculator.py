# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Scientific Calculator"""

import json
import math
import cmath
from gi.repository import Pebbles
from pebbles.core.tokenizer import Tokenizer
from pebbles.core.memory import ContextualMemory
from pebbles.core.utils import Utils

class ScientificCalculator():
    """The scientific calculator."""

    MODE = Pebbles.Context.SCIENTIFIC
    GRAD_VAL = math.pi / 200
    DEG_VAL = math.pi / 180
    INV_GRAD_VAL = 200 / math.pi
    INV_DEG_VAL = 180 / math.pi

    # Ordered and grouped according to the PEMDAS rule: <http://mathworld.wolfram.com/PEMDAS.html>
    OPERATORS = [
        ['j'],
        ['s', 'c', 't', 'i', 'o', 'a', 'h', 'y', 'e', 'r'],
        ['!'],
        ['p', 'b'],
        ['l'],
        ['u'],
        ['^', 'q'],
        ['m'],
        ['/', '*'],
        ['+', '-']
    ]


    def __init__(self, data: str, memory: ContextualMemory,
                 token_map:list, override_context=Pebbles.Context.SCIENTIFIC):
        self.input_dict = json.loads(data)
        self.memory = memory
        self.override_context = override_context
        self.input_dict['input'] = self.input_dict['input'].lower()
        if 'sans' in self.input_dict['input']:
            self.input_dict['input'] = self.input_dict['input'].replace('sans',
                                              self._get_last_answer())
        elif 'ans' in self.input_dict['input']:
            self.input_dict['input'] = self.input_dict['input'].replace('ans',
                                                        self._get_last_answer(override_context))

        if token_map is not None:
            self.tokens = Tokenizer.st_tokenize(self.input_dict['input'], token_map)
            # print ('Tokens: ', self.tokens)

        self.substitutions = {
            'X': 0,
            'A': 0,
            'B': 0,
            'C': 0,
            'M': 0
        }
        self.zero_limit = False


    def set_substitute_value(self, variable, value, zero_limit=False):
        """
        Set Calculus substitute value for "x" and if zero is actually "tends to zero".
        """
        self.substitutions[variable] = value
        self.zero_limit = zero_limit


    def evaluate(self) -> str:
        """
        Evaluate given scientific expression.
        """
        try:
            answer = self.process()
            formatted_answer = ScientificCalculator.format(answer)

            if self.override_context == Pebbles.Context.SCIENTIFIC:
                self.memory.push_history(
                    ScientificCalculator.MODE,
                    self.input_dict['input'],
                    str(answer),
                    {'metadata_1': self.input_dict['angleMode']}
                )
            result_json = json.dumps({'mode': self.MODE, 'result': formatted_answer})
            return result_json, answer
        except (ZeroDivisionError, ArithmeticError, TypeError, IndexError) as e:
            print("Error: ", e)
            return json.dumps({'mode': self.MODE, 'result': 'E'}), None


    def process(self) -> complex | float:
        """
        Process the data to find out a result.
        """
        operand_stack = []
        def operand_pop():
            try:
                return operand_stack.pop()
            except IndexError:
                return 0

        operator_stack = []
        for token in self.tokens:
             # Current tokens is a number, push it to number stack
            if (not self._is_operator(token)) and token not in ['(', ')']:
                self._handle_special_variables(token, operand_stack)

            # If tokens is an opening brace, push it to 'ops'
            elif token == '(':
                operator_stack.append(token)

            # If tokens is a closing brace, solve it till the previous '(' is encountered
            elif token == ')':
                while operator_stack[-1] != '(':
                    b = operand_pop()
                    a = operand_pop()
                    op = operator_stack.pop()
                    # print(a, b, op)
                    temp = self._apply_op(op, a, b)
                    # print("res ", temp)
                    operand_stack.append(temp)

                operator_stack.pop()

            # If token is an operator
            elif self._is_operator(token):
                while (len(operator_stack) > 0 and
                    not self._is_r_l_associative(token) and
                    self._has_precedence_pemdas(token, operator_stack[-1])):
                    b = operand_pop()
                    a = operand_pop()
                    op = operator_stack.pop()
                    # print(a, b, op)
                    tmp = self._apply_op(op, a, b)
                    # print("res ", tmp)
                    operand_stack.append(tmp)

                operator_stack.append(token)

        # print(operator_stack)
        while len(operator_stack) > 0:
            op = operator_stack.pop()
            b = operand_pop()
            a = operand_pop()
            # print(a, b, op)
            tmp = self._apply_op(op, a, b)
            # print("res ", tmp)
            operand_stack.append(tmp)

        # print(operand_stack)
        return operand_pop()


    def _handle_special_variables (self, token, operand_stack):
        if token == 'x':
            operand_stack.append(self.substitutions['X'])
        elif token == '\x11':
            operand_stack.append(self.substitutions['A'])
        elif token == '\x12':
            operand_stack.append(self.substitutions['B'])
        elif token == '\x13':
            operand_stack.append(self.substitutions['C'])
        elif token == '\x14':
            operand_stack.append(self.substitutions['M'])
        else:
            operand_stack.append(float(token))


    def _get_last_answer (self, context=Pebbles.Context.GLOBAL):
        last_ans = ScientificCalculator.parse(self.memory.get_last_result(context))
        return last_ans if last_ans is not None else 0


    @staticmethod
    def format(result: any) -> str:
        """
        Format scientific result.
        """
        val: any
        if isinstance(result, str):
            val = ScientificCalculator.parse(result)
        else:
            val = result

        if isinstance(val, complex):
            if val.real == 0 and val.imag == 0:
                return "0"

            if val.imag < 0:
                return f'{Utils.format_float(val.real)} - \
                    {Utils.format_float(0 - val.imag)}j'

            return f'{Utils.format_float(val.real)} + \
                {Utils.format_float(val.imag)}j'

        if isinstance(val, float):
            return Utils.format_float(val)

        return "E"


    @staticmethod
    def parse(result: str):
        try:
            return float(result)
        except ValueError:
            return complex(result)


    def _apply_op(self, op:chr, a:complex | float, b:complex | float):
        """
        Apply an operation "op" on two operands "a" and "b" and return the result.
        """
        match op:
            case 'j':
                result = self._op_imaginary(a)
            case '+':
                result = self._op_add(a, b)
            case '-':
                result = self._op_subtract(a, b)
            case 'u':
                result = b * -1
            case '*':
                result = a * b
            case '/':
                try:
                    result = a / b
                except ZeroDivisionError as ex:
                    if self.zero_limit:
                        result = math.inf
                    else:
                        raise ex
            case 'q':
                result = self._op_inv_power(a, b)
            case '^':
                result = a ** b
            case 'm':
                result = a % b
            case 'l':
                result = self._op_log(a, b)
            case '!':
                result = float(math.factorial(int(a)))
            case 'p':
                result = float(math.perm(int(a), int(b)))
            case 'b':
                result = float(math.comb(int(a), int(b)))
            case 's':
                result = self._op_sin(b)
            case 'c':
                result = self._op_cos(b)
            case 't':
                result = self._op_tan(b)
            case 'i':
                result = self._op_sin(b, inv=True)
            case 'o':
                result = self._op_cos(b, inv=True)
            case 'a':
                result = self._op_tan(b, inv=True)
            case 'h':
                result = self._op_sin(b, hyper=True)
            case 'y':
                result = self._op_cos(b, hyper=True)
            case 'e':
                result = self._op_tan(b, hyper=True)
            case 'r':
                result = self._op_sin(b, hyper=True, inv=True)
            case 'z':
                result = self._op_cos(b, hyper=True, inv=True)
            case 'k':
                result = self._op_tan(b, hyper=True, inv=True)

        return result


    def _is_r_l_associative(self, op:str) -> bool:
        return op in ['u', '^']


    def _is_operator(self, ch:chr) -> bool:
        exists = False
        for group in ScientificCalculator.OPERATORS:
            if ch in group:
                exists = True
                break
        return exists


    def _is_angle_op(self, op:chr):
        return op in ScientificCalculator.OPERATORS[1]


    def _has_precedence_pemdas(self, op1: chr, op2: chr) -> bool:
        if op2 in ['(', ')']:
            return False

        # print("Comparing " + op1 + " and " + op2)

        # Find the precedence index of each operator
        op1_index = next((i for i, ops in enumerate(self.OPERATORS) if op1 in ops), float('inf'))
        op2_index = next((i for i, ops in enumerate(self.OPERATORS) if op2 in ops), float('inf'))

        return op1_index >= op2_index

    #region Operations
    def _op_imaginary(self, a: float|complex):
        if isinstance(a, complex):
            return a

        return complex(0, a)


    def _op_add(self, a: float|complex, b: float|complex):
        if isinstance(a, float) and isinstance(b, complex):
            return complex(a, 0) + b

        if isinstance(a, complex) and isinstance(b, float):
            return a + complex(b, 0)

        return a + b

    def _op_inv_power(self, a, b):
        try:
            if a == 0:
                result = 0
                if self.zero_limit:
                    if b > 1:
                        result = math.inf
                    elif 0 < b < 1:
                        result = 0.0
                    elif b == 1:
                        result = 1.0
                    elif b < 0:
                        result = cmath.exp(cmath.log(b) / 1e-12)
                    else:
                        return float('nan')
                else:
                    raise ZeroDivisionError("Division by zero in 1/a")

                return result

            return b ** (1 / a)

        except ValueError:
            try:
                # Fallback to complex if all else fail
                return cmath.exp(cmath.log(b) / a)
            except ZeroDivisionError:
                return cmath.inf


    def _op_subtract(self, a: float|complex, b: float|complex):
        if isinstance(a, float) and isinstance(b, complex):
            return complex(a - b.real, -b.imag)

        if isinstance(a, complex) and isinstance(b, float):
            return a - complex(b, 0)

        return a - b


    def _op_log(self, a: float|complex, b: float|complex):
        _x = b
        _y = a
        if isinstance(_x,complex):
            _x = cmath.log(_x)
        else:
            _x = math.log(_x)

        if isinstance(_y,complex):
            _y = cmath.log(_y)
        else:
            _y = math.log(_y)

        return _x / _y


    # region Trignometric
    def _get_angle_factor(self, inv=False):
        angle_factor = 1
        if inv:
            if self.input_dict['angleMode'] == 0:
                angle_factor = self.INV_DEG_VAL
            elif self.input_dict['angleMode'] == 2:
                angle_factor = self.INV_GRAD_VAL
        else:
            if self.input_dict['angleMode'] == 0:
                angle_factor = self.DEG_VAL
            elif self.input_dict['angleMode'] == 2:
                angle_factor = self.GRAD_VAL

        return angle_factor


    def _op_sin(self, b: float|complex, hyper=False, inv=False):
        if inv and (b < -1 or b > 1) and not hyper:
            raise ArithmeticError

        angle_factor = self._get_angle_factor(inv)

        if hyper:
            if isinstance(b, complex):
                return (cmath.asinh(b) * angle_factor) if inv else cmath.sinh(b * angle_factor)

            return (math.asinh(b) * angle_factor) if inv else math.sinh(b * angle_factor)

        if isinstance(b, complex):
            return (cmath.asin(b) * angle_factor) if inv else cmath.sin(b * angle_factor)

        return (math.asin(b) * angle_factor) if inv else math.sin(b * angle_factor)


    def _op_cos(self, b: float|complex, hyper=False, inv=False):
        if inv and (b < -1 or b > 1) and not hyper:
            raise ArithmeticError

        angle_factor = self._get_angle_factor(inv)

        if hyper:
            if isinstance(b, complex):
                return (cmath.acosh(b) * angle_factor) if inv else cmath.cosh(b * angle_factor)

            return (math.acosh(b) * angle_factor) if inv else math.cosh(b * angle_factor)

        if isinstance(b, complex):
            return (cmath.acos(b) * angle_factor) if inv else cmath.cos(b * angle_factor)

        return (math.acos(b) * angle_factor) if inv else math.cos(b * angle_factor)


    def _op_tan(self, b: float|complex, hyper=False, inv=False):
        angle_factor = self._get_angle_factor(inv)

        if hyper:
            if isinstance(b, complex):
                return (cmath.atanh(b) * angle_factor) if inv else cmath.tanh(b * angle_factor)

            return (math.atanh(b) * angle_factor) if inv else math.tanh(b * angle_factor)

        if isinstance(b, complex):
            return (cmath.atan(b) * angle_factor) if inv else cmath.tan(b * angle_factor)

        return (math.atan(b) * angle_factor) if inv else math.tan(b * angle_factor)
    #endregion Trignometric

    #endregion
