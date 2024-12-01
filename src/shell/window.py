# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Main window."""

from gi.repository import Pebbles

class PythonWindow(Pebbles.Window):
    """The main window class."""

    def __init__(self, application: Pebbles.Application):
        super().__init__(application=application)
