
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Converter"""

from datetime import datetime
from gi.repository import GLib

class DateCalculator:
    """
    Date calculator.
    """

    def evaluate_difference (self, from_date:GLib.DateTime, to_date:GLib.DateTime):
        """
        Find the difference between  two given dates in days
        """

        _from_date = datetime.fromtimestamp(from_date.to_unix()).replace(
            hour=0, minute=0, second=0, microsecond=0
        ).date()
        _to_date = datetime.fromtimestamp(to_date.to_unix()).replace(
            hour=0, minute=0, second=0, microsecond=0
        ).date()

        return str((_to_date - _from_date).days)
