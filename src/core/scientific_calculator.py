# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Scientific Calculator"""

from gi.repository import Pebbles
from pebbles.core.tokenizer import Tokenizer
import json
import math

class ScientificCalculator():
    """The scientific calculator."""

    GRAD_VAL = math.pi / 200
    DEG_VAL = math.pi / 180
    INV_GRAD_VAL = 200 / math.pi
    INV_DEG_VAL = 180 / math.pi


    def __init__(self, data: str, float_accuracy: int=-1, tokenize: bool=True, zero_limit: bool=False):
        self.input_dict = json.loads(data)
        self.float_accuracy = float_accuracy
        self.tokenize = tokenize
        self.zero_limit = zero_limit


    def evaluate(self) -> str:
        print("Evaluating...\n", self.input_dict['input'], "\n", "Angle Mode: ", self.input_dict['angleMode'], "\n")
        if self.tokenize:
            result = Tokenizer.st_tokenize(self.input_dict['input'])
            print (result)
        return json.dumps({'mode': 'scientific', 'result': 'Result'})