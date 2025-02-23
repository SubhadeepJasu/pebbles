# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Main window."""

import json
import threading
from gi.repository import Pebbles
from pebbles.core.memory import ContextualMemory
from pebbles.core.scientific_calculator import ScientificCalculator
from pebbles.core.statistics_calculator import StatisticsCalculator
from pebbles.core.utils import Utils

class PythonWindow(Pebbles.MainWindow):
    """The main window class."""

    def __init__(self, application: Pebbles.Application):
        super().__init__(application=application)

        Utils.decimal_point_char = '.'
        self._memory = ContextualMemory()
        self.history = []
        self.stat_calc = StatisticsCalculator()

        self.connect("on_evaluate", self._evaluate)
        self.connect("on_memory_recall", self.memory_recall)
        self.connect("on_memory_clear", self.memory_clear)
        self.connect("on_stat_plot", self.stat_plot_cb)


    def _evaluate(self, _, data:str):
        _th = threading.Thread(target=self._evaluation_thread, args=(data,))
        _th.start()


    def _evaluation_thread(self, data: str):
        data_dict = json.loads(data)
        if data_dict['mode'] == 'sci':
            sci_calc = ScientificCalculator(data, self._memory)
            result_data, result = sci_calc.evaluate()
            print (result_data)
            self.on_evaluation_completed(result_data)

            if result is not None:
                if data_dict['memoryOp'] == 1:
                    self._memory.add(result, 'sci')
                    self.on_memory_change('sci', self._memory.any('sci'))
                elif data_dict['memoryOp'] == 2:
                    self._memory.add(result, 'global')
                    self.on_memory_change('global', self._memory.any('global'))
                elif data_dict['memoryOp'] == -1:
                    self._memory.subtract(result, 'sci')
                    self.on_memory_change('sci', self._memory.any('sci'))
                elif data_dict['memoryOp'] == -2:
                    self._memory.subtract(result, 'global')
                    self.on_memory_change('global', self._memory.any('global'))

                self.set_history(self._memory.peek(include_view=True))
        elif data_dict['mode'] == 'stat':
            if data_dict['op'] == 'set':
                res = self.stat_calc.populate(data_dict['series'], data_dict['seriesIndex'])
                self.on_evaluation_completed(res)


    def stat_plot_cb(self, _, width:float, height:float, plot_type:Pebbles.StatPlotType, dpi: float):
        return self.stat_calc.plot(width, height, plot_type, dpi)


    def memory_recall(self, _, context: str):
        """
        Recall value from memory with given context.
        """
        if context in ['sci', 'calc']:
            answer = self._memory.recall(context)
            if isinstance(answer, complex):
                if answer.real == 0 and answer.imag == 0:
                    return '0'
                if answer.imag < 0:
                    return f'{Utils.format_float(answer.real)} \
                        - {Utils.format_float(0 - answer.imag)}j'
                return f'{Utils.format_float(answer.real)} + {Utils.format_float(answer.imag)}j'

            if isinstance(answer, float):
                return f'{Utils.format_float(answer)}'

        return ''


    def memory_clear(self, _, context: str):
        """
        Clear memory in given context.
        """
        self._memory.clear(context)
        self.on_memory_change(context, self._memory.any(context))

