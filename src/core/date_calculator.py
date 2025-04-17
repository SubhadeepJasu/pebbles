
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Date Calculator"""

from datetime import datetime
from dateutil.relativedelta import relativedelta
from gi.repository import GLib

class DateCalculator:
    """
    Date calculator.
    """

    def evaluate_difference(self, from_date:GLib.DateTime, to_date:GLib.DateTime):
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


    def add_to_date(self,
                    start:GLib.DateTime,
                    days_to_add:int,
                    months_to_add:int,
                    years_to_add:int
    ):
        """
        Add certain days, months and year to a given date to get a new date.
        """

        _start_date = datetime.fromtimestamp(start.to_unix()).replace(
            hour=0, minute=0, second=0, microsecond=0
        ).date()

        new_date = _start_date + relativedelta(
            days=days_to_add,
            months=months_to_add,
            years=years_to_add
        )
        return GLib.Date.new_dmy(new_date.day, new_date.month, new_date.year)


    def subtract_from_date(self,
                           start:GLib.DateTime,
                           days_to_add:int,
                           months_to_add:int,
                           years_to_add:int
    ):
        """
        Subtract certain days, months and year from a given date to get a new date.
        """

        _start_date = datetime.fromtimestamp(start.to_unix()).replace(
            hour=0, minute=0, second=0, microsecond=0
        ).date()

        new_date = _start_date - relativedelta(
            days=days_to_add,
            months=months_to_add,
            years=years_to_add
        )
        return GLib.Date.new_dmy(new_date.day, new_date.month, new_date.year)
