# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Main window."""

from gi.repository import Pebbles
from pebbles.core.memory import ContextualMemory
from pebbles.core.scientific_calculator import ScientificCalculator
import json
import threading

class PythonWindow(Pebbles.Window):
    """The main window class."""

    def __init__(self, application: Pebbles.Application):
        super().__init__(application=application)

        self._memory = ContextualMemory()
        self.connect("on_evaluate", self._evaluate)


    def _evaluate(self, _, data:str):
        _th = threading.Thread(target=self._evaluation_thread, args=(data,))
        _th.start()


    def _evaluation_thread(self, data: str):
        data_dict = json.loads(data)
        if data_dict['mode'] == 'scientific':
            sci_calc = ScientificCalculator(data, self._memory)
            result_data, result = sci_calc.evaluate()
            self.on_evaluation_completed(result_data)

            if result is not None:
                if data_dict['memoryOp'] == 1:
                    self._memory.add(result, 'sci')
                    self.on_memory_change('sci', self._memory.any('sci'))
                if data_dict['memoryOp'] == 2:
                    self._memory.add(result, 'global')
                    self.on_memory_change('global', self._memory.any('global'))

                self._memory.peek()

