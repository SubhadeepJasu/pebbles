# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Utilities"""

class Utils():
    """Utilities"""


    decimal_point_char: chr = '.'
    float_accuracy: int = 2

    @staticmethod
    def format_float(x: float) -> str:
        """Format a given floating point number into a string given that float_accuracy and decimal_point_char was set."""

        format_string = f"{{:.{Utils.float_accuracy}f}}"
        rounded_value = format_string.format(x)

        # Remove trailing zeros and the decimal point if not needed
        return rounded_value.rstrip('0').rstrip(Utils.decimal_point_char) if Utils.decimal_point_char in rounded_value else rounded_value
