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
from pebbles.core.graphing_calculator import GraphingCalculator
from pebbles.core.calculus_calculator import CalculusCalculator
from pebbles.core.converter import Converter
from pebbles.core.tokenizer import Tokenizer
from pebbles.core.utils import Utils

class PythonWindow(Pebbles.MainWindow):
    """The main window class."""

    def __init__(self, application: Pebbles.Application):
        super().__init__(application=application)

        Utils.decimal_point_char = '.'
        self._memory = ContextualMemory()
        self.history = []
        self.stat_calc = StatisticsCalculator(self._memory)
        self.stat_calc.set_plot_ready_callback(self._stat_plot_ready_cb)

        self.graph_calc = GraphingCalculator(self._memory)
        self.graph_calc.set_plot_ready_callback(self._graph_ready_cb)

        self.connect("on_evaluate", self._evaluate)
        self.connect("on_memory_recall", self._memory_recall)
        self.connect("on_memory_clear", self._memory_clear)
        self.connect("on_history_view", self._history_view_cb)
        self.connect("on_history_copy", self._history_copy_cb)
        self.connect("on_history_insert", self._history_insert_cb)
        self.connect("on_history_recall", self._history_recall_cb)
        self.connect("on_stat_plot", self._stat_plot_cb)
        self.connect("on_stat_cell_update", self._stat_cell_update_cb)
        self.connect("on_stat_cell_query", self._stat_cell_query_cb)
        self.connect("on_stat_export", self._on_stat_export_cb)
        self.connect("on_get_last_result", self._on_query_last_result_cb)
        self.connect("on_render_graph", self._on_render_graph)
        self.connect("on_convert_value", self._on_convert_value_cb)


    def _evaluate(self, _, data:str):
        _th = threading.Thread(target=self._evaluation_thread, args=(data,))
        _th.start()


    def _evaluation_thread(self, data: str):
        data_dict = json.loads(data)
        result_data: any
        result: any
        if data_dict['context'] == Pebbles.Context.SCIENTIFIC:
            sci_calc = ScientificCalculator(data, self._memory, Tokenizer.SCIENTIFIC_TOKEN_MAP)
            result_data, result = sci_calc.evaluate()
            self._commit_to_memory(result, Pebbles.Context.SCIENTIFIC, data_dict['memoryOp'])
            self.show_history(self._memory.get_views(
                format_func=ScientificCalculator.format,
                context=Pebbles.Context.SCIENTIFIC
            ), Pebbles.Context.SCIENTIFIC)

        elif data_dict['context'] == Pebbles.Context.STATISTICS:
            if data_dict['op'] == Pebbles.StatOp.LOAD_DATASET:
                result_data = self.stat_calc.load_csv_data(data_dict['options']['csv'])
            elif data_dict['op'] == Pebbles.StatOp.CLEAR_DATASET:
                result_data = self.stat_calc.clear_dataset()
            elif data_dict['op'] == Pebbles.StatOp.CLEAR_SERIES:
                result_data = self.stat_calc.clear_series(data_dict['options']['seriesIndex'])
            else:
                result_data, result = self.stat_calc.evaluate (
                    data_dict['op'],
                    data_dict['options']['seriesIndex']
                )
                self._commit_to_memory(result,
                                Pebbles.Context.STATISTICS, data_dict['options']['memoryOp'])
                self.show_history(self._memory.get_views(
                    format_func=ScientificCalculator.format,
                    context=Pebbles.Context.STATISTICS
                ), Pebbles.Context.STATISTICS)
        elif data_dict['context'] == Pebbles.Context.CALCULUS:
            cal_calc = CalculusCalculator(data, self._memory)
            result_data,result = cal_calc.evaluate()
            self._commit_to_memory(result, Pebbles.Context.CALCULUS, data_dict['memoryOp'])
            self.show_history(self._memory.get_views(
                format_func=ScientificCalculator.format,
                context=Pebbles.Context.CALCULUS
            ), Pebbles.Context.CALCULUS)
        else:
            return

        self.on_evaluation_completed(result_data)


    def _commit_to_memory(self, result, context, memory_op):
        if result is not None:
            if memory_op == Pebbles.MemAppendOp.ADD:
                self._memory.add(result, context)
                self.on_memory_change(context,
                                        self._memory.any(context))
            elif memory_op == Pebbles.MemAppendOp.ADD_GLOBAL:
                self._memory.add(result, Pebbles.Context.GLOBAL)
                self.on_memory_change(Pebbles.Context.GLOBAL,
                                        self._memory.any(Pebbles.Context.GLOBAL))
            elif memory_op == Pebbles.MemAppendOp.SUBTRACT:
                self._memory.subtract(result, context)
                self.on_memory_change(context,
                                        self._memory.any(context))
            elif memory_op == Pebbles.MemAppendOp.SUBTRACT_GLOBAL:
                self._memory.subtract(result, Pebbles.Context.GLOBAL)
                self.on_memory_change(Pebbles.Context.GLOBAL,
                                        self._memory.any(Pebbles.Context.GLOBAL))


    def _on_query_last_result_cb(self, _, context:str):
        return self._memory.get_last_result(context)


    def _history_view_cb(self, _, context:str):
        if context in [Pebbles.Context.SCIENTIFIC, Pebbles.Context.STATISTICS, Pebbles.Context.CALCULUS]:
            self.show_history(self._memory.get_views(
                    format_func=ScientificCalculator.format,
                    context=context
                ), context)


    def _history_insert_cb(self, _, item_id:int):
        item = self._memory.get_history_by_id(item_id)
        context = item.get_context()
        result = item.get_result()
        if context in [Pebbles.Context.SCIENTIFIC, Pebbles.Context.STATISTICS]:
            return ScientificCalculator.format(result)
        return ''


    def _history_copy_cb(self, _, item_id:int):
        item = self._memory.get_history_by_id(item_id)
        return item.get_result()


    def _history_recall_cb(self, _, item_id: int):
        item = self._memory.get_history_by_id(item_id)
        context = item.get_context()
        if context in [Pebbles.Context.SCIENTIFIC, Pebbles.Context.STATISTICS]:
            item.set_result(ScientificCalculator.format(item.get_result()))

            if context == Pebbles.Context.STATISTICS:
                metadata = item.get_metadata()
                dataset_hash = metadata.get_metadata_4()
                if dataset_hash and dataset_hash != self.stat_calc.hash_dataset():
                    print ("WARNING: Hash mismatch. \
Attempting to make a table with the previous series.")
                    try:
                        res = json.loads(self.stat_calc.load_csv_data(metadata.get_metadata_3()))
                        if res and 'shape' in res and res['shape']:
                            # Store max_series_length for use when redrawing the table
                            item.get_metadata().set_metadata_3(str(res['shape'][1]))
                            self.warn_table_change()
                    except ValueError as e:
                        print(f"Error: Cannot recall previous state from history: {e}")

        self.history_recall(item)
        return item


    def _stat_cell_update_cb(self, _, value:float, index:int, series_index:int):
        return self.stat_calc.update_value (value, index, series_index)


    def _stat_cell_query_cb(self, _, index:int, series_index:int):
        value = self.stat_calc.get_value(index, series_index)
        if value is not None:
            return f"{value:.16g}"

        return ""


    def _stat_plot_ready_cb(self, pixbuf, valid):
        self.on_plot_ready (pixbuf, valid)

    def _stat_plot_cb(
            self, _, width:float, height:float, plot_type:Pebbles.StatPlotType, dpi: float):
        self.stat_calc.set_plot_params_and_plot(width, height, plot_type, dpi)


    def _on_stat_export_cb(self, _, path: str):
        self.stat_calc.export(path)


    def _on_render_graph(self, _, payload):
        self.graph_calc.set_plot_params_and_plot (payload)


    def _graph_ready_cb(self, pixbuf, valid):
        self.on_render_ready(pixbuf, valid)


    def _memory_recall(self, _, context: str):
        """
        Recall value from memory with given context.
        """
        formatted_answer = ''
        if context in [Pebbles.Context.SCIENTIFIC, Pebbles.Context.CALCULUS]:
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
        elif context == Pebbles.Context.STATISTICS:
            answer = self._memory.recall(context)
            formatted_answer = f'{Utils.format_float(answer)}'
        else:
            answer = float(self._memory.recall(context))
            formatted_answer = f'{Utils.format_float(answer)}'

        return formatted_answer


    def _memory_clear(self, _, context: str):
        """
        Clear memory in given context.
        """
        self._memory.clear(context)
        self.on_memory_change(context, self._memory.any(context))


    def _on_convert_value_cb(self, _,
                             input_str:str, conversion_factors:list,
                             conversion_factor_len:int, unit_1:int, unit_2:int):
        converter = Converter(conversion_factors)
        return converter.convert(input_str, unit_1, unit_2)
