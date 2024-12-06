# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Main window."""

from gi.repository import Pebbles
from pebbles.core.scientific_calculator import ScientificCalculator
import json
import threading

class PythonWindow(Pebbles.Window):
    """The main window class."""

    _sci_result: str

    def __init__(self, application: Pebbles.Application):
        super().__init__(application=application)

        self.connect("on_evaluate", PythonWindow._evaluate)


    @staticmethod
    def _evaluate(self, data:str):
        _th = threading.Thread(target=self._evaluation_thread, args=(data,))
        _th.start()
    
    
    def _evaluation_thread(self, data: str):
        data_dict = json.loads(data)
        if data_dict['mode'] == 'scientific':
            sci_calc = ScientificCalculator()
            self._sci_result = sci_calc.evaluate(data_dict['input'], data_dict['angleMode'])
            print(self._sci_result)