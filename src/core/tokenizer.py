# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Tokenizer"""

class Tokenizer():
    """Tokenizer used to convert input expression into meaningful tokens."""

    # All string replacements in the order in which they should be handled
    SCIENTIFIC_CONSTANTS = [
        ('π', ' ( 3.1415926535897932 ) '),
        ('\xCF\x86', ' ( 1.618033989 ) '),
        ('\xF0\x9D\x9B\xBE', ' ( 0.5772156649 ) '),
        ('\xCE\xBB', ' ( 1.30357 ) '),
        ('K', ' ( 2.685452001 ) '),
        ('\xCE\xB1', ' ( 2.5029 ) '),
        ('\xCE\xB4', ' ( 4.6692 ) '),
        ('\xF0\x9D\x91\x83', ' ( 2.29558714939 ) '),
        ('E', ' * 10 ^ '),
        ('pi', ' ( 3.1415926535897932 ) '),
    ]

    LEXICAL_REPLACEMENTS = [
        ('gans', '#'),
        ('ans', '@'),
        ('isinh', ' [0] '),
        ('icosh', ' [1] '),
        ('itanh', ' [2] '),
        ('isin', ' [3] '),
        ('icos', ' [4] '),
        ('itan', ' [5] '),
        ('sinh', ' [6] '),
        ('cosh', ' [7] '),
        ('tanh', ' [8] '),
        ('sin', ' [9] '),
        ('cos', ' [10] '),
        ('tan', ' [11] '),
        ('log\xE2\x82\x81\xE2\x82\x80', ' 10 log '),
        ('log', ' log '),
        ('ln', ' e log '),
        ('mod', ' m '),
        ('p', ' p '),
        ('P', ' p '),
        ('C', ' b '),
        ('c', ' b '),

        # Convert to symbolic terms and introduce additional spaces
        ('e', ' ( 2.718281828 ) '),
        ('i', ' j '),                   # Imaginary
        ('j', ' j 1 '),
        ('[0]', ' 0 r '),
        ('[1]', ' 0 z '),
        ('[2]', ' 0 k '),
        ('[3]', ' 0 i '),
        ('[4]', ' 0 o '),
        ('[5]', ' 0 a '),
        ('[6]', ' 0 h '),
        ('[7]', ' 0 y '),
        ('[8]', ' 0 e '),
        ('[9]', ' 0 s '),
        ('[10]', ' 0 c '),
        ('[11]', ' 0 t '),
        ('log', ' l '),
        ('(', ' ( '),
        (')', ' ) '),
        ('×', ' * '),
        ('÷', ' / '),
        ('%', ' % '),
        ('+', ' + '),
        ('-', ' - '),
        ('−', ' - '),
        ('*', ' * '),
        ('/', ' / '),
        ('^', ' ^ '),
        ('sqrt', ' 2 q '),
        ('√', ' q '),
        ('sqr', ' ^ 2 '),
        ('rt', ' q '),
        ('!', ' ! 1 '),
        ('∞', 'inf')
    ]

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
        n = len(tokens)
        for i in range(n):
            if tokens[i] == '-':
                if i == 0:
                    if i < n:
                        tokens [i] = '( 0 u'
                        tokens [i + 1] = tokens [i + 1] + " )"
                elif tokens [i - 1] == ')' or tokens [i - 1] == 'x' or \
                    Tokenizer._is_number (tokens [i - 1].strip()):
                    tokens [i] = '-'
                else:
                    if i < n:
                        tokens [i] = '( 0 u'
                        tokens [i + 1] = tokens [i + 1] + ' )'

        uniminus_converted = ' '.join(tokens)
        return uniminus_converted

    # pylint: disable=fixme,too-many-branches,too-many-statements,too-many-nested-blocks
    # TODO: Simplify this
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
                                    paren_start_index = i
                                    break

                            if paren_start_index >= 0:
                                tokens_in_range = tokens[paren_start_index:percentage_index - 2]
                                exp_a += ' '.join(tokens_in_range[i])
                                exp_a = Tokenizer._space_removal(exp_a)
                                result = Tokenizer._space_removal(' '.join(tokens))
                                return result.replace('[%]', ' * ' + exp_a + ' / 100 ')
                        elif Tokenizer._is_number(tokens[percentage_index - 3]):
                            exp_a = tokens[percentage_index - 3]
                            result = ' '.join(tokens)
                            return result.replace('[%]', ' * ' + exp_a + ' / 100 ')
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
    # pylint: enable=fixme,too-many-branches,too-many-statements,too-many-nested-blocks

    @staticmethod
    def st_tokenize(input_exp:str) -> list[str]:
        """
        Tokenize the given string into a format that the scientific calculator can understand.
        """
        if Tokenizer._check_parenthesis(input_exp):
            exp:str = input_exp
            # Certain UTF-8 escape characters require a space
            # after it to seperate it from the next character.
            # This is only during testing. This is however not
            # an issue when fetching input from the text entry
            # in ScientificDisplay.

            # Scientific Constants
            for c in Tokenizer.SCIENTIFIC_CONSTANTS:
                exp = exp.replace(c[0], c[1])

            exp = exp.lower()
            # Convert to lexemes
            for l in Tokenizer.LEXICAL_REPLACEMENTS:
                exp = exp.replace(l[0], l[1])

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
        return []
