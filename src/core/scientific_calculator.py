# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Main window."""

from gi.repository import Pebbles

class ScientificCalculator():
    """The main window class."""

    def __init__(self):
        pass

    def evaluate(self, input:str, angle_mode:int=0) -> str:
        print("Evaluating...\n", input, "\n", "Angle Mode: ", angle_mode, "\n")
        return 'Got result'