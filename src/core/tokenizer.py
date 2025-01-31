# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>


import re

"""Tokenizer"""

class Tokenizer():
    """Tokenizer"""

    @staticmethod
    def _check_parenthesis(exp: str) -> bool:
        bracket_balance = 0
        for c in exp:
            if c == '(':
                bracket_balance += 1
            elif c == ')':
                bracket_balance -= 1

        return bracket_balance >= 0


    @staticmethod
    def _space_removal(original: str) -> str:
        i = 0
        j = 0
        result = ''
        l = len(original)
        while i < l:
            j = i + 1
            if original[i] == ' ':
                while original[j] == ' ':
                    j += 1

                result += ' '
                i = j
            else:
                result += original[i]
                i += 1

        return result


    @staticmethod
    def _is_number(exp: str) -> bool:
        return exp.endswith(tuple([str(i) for i in range(0, 10)] + ['.', 'x']))


    @staticmethod
    def _algebraic_variable_product_convert(exp: str) -> str:
        converted_exp = ''
        tokens = exp.replace('x', ' x ').split(' ')
        for i in range(1, len(tokens)):
            if tokens[i] == 'x' and Tokenizer._is_number(tokens[i - 1]) and tokens[i - 1] != "(":
                tokens[i] = '* x'

        converted_exp = Tokenizer._space_removal(' '.join(tokens))
        return converted_exp


    @staticmethod
    def _algebraic_parenthesis_product_convert(exp: str) -> str:
        tokens = exp.split(' ')
        for i in range(1, len(tokens)):
            if tokens[i] == ' ':
                if Tokenizer._is_number(tokens[i - 1]):
                    tokens[i] = '* ()'

            if tokens[i] == ' ':
                if Tokenizer._is_number(tokens[i + 1]) or tokens[i + 1] == '(':
                    tokens[i] = ') *'

        return Tokenizer._space_removal(' '.join(tokens))


    @staticmethod
    def _unary_minus_convert(exp: str):
        uniminus_converted = ''
        tokens = exp.split (' ')
        for i in range(len(tokens)):
            if tokens[i] == '-':
                if i == 0:
                    if i < len(tokens):
                        tokens [i] = '( 0 u'
                        tokens [i + 1] = tokens [i + 1] + " )"
                elif tokens [i - 1] == ')' or tokens [i - 1] == 'x' or Tokenizer._is_number (tokens [i - 1].strip()):
                    tokens [i] = '-'
                else:
                    if i < len(tokens):
                        tokens [i] = '( 0 u'
                        tokens [i + 1] = tokens [i + 1] + ' )'

        uniminus_converted = ' '.join(tokens)
        return uniminus_converted


    @staticmethod
    def _relative_percentage_convert(exp: str) -> str:
        while '%' in exp:
            exp_a = ''
            exp_b = ''
            tokens = exp.split(' ')
            percentage_index = -1
            for i in range(len(tokens) - 1, 0, -1):
                if tokens[i] == '%':
                    percentage_index = i
                    tokens[i] = '[%]'
                    break

            if Tokenizer._is_number(tokens[percentage_index - 1]):
                exp_b = tokens[percentage_index - 1]
                if percentage_index - 2 >= 0 and tokens[percentage_index - 2] in ['+', '-']:
                    if percentage_index - 3 >= 0:
                        if tokens[percentage_index - 3] == ')':
                            paren_balance = -1
                            paren_start_index = -1
                            for i in range(percentage_index - 4, -1, -1):
                                if tokens[i] == '(':
                                    paren_balance += 1
                                elif tokens[i] == ')':
                                    paren_balance -= 1

                                if paren_balance == 0:
                                    paren_start_index = i;
                                    break

                            if paren_start_index >= 0:
                                tokens_in_range = tokens[paren_start_index:percentage_index - 2]
                                exp_a += ' '.join(tokens_in_range[i])
                                exp_a = Tokenizer._space_removal(exp_a)
                                result = Tokenizer._space_removal(' '.join(tokens))
                                return result.replace('[%]', ' * ' + exp_a + ' / 100 ');
                        elif Tokenizer._is_number(tokens[percentage_index - 3]):
                            exp_a = tokens[percentage_index - 3]
                            result = ' '.join(tokens)
                            return result.replace('[%]', ' * ' + exp_a + ' / 100 ');
            elif tokens[percentage_index - 1] == ')':
                paren_balance_b = -1
                paren_start_index_b = -1
                for i in range(percentage_index - 2, -1, -1):
                    if tokens[i] == "(":
                        paren_balance_b += 1
                    elif tokens[i] == ")":
                        paren_balance_b -= 1

                    if paren_balance_b == 0:
                        paren_start_index_b = i
                        break

                if paren_start_index_b >= 0:
                    tokens_in_range = tokens[paren_start_index_b:percentage_index - 2]
                    exp_b += Tokenizer._space_removal(' '.join(tokens_in_range))
                if paren_start_index_b > 0 and tokens[paren_start_index_b - 1] in ['+', '-']:
                    if paren_start_index_b - 2 >= 0:
                        if tokens[paren_start_index_b - 2] == ")":
                            paren_balance = -1
                            paren_start_index = -1
                            for i in range(paren_start_index_b - 3, -1, -1):
                                if tokens[i] == "(":
                                    paren_balance += 1
                                elif tokens[i] == ")":
                                    paren_balance -= 1

                                if paren_balance == 0:
                                    paren_start_index = i
                                    break

                            if paren_start_index >= 0:
                                tokens_in_range = tokens[paren_start_index:paren_start_index_b - 1]
                                exp_a = Tokenizer._space_removal(' '.join(tokens_in_range))
                                result = ' '.join(tokens)
                                result = Tokenizer._space_removal(result)
                                return result.replace("[%]", " * " + exp_a + " / 100 ")
                        elif Tokenizer._is_number(tokens[paren_start_index_b - 2]):
                            exp_a = tokens[paren_start_index_b - 2]
                            result = ' '.join(tokens)
                            result = Tokenizer._space_removal(result)
                            return result.replace("[%]", " * " + exp_a + " / 100 ")

            result = ' '.join(tokens)
            result = Tokenizer._space_removal(result)
            return result.replace("[%]", " / 100 ")
        return exp


    @staticmethod
    def st_tokenize(input:str) -> list[str]:
        if Tokenizer._check_parenthesis(input):
            exp:str = input

            """
            Certain UTF-8 escape characters require a space
            after it to seperate it from the next character.
            This is only during testing. This is however not
            an issue when fetching input from the text entry
            in ScientificDisplay.
            """

            # Detect constants
            exp = exp.replace('π', ' ( 3.1415926535897932 ) ')
            exp = exp.replace('\xCF\x86', ' ( 1.618033989 ) ')
            exp = exp.replace('\xF0\x9D\x9B\xBE', ' ( 0.5772156649 ) ')
            exp = exp.replace('\xCE\xBB', ' ( 1.30357 ) ')
            exp = exp.replace('K', ' ( 2.685452001 ) ')
            exp = exp.replace('\xCE\xB1', ' ( 2.5029 ) ')
            exp = exp.replace('\xCE\xB4', ' ( 4.6692 ) ')
            exp = exp.replace('\xF0\x9D\x91\x83', ' ( 2.29558714939 ) ')
            exp = exp.replace('E', ' * 10 ^ ')
            exp = exp.replace('pi', ' ( 3.1415926535897932 ) ')

            exp = exp.lower()

            # Convert to lexemes
            exp = exp.replace('Gans', '#')
            exp = exp.replace('ans', '@')
            exp = exp.replace('isinh', ' [0] ')
            exp = exp.replace('icosh', ' [1] ')
            exp = exp.replace('itanh', ' [2] ')
            exp = exp.replace('isin', ' [3] ')
            exp = exp.replace('icos', ' [4] ')
            exp = exp.replace('itan', ' [5] ')
            exp = exp.replace('sinh', ' [6] ')
            exp = exp.replace('cosh', ' [7] ')
            exp = exp.replace('tanh', ' [8] ')
            exp = exp.replace('sin', ' [9] ')
            exp = exp.replace('cos', ' [10] ')
            exp = exp.replace('tan', ' [11] ')
            exp = exp.replace('log\xE2\x82\x81\xE2\x82\x80', ' 10 log ')
            exp = exp.replace('log', ' log ')
            exp = exp.replace('ln', ' e log ')
            exp = exp.replace('mod', ' m ')
            exp = exp.replace('p', ' p ')
            exp = exp.replace('P', ' p ')
            exp = exp.replace('C', ' b ')
            exp = exp.replace('c', ' b ')

            # Convert to symbolic terms and introduce additional spaces
            exp = exp.replace('e', ' ( 2.718281828 ) ')
            exp = exp.replace('i', ' j ')                   # Imaginary
            exp = exp.replace('j', ' j 1 ')
            exp = exp.replace('[0]', ' 0 r ')
            exp = exp.replace('[1]', ' 0 z ')
            exp = exp.replace('[2]', ' 0 k ')
            exp = exp.replace('[3]', ' 0 i ')
            exp = exp.replace('[4]', ' 0 o ')
            exp = exp.replace('[5]', ' 0 a ')
            exp = exp.replace('[6]', ' 0 h ')
            exp = exp.replace('[7]', ' 0 y ')
            exp = exp.replace('[8]', ' 0 e ')
            exp = exp.replace('[9]', ' 0 s ')
            exp = exp.replace('[10]', ' 0 c ')
            exp = exp.replace('[11]', ' 0 t ')
            exp = exp.replace('log', ' l ')
            exp = exp.replace('(', ' ( ')
            exp = exp.replace(')', ' ) ')
            exp = exp.replace('×', ' * ')
            exp = exp.replace('÷', ' / ')
            exp = exp.replace('%', ' % ')
            exp = exp.replace('+', ' + ')
            exp = exp.replace('-', ' - ')
            exp = exp.replace('−', ' - ')
            exp = exp.replace('*', ' * ')
            exp = exp.replace('/', ' / ')
            exp = exp.replace('^', ' ^ ')
            exp = exp.replace('sqrt', ' 2 q ')
            exp = exp.replace('√', ' q ')
            exp = exp.replace('sqr', ' ^ 2 ')
            exp = exp.replace('rt', ' q ')
            exp = exp.replace('!', ' ! 1 ')
            exp = exp.replace('∞', 'inf')

            exp = exp.strip ()
            exp = Tokenizer._space_removal (exp)

            # Intelligently convert expressions based on common rules
            exp = Tokenizer._algebraic_parenthesis_product_convert(exp)
            print(exp)
            exp = Tokenizer._relative_percentage_convert(exp)
            print(exp)
            exp = Tokenizer._unary_minus_convert(exp)
            print(exp)
            exp = Tokenizer._space_removal(exp.strip())

            return exp.split(' ')
        else:
            return []

