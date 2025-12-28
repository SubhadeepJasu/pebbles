# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Converter"""

import json
from gi.repository import Pebbles
from pebbles.core.utils import Utils

class Converter:
    """
    Unit Converter
    """

    def __init__(self, data:str):
        self.data_dict = json.loads(data)
        self.conversion_factors = self.data_dict['conversionFactors']

    def convert(self):
        """
        Convert from unit_1 to unit_2 according to conversion factor table
        """

        if self.data_dict['input'] == '':
            return '0'

        val = float(self.data_dict['input'])
        unit1 = self.data_dict['unit1']
        unit2 = self.data_dict['unit2']

        if self.conversion_factors[unit2] == 0:
            return "0"

        if self.data_dict['context'] != Pebbles.Context.CONV_TEMP:
            result = val * (self.conversion_factors[unit1] / self.conversion_factors[unit2])
        else: # Temperature
            result = self._convert_temp(unit1, unit2, val)

        return Utils.format_float(result)

    def _convert_temp(self, unit1, unit2, val):
        if unit2 == 0:
            if unit1 == 0:
                result = val
            elif unit1 == 1:
                result = self._c_2_f(val)
            else:
                result = self._c_2_k(val)
        elif unit2 == 1:
            if unit1 == 0:
                result = self._f_2_c(val)
            elif unit1 == 1:
                result = val
            else:
                result = self._f_2_k(val)
        else:
            if unit1 == 0:
                result = self._k_2_c(val)
            elif unit1 == 1:
                result = self._k_2_f(val)
            else:
                result = val
        return result


    # C/5 = F-32/9 ############################
    def _f_2_c(self, far):
        return (far - 32) * 5 / 9

    def _c_2_f(self, cel):
        return (cel * 9 / 5) + 32

    def _c_2_k(self, cel):
        return cel + 273.15

    def _k_2_c(self, k):
        return k - 273.15

    def _f_2_k(self, far):
        return (((far - 32) * 5 / 9)) + 273.15

    def _k_2_f(self, k):
        return (k - 273.15) * 9/5 + 32
