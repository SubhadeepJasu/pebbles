# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Calculus Calculator"""

import json
from gi.repository import Pebbles
from pebbles.core.scientific_calculator import ScientificCalculator
from pebbles.core.tokenizer import Tokenizer
from pebbles.core.memory import ContextualMemory
from pebbles.core.utils import Utils


class CalculusCalculator:
    """The calculus calculator for calculating calculus. Hail Newton."""

    MODE = Pebbles.Context.CALCULUS

    def __init__(self, data: str, memory: ContextualMemory):
        self.input_dict = json.loads(data)
        self.memory = memory
        self.angle_mode = self.input_dict['angleMode']
        self.integral_mode = self.input_dict['integralMode']
        self.scientific_calculator = ScientificCalculator(
            data,
            self.memory,
            Tokenizer.SCIENTIFIC_TOKEN_MAP,
            override_context=Pebbles.Context.CALCULUS
        )


    def evaluate(self) -> str:
        """
        Find integral or derivative of the given expression at given limits.
        """
        try:
            answer = self.process()
            formatted_answer = ScientificCalculator.format(answer)

            input_expr = self.input_dict['input'].lower()
            if 'sans' in input_expr:
                input_expr = input_expr.replace('sans', self._get_last_answer(global_scope=True))
            elif 'ans' in input_expr:
                input_expr = input_expr.replace('ans', self._get_last_answer())


            self.memory.push_history(
                CalculusCalculator.MODE,
                input_expr,
                str(answer),
                {'metadata_1': self.angle_mode,
                 'metadata_2': 1 if self.integral_mode else 0,
                 'metadata_3': str(self.input_dict['limitA']),
                 'metadata_4': str(self.input_dict['limitB']) if self.integral_mode else ''
                }
            )
            result_json = json.dumps({'mode': self.MODE, 'result': formatted_answer})
            return result_json, answer
        except (ZeroDivisionError, ArithmeticError, TypeError, IndexError) as e:
            print("Error: ", e)
            return json.dumps({'mode': self.MODE, 'result': 'E'}), None


    def process(self) -> complex | float:
        """
        Process the data to find out a result.
        Uses Simpson's 3/8 Method for integration.
        Uses 5 point stencil for derivation.
        """

        if self.integral_mode:
            # Simpson's Rule
            n = self.input_dict['integralAccuracy'] * 2
            a = self.input_dict['limitA']
            h = (self.input_dict['limitB'] - a) / n

            result = 0
            for i in range(n + 1):
                x = a + i * h
                self.scientific_calculator.set_substitute_value('X', x, zero_limit=True)
                fx = self.scientific_calculator.process()

                if i in (0, n):
                    coeff = 1
                elif i % 2 == 0:
                    coeff = 2
                else:
                    coeff = 4

                result += coeff * fx

            result = (h / 3) * result
        else:
            # Five point stencil
            h = 10 ** (0 - self.input_dict['derivativeAccuracy'])
            x0 = self.input_dict['limitA']
            self.scientific_calculator.set_substitute_value('X', x0 + 2*h, zero_limit=True)
            f_plus2h = self.scientific_calculator.process()

            self.scientific_calculator.set_substitute_value('X', x0 + h, zero_limit=True)
            f_plus1h = self.scientific_calculator.process()

            self.scientific_calculator.set_substitute_value('X', x0 - h, zero_limit=True)
            f_minus1h = self.scientific_calculator.process()

            self.scientific_calculator.set_substitute_value('X', x0 - 2*h, zero_limit=True)
            f_minus2h = self.scientific_calculator.process()

            result = (0 - f_plus2h + 8*f_plus1h - 8*f_minus1h + f_minus2h) / (12 * h)

        return result


    def _get_last_answer (self, global_scope=False):
        context = Pebbles.Context.GLOBAL if global_scope else CalculusCalculator.MODE
        last_ans, _, _, _, _, _ = self.memory.get_last_result(context)
        last_ans = ScientificCalculator.parse(last_ans)
        return Utils.format_float(last_ans) if last_ans is not None else '0'
