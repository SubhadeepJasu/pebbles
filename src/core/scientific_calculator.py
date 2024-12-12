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
            print("Tokens: ")
            print(self.tokens)
            print("\n")
            answer = self.process()
            print("Answer: ")
            print(answer)
            print("\n")
            if type(answer) == complex:
                return json.dumps({'mode': self.MODE, 'result': f'{answer.real:.{self.float_accuracy}f} + {answer.imag:.{self.float_accuracy}f}j'})
            elif type(answer) == float:
                return json.dumps({'mode': self.MODE, 'result': f'{answer:.{self.float_accuracy}f}'})
            else:
                return json.dumps({'mode': self.MODE, 'result': 'E'})
        except Exception as e:
            print(e)
            print("\n")
            return json.dumps({'mode': self.MODE, 'result': 'E'})

    
    def process(self) -> complex | float:
        is_complex = 'j' in self.tokens

        operand_stack = []
        operator_stack = []
        for token in self.tokens:
             # Current tokens is a number, push it to number stack
            if (not self._is_operator(token)) and token not in ['(', ')']:
                operand_stack.append(complex(float(token), 0) if is_complex else float(token))
            
            # If tokens is an opening brace, push it to 'ops'
            elif token == '(':
                operator_stack.append(token)

            # If tokens is a closing brace, solve it till the previous '(' is encountered
            elif token == ')':
                while operator_stack[-1] != '(':
                    temp = self._apply_op(operator_stack.pop(), operand_stack.pop(), operand_stack.pop())
                    operand_stack.append(complex(temp) if is_complex else float(temp))
                
                operator_stack.pop()

            # If token is an operator
            elif self._is_operator(token):
                while (not self._is_r_l_associative(token)) and len(operator_stack) > 0 and self._has_precedence_pemdas(token, operator_stack[-1]):
                    tmp = self._apply_op(operator_stack.pop(), operand_stack.pop(), operand_stack.pop())
                    operand_stack.append(complex(tmp) if is_complex else float(tmp))
                
                operator_stack.append(token)

        print(operator_stack)
        while len(operator_stack) > 0:
            tmp = self._apply_op(operator_stack.pop(), operand_stack.pop(), operand_stack.pop())
            operand_stack.append(complex(tmp) if is_complex else float(tmp))
            
        print(operand_stack)
        return operand_stack.pop()      


    def _apply_op(self, op:chr, a:complex | float, b:complex | float):
        is_complex = type(a) == complex or type(b) == complex
        match op:
            case 'j':
                return complex(0, b)
            case '+':
                return a + b
            case '-':
                return a - b
            case 'u':
                if is_complex:
                    return b * complex(-1, 0)
                else:
                    return b * -1
            case '*':
                return a * b
            case '/':
                if self.zero_limit:
                    if b == 0:
                        b = complex(sys.float_info.min, 0) if is_complex else sys.float_info.min
                        if a == 0:
                            a = complex(sys.float_info.min, 0) if is_complex else sys.float_info.min
                
                if b == 0:
                    raise ArithmeticError()
                
                return a / b
            case 'q':
                return b ** (1 / a)
            case '^':
                return a ** b
            case 'm':
                return a % b
            case 'l':
                if is_complex:
                    return cmath.log(b) / cmath.log(a)
                
                return math.log(b) / math.log(a)
            case '!':
                return math.factorial(int(b))
            case 'p':
                return math.perm(int(a), int(b))
            case 'b':
                return math.comb(int(a), int(b))
            case 's':
                if is_complex:
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
                if is_complex:
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
                if is_complex:
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
                
                if is_complex:
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
                
                if is_complex:
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
                if is_complex:
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
                if is_complex:
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
                if is_complex:
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
                if is_complex:
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
                if is_complex:
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
                if is_complex:
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
                if is_complex:
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
        return op in ['u', '^', '']


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

        n = len(PRECENDANCE)

        m1 = n
        for i in range(n):
            if m1 == n and op1 in PRECENDANCE[i]:
                m1 = i

            if m1 != n and op2 in PRECENDANCE[i]:
                m2 = i
                break
        
        return m1 < m2
            
            

