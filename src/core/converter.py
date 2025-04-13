
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Converter"""

from pebbles.core.utils import Utils

class Converter:
    """
    Unit Converter
    """

    def __init__(self, conversion_factors:list[float]):
        self.conversion_factors = conversion_factors

    def convert(self, input_str:str, unit_1:int, unit_2:int):
        """
        Convert from unit_1 to unit_2 according to conversion factor table
        """
        input_value = float(input_str)
        result = input_value * (self.conversion_factors[unit_2] / self.conversion_factors[unit_1])
        return Utils.format_float(result)
