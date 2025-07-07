# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Programmers Calculator"""

import json
from gi.repository import Pebbles
from pebbles.core.tokenizer import Tokenizer
from pebbles.core.memory import ContextualMemory
from pebbles.core.utils import Utils

# pylint: disable=too-many-public-methods, too-many-branches

class ProgrammersCalculator():
    """The programmers calculator."""

    MODE = Pebbles.Context.PROGRAMMER

    HEXADECIMAL_DIGITS = [ 'a', 'b', 'c', 'd', 'e', 'f' ]

    TOKEN_TYPE_OPERATOR = 0
    TOKEN_TYPE_OPERAND = 1
    TOKEN_TYPE_PARENTHESIS = 2

    # Ordered and grouped according to the PEMDAS rule: <http://mathworld.wolfram.com/PEMDAS.html>
    OPERATORS = [
        ['u'],
        ['!', 'm'],
        ['/', '*'],
        ['+', '-'],
        ['<', '>'],
        ['&', '_'],
        ['x', 'p', 'n', '|']
    ]

    def __init__(self, memory: ContextualMemory):
        self.memory = memory
        self.stored_tokens: list[_ProgToken] = [
            _ProgToken("0", ProgrammersCalculator.TOKEN_TYPE_OPERAND, Pebbles.NumberSystem.DECIMAL)
        ]


    def get_last_token(self):
        return self.stored_tokens[-1]


    def get_token_array(self):
        return self.stored_tokens


    def set_last_token(self, arr:list[bool], wrd_length:Pebbles.GlobalWordLength, number_system:Pebbles.NumberSystem):
        if self.stored_tokens[-1].token_type != ProgrammersCalculator.TOKEN_TYPE_OPERAND:
            self.stored_tokens.append(_ProgToken(
                self.bool_array_to_string (arr, wrd_length, number_system),
                ProgrammersCalculator.TOKEN_TYPE_OPERAND,
                number_system
            ))
        else:
            self.stored_tokens[-1].token = self.bool_array_to_string (arr, wrd_length, number_system)

        token_list = [token.token for token in self.stored_tokens]
        expression = " ".join(token_list)
        return Utils.get_natural_expression(expression)


    def populate_token_array(self, exp: str, number_system:Pebbles.NumberSystem):
        _stored_tokens = Tokenizer.get_token_array (exp, number_system)
        self.stored_tokens = [_ProgToken(x['token'], x['type'], x['numberSystem']) for x in _stored_tokens]


    def set_number_system(self,
                          exp:str,
                          number_system:Pebbles.NumberSystem,
                          wrd_length=Pebbles.GlobalWordLength.BYT,
                          force_decimal=False
                         ) -> str:
        token_structure = Tokenizer.get_token_array(exp, number_system)

        if self._compare_token_set(token_structure, self.stored_tokens):
            for i in range(len(token_structure)):
                if token_structure[i].type == ProgrammersCalculator.TOKEN_TYPE_OPERAND:
                    if token_structure[i].number_system != self.stored_tokens[i].number_system:
                        self.stored_tokens[i].token = self.convert_number_system(
                            self.stored_tokens[i].token,
                            self.stored_tokens[i].number_system,
                            Pebbles.NumberSystem.DECIMAL \
                                if force_decimal \
                                else token_structure[i].number_system,
                            wrd_length
                        )

        token_list = []
        for token in self.stored_tokens:
            token.token = Utils.remove_leading_zeroes(token.token)
            token_list.append(token.token)

        return Utils.get_natural_expression(" ".join(token_list))


    def _compare_token_set(self, a: list, b: list) -> bool:
        if len(a) != len(b):
            return False
        for i in range(len(a)):
            if a[i].token != b[i].token:
                return False
        return True


    def convert_number_system(self,
                           exp: str,
                           number_system_a: Pebbles.NumberSystem,
                           number_system_b: Pebbles.NumberSystem,
                           wrd_length = Pebbles.GlobalWordLength.WRD,
                           format_binary = False
                          ) -> str:
        """
        Convert a string value from one number system to another.
        """
        converted = exp

        if number_system_a == Pebbles.NumberSystem.DECIMAL:
            if number_system_b == Pebbles.NumberSystem.BINARY:
                converted = self.convert_decimal_to_binary(exp, wrd_length, format_binary)
            elif number_system_b == Pebbles.NumberSystem.HEXADECIMAL:
                converted = self.convert_decimal_to_hexadecimal(exp)
            elif number_system_b == Pebbles.NumberSystem.OCTAL:
                converted = self.convert_decimal_to_octal(exp, wrd_length)

        elif number_system_a == Pebbles.NumberSystem.BINARY:
            if number_system_b == Pebbles.NumberSystem.DECIMAL:
                converted = self.convert_binary_to_decimal(exp, wrd_length)
            elif number_system_b == Pebbles.NumberSystem.HEXADECIMAL:
                converted = self.convert_binary_to_hexadecimal(exp, wrd_length)
            elif number_system_b == Pebbles.NumberSystem.OCTAL:
                converted = self.convert_binary_to_octal(exp, wrd_length)
            elif format_binary:
                converted = self.represent_binary_by_word_length(exp, wrd_length, True)

        elif number_system_a == Pebbles.NumberSystem.HEXADECIMAL:
            if number_system_b == Pebbles.NumberSystem.DECIMAL:
                converted = self.convert_hexadecimal_to_decimal(exp, wrd_length)
            elif number_system_b == Pebbles.NumberSystem.BINARY:
                converted = self.convert_hexadecimal_to_binary(exp, wrd_length, format_binary)
            elif number_system_b == Pebbles.NumberSystem.OCTAL:
                converted = self.convert_hexadecimal_to_octal(exp, wrd_length)

        elif number_system_a == Pebbles.NumberSystem.OCTAL:
            if number_system_b == Pebbles.NumberSystem.DECIMAL:
                converted = self.convert_octal_to_decimal(exp, wrd_length)
            elif number_system_b == Pebbles.NumberSystem.BINARY:
                converted = self.convert_octal_to_binary(exp, wrd_length, format_binary)
            elif number_system_b == Pebbles.NumberSystem.HEXADECIMAL:
                converted = self.convert_octal_to_hexadecimal(exp, wrd_length)

        return converted




    @staticmethod
    def convert_signed_binary_to_decimal(binary: str) -> int:
        """
        Convert signed binary string to int.
        """

        dec = 0
        length = len(binary)
        for i in range(length - 1, 0, -1):
            if binary[i] == '1':
                dec += 1 << ((length - 1) - i)
        if binary[0] == '1':
            dec -= 1 << (length - 1)
        return dec


    def represent_binary_by_word_length (self,
                                         binary_value:str,
                                         wrd_length=Pebbles.GlobalWordLength.BYT,
                                         format_output=False
                                        ):
        """
        Represent a binary buffer as a string of zeroes and ones as per word length.
        """

        new_binary = ""
        required_bit_length = 8
        match wrd_length:
            case Pebbles.GlobalWordLength.WRD:
                required_bit_length = 16
            case Pebbles.GlobalWordLength.DWD:
                required_bit_length = 32
            case Pebbles.GlobalWordLength.QWD:
                required_bit_length = 64

        if len(binary_value) > required_bit_length:
            new_binary = binary_value[- (required_bit_length + 1) : -1]
        else:
            pre_zeros = "0" * (required_bit_length - len(binary_value))
            new_binary = pre_zeros + binary_value

        if format_output:
            formatted_binary = ""
            for i in range(len(new_binary)):
                formatted_binary += new_binary[i]
                if (i + 1) % 8 == 0:
                    formatted_binary += " "
            return formatted_binary
        return new_binary

    def convert_binary_to_decimal(self, number:str, wrd_length=Pebbles.GlobalWordLength.WRD):
        """
        Convert binary string to decimal string.
        """

        formatted_binary = self.represent_binary_by_word_length(number, wrd_length)
        decimal = ProgrammersCalculator.convert_signed_binary_to_decimal(formatted_binary)
        return str(decimal)


    def convert_binary_to_octal(self, bin_value:str, wrd_length=Pebbles.GlobalWordLength.BYT):
        """
        Convert binary string to octal string.
        """

        binary_string = self.represent_binary_by_word_length(bin_value, wrd_length)
        octal_num = 0
        decimal_num = 0
        count = 1
        converted_binary = binary_string
        negative = binary_string[0] == '1'

        if negative:
            # Flip bits for two's complement handling
            converted_binary = ''.join('0' if bit == '1' else '1' for bit in binary_string)

        try:
            decimal_num = int(converted_binary, 2)
        except ValueError:
            decimal_num = ProgrammersCalculator.convert_signed_binary_to_decimal(binary_string)

        if negative:
            decimal_num += 1  # Final step of two's complement conversion

        # Convert to octal manually (in base 10 format, not "0o" prefixed)
        while decimal_num != 0:
            octal_num += abs(decimal_num % 8) * count
            decimal_num //= 8
            count *= 10

        return f"-{octal_num}" if negative else str(octal_num)


    def convert_binary_to_hexadecimal(self, bin_value, wrd_length=Pebbles.GlobalWordLength.BYT):
        """
        Convert binary string to hexadecimal string.
        """

        bin_str = self.represent_binary_by_word_length(bin_value, wrd_length, False)
        converted_binary = bin_str
        negative = (len(bin_str) > 0 and bin_str[0] == '1')

        if negative:
            converted_binary = ''.join('0' if b == '1' else '1' for b in bin_str)

        hex_map = {
            '0000': '0', '0001': '1', '0010': '2', '0011': '3',
            '0100': '4', '0101': '5', '0110': '6', '0111': '7',
            '1000': '8', '1001': '9', '1010': 'A', '1011': 'B',
            '1100': 'C', '1101': 'D', '1110': 'E', '1111': 'F'
        }

        hex_value = ""
        i = 0
        n = len(converted_binary)
        while i < n:
            if converted_binary[i] == '.':
                hex_value += '.'
                i += 1
                continue

            chunk = converted_binary[i:i+4]
            if len(chunk) < 4:
                chunk = chunk.ljust(4, '0')
            hex_value += hex_map.get(chunk, '')
            i += 4

        hex_value = hex_value.lstrip('0')

        if negative and hex_value:
            num = int(hex_value, 16) + 1
            hex_value = format(num, 'X')
            hex_value = '-' + hex_value

        return hex_value or '0'


    def _decimal_to_binary_int_unsigned(self, k: int) -> str:
        bin_str = ""
        n = k
        while n > 0:
            bin_str = str(n % 2) + bin_str
            n = n // 2
        return bin_str or "0"

    def convert_decimal_to_binary(self,
                                  number: str,
                                  wrd_length=Pebbles.GlobalWordLength.WRD,
                                  format_output=False
                                 ) -> str:
        is_negative = number.startswith('-')
        decimal = int(number)

        if is_negative:
            if wrd_length == Pebbles.GlobalWordLength.BYT:
                decimal += 128
            elif wrd_length == Pebbles.GlobalWordLength.WRD:
                decimal += 32768
            elif wrd_length == Pebbles.GlobalWordLength.DWD:
                decimal += 2147483648
            elif wrd_length == Pebbles.GlobalWordLength.QWD:
                decimal += 9223372036854775808

        binary = self._decimal_to_binary_int_unsigned(decimal)
        binary = self.represent_binary_by_word_length(binary, wrd_length, format_output)

        if is_negative:
            binary = binary[1:]  # remove MSB
            binary = "1" + binary  # reattach sign

        return binary


    def convert_decimal_to_hexadecimal(self, number: str) -> str:
        n = int(number)
        hexa = ""

        while n != 0:
            temp = n % 16
            if temp < 10:
                hexa += str(temp)
            else:
                hexa += ProgrammersCalculator.HEXADECIMAL_DIGITS[temp - 10]
            n //= 16

        hex_value = hexa[::-1]  # reverse the string

        if hex_value.strip() == "":
            return "0"

        return hex_value


    def convert_hexadecimal_to_binary(self,
                                      hex_value: str,
                                      wrd_length=Pebbles.GlobalWordLength.WRD,
                                      format_output=False
                                     ) -> str:
        hex_to_bin_map = {
            '0': "0000", '1': "0001", '2': "0010", '3': "0011",
            '4': "0100", '5': "0101", '6': "0110", '7': "0111",
            '8': "1000", '9': "1001", 'A': "1010", 'a': "1010",
            'B': "1011", 'b': "1011", 'C': "1100", 'c': "1100",
            'D': "1101", 'd': "1101", 'E': "1110", 'e': "1110",
            'F': "1111", 'f': "1111"
        }
        binary_value = ""
        for char in hex_value:
            binary_value += hex_to_bin_map.get(char, "")

        formatted_binary = self.represent_binary_by_word_length(
            binary_value,
            wrd_length,
            format_output
        )
        return formatted_binary


    @staticmethod
    def map_bin_to_hex(bin_str: str) -> str:
        bin_to_hex_map = {
            "0000": "0", "0001": "1", "0010": "2", "0011": "3",
            "0100": "4", "0101": "5", "0110": "6", "0111": "7",
            "1000": "8", "1001": "9", "1010": "a", "1011": "b",
            "1100": "c", "1101": "d", "1110": "e", "1111": "f"
        }
        return bin_to_hex_map.get(bin_str, "")


    def convert_decimal_to_octal(self, dec_value:str, wrd_length=Pebbles.GlobalWordLength.BYT):
        bin_value = self.convert_decimal_to_binary (dec_value, wrd_length)
        return self.convert_binary_to_octal (bin_value, wrd_length)


    def convert_hexadecimal_to_octal(self, hex_value:str, wrd_length=Pebbles.GlobalWordLength.BYT):
        bin_value = self.convert_hexadecimal_to_binary (hex_value, wrd_length)
        return self.convert_binary_to_octal (bin_value, wrd_length)


    def convert_octal_to_binary(self,
                                oct_value: str,
                                wrd_length=Pebbles.GlobalWordLength.BYT,
                                format_output=False
                               ):
        octal_num = int(oct_value)
        decimal_num = 0
        count = 0

        while octal_num != 0:
            decimal_num += (octal_num % 10) * (8 ** count)
            count += 1
            octal_num //= 10

        bin_value = self.convert_decimal_to_binary(str(decimal_num), wrd_length)
        bin_value = self.represent_binary_by_word_length(bin_value, wrd_length, format_output)
        return bin_value


    def convert_octal_to_decimal(self, oct_value:str, wrd_length=Pebbles.GlobalWordLength.BYT):
        bin_value = self.convert_octal_to_binary (oct_value, wrd_length)
        return self.convert_binary_to_decimal (bin_value, wrd_length)


    def convert_octal_to_hexadecimal(self, oct_value:str, wrd_length=Pebbles.GlobalWordLength.BYT):
        bin_value = self.convert_octal_to_binary(oct_value, wrd_length)
        return self.convert_binary_to_hexadecimal(bin_value, wrd_length)


    def convert_hexadecimal_to_decimal(self, number: str, wrd_length=Pebbles.GlobalWordLength.WRD):
        binary_value = self.convert_hexadecimal_to_binary(number, wrd_length)
        decimal = self.convert_binary_to_decimal(binary_value, wrd_length)
        return str(decimal)


    def bool_array_to_string(self,
                             arr:list[bool],
                             wrd_length:Pebbles.GlobalWordLength,
                             number_system:Pebbles.NumberSystem
                            ):
        """
        Convert a bool array to string of zeroes and ones or one of the other number systems.
        """
        final_form = ''

        for b in arr:
            final_form += "1" if b else "0"


        match number_system:
            case Pebbles.NumberSystem.OCTAL:
                final_form = self.convert_binary_to_octal (final_form, wrd_length)
            case Pebbles.NumberSystem.DECIMAL:
                final_form = self.convert_binary_to_decimal (final_form, wrd_length)
            case Pebbles.NumberSystem.HEXADECIMAL:
                final_form = self.convert_binary_to_hexadecimal (final_form, wrd_length)
            case _:
                final_form = self.represent_binary_by_word_length (final_form, wrd_length)
        return final_form


    def string_to_bool_array(self, string_val: str, number_system: Pebbles.NumberSystem, wrd_length) -> list[bool]:
        bool_array = [False] * 64

        if number_system == Pebbles.NumberSystem.OCTAL:
            converted_str = self.convert_octal_to_binary(string_val, wrd_length, format_output=True).replace(" ", "")
        elif number_system == Pebbles.NumberSystem.DECIMAL:
            converted_str = self.convert_decimal_to_binary(string_val, wrd_length, format_output=True).replace(" ", "")
        elif number_system == Pebbles.NumberSystem.HEXADECIMAL:
            converted_str = self.convert_hexadecimal_to_binary(string_val, wrd_length, format_output=True).replace(" ", "")
        else:
            converted_str = self.represent_binary_by_word_length(string_val, wrd_length, format_output=True).replace(" ", "")

        # Fill bool_array from the right
        start_index = 64 - len(converted_str)
        for i, ch in enumerate(converted_str):
            bool_array[start_index + i] = ch == '1'

        return bool_array

    # Evaluation ####################

    def _has_precedence_pemdas(self, op1: chr, op2: chr) -> bool:
        if op2 in ['(', ')']:
            return False

        # print("Comparing " + op1 + " and " + op2)

        # Find the precedence index of each operator
        op1_index = next((i for i, ops in enumerate(self.OPERATORS) if op1 in ops), float('inf'))
        op2_index = next((i for i, ops in enumerate(self.OPERATORS) if op2 in ops), float('inf'))

        return op1_index >= op2_index


    def _enforce_unsigned_bit_width(self, number: int, bit_width: int) -> str:
        bin_str = format(number, 'b')
        bin_str = bin_str.zfill(bit_width)
        return bin_str[-bit_width:]


    def _enforce_signed_bit_width(self, number: int, bit_width: int) -> str:
        if number >= 0:
            bin_str = format(number, 'b')
        else:
            bin_str = format((1 << bit_width) + number, 'b')

        bin_str = bin_str.zfill(bit_width)
        return bin_str[-bit_width:]


    def _apply_op(self,
                  op:chr,
                  a_input:list[bool],
                  b_input:list[bool],
                  wrd_size:Pebbles.GlobalWordLength
                 ):
        bits = 8
        if wrd_size == Pebbles.GlobalWordLength.WRD:
            bits = 16
        elif wrd_size == Pebbles.GlobalWordLength.DWD:
            bits = 32
        elif wrd_size == Pebbles.GlobalWordLength.QWD:
            bits = 64
        str_a = ''.join(['1' if a_input[i] else '0' for i in range(64 - bits, 64)])
        str_b = ''.join(['1' if b_input[i] else '0' for i in range(64 - bits, 64)])

        a = self.convert_signed_binary_to_decimal(str_a)
        if a < 0:
            a = self._enforce_signed_bit_width(a, bits)
        else:
            a = self._enforce_unsigned_bit_width(a, bits)

        b = self.convert_signed_binary_to_decimal(str_b)
        if b < 0:
            b = self._enforce_signed_bit_width(b, bits)
        else:
            b = self._enforce_unsigned_bit_width(b, bits)


        result = self._apply_op_bit_wise(op, a, b)
        return self.string_to_bool_array(str(result), Pebbles.NumberSystem.DECIMAL, wrd_size)



    def _apply_op_bit_wise(self, op:chr, a, b):
        result = 0

        match op:
            case '+':
                result = a + b
            case '-':
                result = b - a
            case '*':
                result = a * b
            case '/':
                result = b / a
            case '&':
                result = a & b
            case '|':
                result = a | b
            case '!':
                result = ~a
            case '_':
                result = ~(a & b)
            case 'o':
                result = ~(a | b)
            case 'x':
                result = (a | b) & (~a | ~b)
            case 'n':
                result = (a & b) | (~a & ~b)
            case 'm':
                result = b % a

        return result


    def evaluate(self, number_system: Pebbles.NumberSystem, wrd_length: Pebbles.GlobalWordLength, gen_hist: bool):
        """
        Evaluate a programming mode expression.
        """
        try:
            answer = self.process(number_system, wrd_length)
            formatted_answer = self.bool_array_to_string(answer, wrd_length, number_system)

            if gen_hist:
                self.memory.push_history(
                    self.MODE,
                    self.input_dict['input'],
                    str(answer.token),
                    {'metadata_1': number_system,
                     'metadata_2': wrd_length
                    }
                )
            result_json = json.dumps({'mode': self.MODE, 'result': formatted_answer})
            return result_json, answer
        except (ZeroDivisionError, ArithmeticError, TypeError, IndexError) as e:
            print("Error: ", e)
            return json.dumps({'mode': self.MODE, 'result': 'E'}), None


    def process(self, number_system: Pebbles.NumberSystem, wrd_length: Pebbles.GlobalWordLength):
        """
        Process the data to find out a result.
        """
        operand_stack = []
        def operand_pop():
            try:
                return operand_stack.pop()
            except IndexError:
                return [False] * 64

        operator_stack = []
        for token in self.stored_tokens:
            if token.token_type == ProgrammersCalculator.TOKEN_TYPE_OPERAND:
                operand_stack.append(self.string_to_bool_array(token.token, token.number_system, wrd_length))
            elif token.token_type == ProgrammersCalculator.TOKEN_TYPE_PARENTHESIS:
                if token.token == '(':
                    operator_stack.append('(')
                else:
                    while operator_stack[-1] != '(':
                        b = operand_pop()
                        a = operand_pop()
                        tmp = self._apply_op(
                            operator_stack.pop(),
                            a,
                            b,
                            wrd_length
                        )
                        operand_stack.append(tmp)

                    operator_stack.pop()
            elif token.token_type == ProgrammersCalculator.TOKEN_TYPE_OPERATOR:
                while len(operator_stack) > 0 and \
                    self._has_precedence_pemdas(token.token, operator_stack[-1]):
                    b = operand_pop()
                    a = operand_pop()
                    tmp = self._apply_op(
                        operator_stack.pop(),
                        a,
                        b,
                        wrd_length
                    )
                    operand_stack.append(tmp)

                operator_stack.append(token.token)

        while len(operator_stack) > 0:
            b = operand_pop()
            a = operand_pop()
            tmp = self._apply_op(operator_stack.pop(), a, b, wrd_length)
            operand_stack.append(tmp)

        return operand_pop()



class _ProgToken:
    def __init__(self, token:str, token_type:int, number_system:Pebbles.NumberSystem):
        self.token = token
        self.token_type = token_type
        self.number_system = number_system

    def to_string (self):
        """
        Get string representation
        """

        obj = {
            'token': self.token,
            'tokenType': self.token_type,
            'numberSystem': self.number_system,
            'tokenTypeS': 'operand',
            'numberSystemS': 'decimal',
        }

        if self.token_type == ProgrammersCalculator.TOKEN_TYPE_OPERATOR:
            obj['tokenTypeS'] = 'operator'
        elif self.token_type == ProgrammersCalculator.TOKEN_TYPE_PARENTHESIS:
            obj['tokenTypeS'] = 'parenthesis'

        if self.number_system == Pebbles.NumberSystem.BINARY:
            obj['numberSystemS'] = 'binary'
        elif self.number_system == Pebbles.NumberSystem.HEXADECIMAL:
            obj['numberSystemS'] = 'hexadecimal'
        elif self.number_system == Pebbles.NumberSystem.OCTAL:
            obj['numberSystemS'] = 'octal'

        return json.dumps(obj)


class _BoolArrayStack:
    def __init__(self):
        self.stack = []
        self.tp = -1  # top pointer

    def push(self, elem):
        if self.tp < len(self.stack) - 1:
            self.tp += 1
            # Ensure elem is exactly 64 bits
            elem = elem[:64] + [False] * (64 - len(elem))  # pad or truncate
            self.stack.append(elem)
            return True
        return False

    def pop(self):
        if self.tp >= 0:
            temp = self.stack.pop()
            self.tp -= 1
            return temp

        return [False] * 64  # return default blank 64-bit array
