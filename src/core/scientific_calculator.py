# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Scientific Calculator"""

from gi.repository import Pebbles
from pebbles.core.tokenizer import Tokenizer
import json
import math
import cmath
import sys

class ScientificCalculator():
    """The scientific calculator."""

    MODE = 'scientific'
    GRAD_VAL = math.pi / 200
    DEG_VAL = math.pi / 180
    INV_GRAD_VAL = 200 / math.pi
    INV_DEG_VAL = 180 / math.pi


    def __init__(self, data: str, float_accuracy: int=2, tokenize: bool=True, zero_limit: bool=False):
        self.input_dict = json.loads(data)
        self.float_accuracy = float_accuracy
        self.angle_mode = self.input_dict['angleMode']
        if tokenize:
            self.tokens = Tokenizer.st_tokenize(self.input_dict['input'])
        self.zero_limit = zero_limit


    def evaluate(self) -> str:
        try:
            answer = self.process()
            if type(answer) == complex:
                if answer.real == 0 and answer.imag == 0:
                    return json.dumps({'mode': self.MODE, 'result': '0'}), 0
                if answer.imag < 0:
                    return json.dumps({'mode': self.MODE, 'result': f'{self._format_float(answer.real)} - {self._format_float(-answer.imag)}j'}), answer
                return json.dumps({'mode': self.MODE, 'result': f'{self._format_float(answer.real)} + {self._format_float(answer.imag)}j'}), answer
            elif type(answer) == float:
                return json.dumps({'mode': self.MODE, 'result': f'{self._format_float(answer)}'}), answer
            else:
                return json.dumps({'mode': self.MODE, 'result': 'E'}), None
        except Exception as e:
            return json.dumps({'mode': self.MODE, 'result': 'E'}), None


    def _format_float(self, x: float) -> str:
        format_string = f"{{:.{self.float_accuracy}f}}"
        rounded_value = format_string.format(x)

        # Remove trailing zeros and the decimal point if not needed
        return rounded_value.rstrip('0').rstrip('.') if '.' in rounded_value else rounded_value


    def process(self) -> complex | float:
        operand_stack = []
        def operand_pop():
            try:
                return operand_stack.pop()
            except:
                return 0

        operator_stack = []
        for token in self.tokens:
             # Current tokens is a number, push it to number stack
            if (not self._is_operator(token)) and token not in ['(', ')']:
                operand_stack.append(float(token))

            # If tokens is an opening brace, push it to 'ops'
            elif token == '(':
                operator_stack.append(token)

            # If tokens is a closing brace, solve it till the previous '(' is encountered
            elif token == ')':
                while operator_stack[-1] != '(':
                    b = operand_pop()
                    a = operand_pop()
                    op = operator_stack.pop()
                    print(a, b, op)
                    temp = self._apply_op(op, a, b)
                    print("res ", temp)
                    operand_stack.append(temp)

                operator_stack.pop()

            # If token is an operator
            elif self._is_operator(token):
                while (not self._is_r_l_associative(token)) and len(operator_stack) > 0 and self._has_precedence_pemdas(token, operator_stack[-1]):
                    b = operand_pop()
                    a = operand_pop()
                    op = operator_stack.pop()
                    print(a, b, op)
                    tmp = self._apply_op(op, a, b)
                    print("res ", tmp)
                    operand_stack.append(tmp)

                operator_stack.append(token)

        # print(operator_stack)
        while len(operator_stack) > 0:
            b = operand_pop()
            a = operand_pop()

            print("hi")
            op = operator_stack.pop()
            print(a, b, op)
            tmp = self._apply_op(op, a, b)
            print("res ", tmp)
            operand_stack.append(tmp)

        # print(operand_stack)
        return operand_pop()


    def _apply_op(self, op:chr, a:complex | float, b:complex | float):
        match op:
            case 'j':
                if type(a) == complex:
                    return a

                return complex(0, a)
            case '+':
                if type(a) == float and type(b) == complex:
                    return complex(a, 0) + b
                elif type(a) == complex and type(b) == float:
                    return a + complex(b, 0)
                return a + b
            case '-':
                if type(a) == float and type(b) == complex:
                    return complex(a - b.real, -b.imag)
                elif type(a) == complex and type(b) == float:
                    return a - complex(b, 0)
                return a - b
            case 'u':
                    return b * -1
            case '*':
                return a * b
            case '/':
                return a / b

            case 'q':
                return b ** (1 / a)
            case '^':
                return a ** b
            case 'm':
                return a % b
            case 'l':
                _x = a
                _y = b
                if type(_x) == complex:
                    _X = cmath.log(_x)
                else:
                    _x = math.log(_x)

                if type(_y) == complex:
                    _y = cmath.log(_y)
                else:
                    _y = math.log(_y)

                return _x / _y
            case '!':
                return float(math.factorial(int(a)))
            case 'p':
                return float(math.perm(int(a), int(b)))
            case 'b':
                return float(math.comb(int(a), int(b)))
            case 's':
                if type(b) == complex:
                    if self.angle_mode == 0:
                        return cmath.sin(b * self.DEG_VAL)
                    elif self.angle_mode == 1:
                        return cmath.sin(b)
                    else:
                        return cmath.sin(b * self.GRAD_VAL)
                else:
                    if self.angle_mode == 0:
                        return math.sin(b * self.DEG_VAL)
                    elif self.angle_mode == 1:
                        return math.sin(b)
                    else:
                        return math.sin(b * self.GRAD_VAL)
            case 'c':
                if type(b) == complex:
                    if self.angle_mode == 0:
                        return cmath.cos(b * self.DEG_VAL)
                    elif self.angle_mode == 1:
                        return cmath.cos(b)
                    else:
                        return cmath.cos(b * self.GRAD_VAL)
                else:
                    if self.angle_mode == 0:
                        return math.cos(b * self.DEG_VAL)
                    elif self.angle_mode == 1:
                        return math.cos(b)
                    else:
                        return math.cos(b * self.GRAD_VAL)
            case 't':
                if type(b) == complex:
                    if self.angle_mode == 0:
                        return cmath.tan(b * self.DEG_VAL)
                    elif self.angle_mode == 1:
                        return cmath.tan(b)
                    else:
                        return cmath.tan(b * self.GRAD_VAL)
                else:
                    if self.angle_mode == 0:
                        return math.tan(b * self.DEG_VAL)
                    elif self.angle_mode == 1:
                        return math.tan(b)
                    else:
                        return math.tan(b * self.GRAD_VAL)
            case 'i':
                if b < -1 or b > 1:
                    raise ArithmeticError

                if type(b) == complex:
                    if self.angle_mode == 0:
                        return cmath.asin(b * self.INV_DEG_VAL)
                    elif self.angle_mode == 1:
                        return cmath.asin(b)
                    else:
                        return cmath.asin(b * self.INV_GRAD_VAL)
                else:
                    if self.angle_mode == 0:
                        return math.asin(b * self.INV_DEG_VAL)
                    elif self.angle_mode == 1:
                        return math.asin(b)
                    else:
                        return math.asin(b * self.INV_GRAD_VAL)
            case 'o':
                if b < -1 or b > 1:
                    raise ArithmeticError

                if type(b) == complex:
                    if self.angle_mode == 0:
                        return cmath.acos(b * self.INV_DEG_VAL)
                    elif self.angle_mode == 1:
                        return cmath.acos(b)
                    else:
                        return cmath.acos(b * self.INV_GRAD_VAL)
                else:
                    if self.angle_mode == 0:
                        return math.acos(b * self.INV_DEG_VAL)
                    elif self.angle_mode == 1:
                        return math.acos(b)
                    else:
                        return math.acos(b * self.INV_GRAD_VAL)
            case 'a':
                if type(b) == complex:
                    if self.angle_mode == 0:
                        return cmath.atan(b * self.INV_DEG_VAL)
                    elif self.angle_mode == 1:
                        return cmath.atan(b)
                    else:
                        return cmath.atan(b * self.INV_GRAD_VAL)
                else:
                    if self.angle_mode == 0:
                        return math.atan(b * self.INV_DEG_VAL)
                    elif self.angle_mode == 1:
                        return math.atan(b)
                    else:
                        return math.atan(b * self.INV_GRAD_VAL)
            case 'h':
                if type(b) == complex:
                    if self.angle_mode == 0:
                        return cmath.sinh(b * self.DEG_VAL)
                    elif self.angle_mode == 1:
                        return cmath.sinh(b)
                    else:
                        return cmath.sinh(b * self.GRAD_VAL)
                else:
                    if self.angle_mode == 0:
                        return math.sinh(b * self.DEG_VAL)
                    elif self.angle_mode == 1:
                        return math.sinh(b)
                    else:
                        return math.sinh(b * self.GRAD_VAL)
            case 'y':
                if type(b) == complex:
                    if self.angle_mode == 0:
                        return cmath.cosh(b * self.DEG_VAL)
                    elif self.angle_mode == 1:
                        return cmath.cosh(b)
                    else:
                        return cmath.cosh(b * self.GRAD_VAL)
                else:
                    if self.angle_mode == 0:
                        return math.cosh(b * self.DEG_VAL)
                    elif self.angle_mode == 1:
                        return math.cosh(b)
                    else:
                        return math.cosh(b * self.GRAD_VAL)
            case 'e':
                if type(b) == complex:
                    if self.angle_mode == 0:
                        return cmath.tanh(b * self.DEG_VAL)
                    elif self.angle_mode == 1:
                        return cmath.tanh(b)
                    else:
                        return cmath.tanh(b * self.GRAD_VAL)
                else:
                    if self.angle_mode == 0:
                        return math.tanh(b * self.DEG_VAL)
                    elif self.angle_mode == 1:
                        return math.tanh(b)
                    else:
                        return math.tanh(b * self.GRAD_VAL)
            case 'r':
                if type(b) == complex:
                    if self.angle_mode == 0:
                        return cmath.asinh(b * self.INV_DEG_VAL)
                    elif self.angle_mode == 1:
                        return cmath.asinh(b)
                    else:
                        return cmath.asinh(b * self.INV_GRAD_VAL)
                else:
                    if self.angle_mode == 0:
                        return math.asinh(b * self.INV_DEG_VAL)
                    elif self.angle_mode == 1:
                        return math.asinh(b)
                    else:
                        return math.asinh(b * self.INV_GRAD_VAL)
            case 'z':
                if type(b) == complex:
                    if self.angle_mode == 0:
                        return cmath.acosh(b * self.INV_DEG_VAL)
                    elif self.angle_mode == 1:
                        return cmath.acosh(b)
                    else:
                        return cmath.acosh(b * self.INV_GRAD_VAL)
                else:
                    if self.angle_mode == 0:
                        return math.acosh(b * self.INV_DEG_VAL)
                    elif self.angle_mode == 1:
                        return math.acosh(b)
                    else:
                        return math.acosh(b * self.INV_GRAD_VAL)
            case 'k':
                if type(b) == complex:
                    if self.angle_mode == 0:
                        return cmath.atanh(b * self.INV_DEG_VAL)
                    elif self.angle_mode == 1:
                        return cmath.atanh(b)
                    else:
                        return cmath.atanh(b * self.INV_GRAD_VAL)
                else:
                    if self.angle_mode == 0:
                        return math.atanh(b * self.INV_DEG_VAL)
                    elif self.angle_mode == 1:
                        return math.atanh(b)
                    else:
                        return math.atanh(b * self.INV_GRAD_VAL)

        raise ArithmeticError


    def _is_r_l_associative(self, op:str) -> bool:
        return op in ['u', '^']


    def _is_operator(self, ch:chr) -> bool:
        return (ch in [
            '+', '-', '/', '*', '^',
            'm', 'l', '!', 'p', 'b',
            'z', 'k', 'q', 'u', 'j'
            ]) or self._is_angle_op(ch)


    def _is_angle_op(self, op:chr):
        return op in ['s', 'c', 't', 'i', 'o',
            'a', 'h', 'y', 'e', 'r']


    def _has_precedence_pemdas(self, op1: chr, op2: chr) -> bool:
        if op2 in ['(', ')']:
            return False

        print("Comparing " + op1 + " and " + op2)
        # Following the PEMDAS rule: <http://mathworld.wolfram.com/PEMDAS.html>
        PRECENDANCE = [
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

        # Find the precedence index of each operator
        op1_index = next((i for i, ops in enumerate(PRECENDANCE) if op1 in ops), float('inf'))
        op2_index = next((i for i, ops in enumerate(PRECENDANCE) if op2 in ops), float('inf'))

        return op1_index > op2_index
