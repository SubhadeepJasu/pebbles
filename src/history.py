# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>

"""
Contextual Memory Store
"""

from gi.repository import Pebbles

class HistoryViewModel(Pebbles.HistoryViewModel):
    """
    History View Model
    """

    def __init__(self, item_id: int, context:str, input_exp:str, output:str):
        super().__init__(id=item_id, context=context, input=input_exp, output=output)
