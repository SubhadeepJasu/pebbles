# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>

"""Graphing Calculator"""

import threading
import json
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
from gi.repository import Pebbles
from pebbles.core.scientific_calculator import ScientificCalculator
from pebbles.core.tokenizer import Tokenizer
from pebbles.core.memory import ContextualMemory
from pebbles.core.utils import Utils

matplotlib.use("Agg")

class GraphingCalculator:
    """The graphing calculator."""

    LEGEND_PROPS = {
        'size': 6,
        'style': 'italic'
    }

    def __init__(self, memory: ContextualMemory):
        self.memory = memory
        self.plot_thread:threading.Thread = None
        self.on_plot_ready = None
        self.cancel_event = threading.Event()
        self.calculators = []
        self.plot_params = {}
        self.plot_lock = threading.Lock()


    def set_plot_params_and_plot(self, payload):
        """
        Set parameters for plotting.
        """
        if payload.contains_equations():
            self.calculators = []
            for eq in payload.get_equations():
                self.calculators.append({
                    'eq': eq,
                    'calc': ScientificCalculator(
                        json.dumps({
                            'input': eq.get_expression(),
                            'angleMode': int(payload.get_angle_unit())
                        }),
                        self.memory,
                        Tokenizer.GRAPHING_TOKEN_MAP,
                        override_context=Pebbles.Context.GRAPHING
                    )
                })

        self.plot_params = {
            'width': payload.get_width(),
            'height': payload.get_height(),
            'a': payload.get_var_a(),
            'b': payload.get_var_b(),
            'c': payload.get_var_c(),
            'm': payload.get_var_m(),
            'dpi': payload.get_dpi(),
            'xMin': payload.get_x_min(),
            'xMax': payload.get_x_max(),
            'yMin': payload.get_y_min(),
            'yMax': payload.get_y_max(),
            'xScaling': payload.get_x_scaling(),
            'yScaling': payload.get_y_scaling(),
            'darkMode': payload.get_dark_mode(),
            'fidelity': payload.get_fidelity_mode()
        }

        self.start_plotting()


    def set_plot_ready_callback(self, cb):
        """
        Set a callback for when the plot pixbuf is ready and it's ready to draw.
        """
        self.on_plot_ready = cb


    def start_plotting(self):
        """
        Start the plotting process
        """
        if self.plot_thread and self.plot_thread.is_alive():
            self.cancel_event.set()  # Cancel existing thread
            self.plot_thread.join()
            if self.plot_lock.locked():
                self.plot_lock.release()

        self.cancel_event.clear()
        self.plot_thread = threading.Thread(target=self._plot)
        self.plot_thread.start()


    def _plot(self, path=''):
        try:
            with self.plot_lock:
                fidelity_mode = self.plot_params['fidelity']
                step_size = 1 if fidelity_mode or path != '' else 6
                palette = Pebbles.get_palette(self.plot_params['darkMode'])
                dpi = self.plot_params['dpi']
                width = self.plot_params['width']
                height = self.plot_params['height']
                plt.tight_layout(pad=4 / dpi)

                if self.cancel_event.is_set():
                    return

                fig, ax = self._setup_plot(width, height, dpi, step_size)
                x_values = self._generate_plot_x_values(
                    self.plot_params['xScaling'],
                    width,
                    step_size
                )

                if self.plot_params['yScaling'] == 1:
                    x_values = x_values[x_values != 0]

                t_values = np.linspace(
                    0, 2 * np.pi, width // (step_size ** 2)
                )
                for pro in self.calculators:
                    pro['calc'].set_substitute_value('A',
                                                     self.plot_params['a'], zero_limit=True)
                    pro['calc'].set_substitute_value('B',
                                                     self.plot_params['b'], zero_limit=True)
                    pro['calc'].set_substitute_value('C',
                                                     self.plot_params['c'], zero_limit=True)
                    pro['calc'].set_substitute_value('M',
                                                    self.plot_params['m'], zero_limit=True)
                    if pro['eq'].get_radial_coord_mode():
                        self._plot_radial(ax, pro, palette, (t_values, step_size))
                    else:
                        self._plot_cartesian(
                            ax, pro, palette,
                            (
                                x_values,
                                step_size,
                                self.plot_params['xScaling'],
                                self.plot_params['yScaling']
                            )
                        )

                if path == '':
                    if fidelity_mode:
                        self._draw_legend(ax)
                        self._configure_labels(ax)
                        pixbuf_f = Utils.plot_to_pixbuf(plt, fig, (width, height), dpi, step_size)
                        ax.set_xticklabels([])
                        ax.set_yticklabels([])
                        ax.get_legend().remove()
                        pixbuf_i = Utils.plot_to_pixbuf(plt, fig, (width, height), dpi, step_size)
                        if self.on_plot_ready:
                            self.on_plot_ready(pixbuf_i, pixbuf_f, True)
                    else:
                        ax.set_xticklabels([])
                        ax.set_yticklabels([])
                        pixbuf_f = Utils.plot_to_pixbuf(plt, fig, (width, height), dpi, step_size)
                        if self.on_plot_ready:
                            self.on_plot_ready(None, pixbuf_f, True)
                else:
                    self._draw_legend(ax)
                    self._configure_labels(ax)
                    Utils.fig_save_path = path
                    Utils.plot_to_image(plt, fig, (width, height), dpi, step_size)

        except RuntimeError:
            pass


    def _generate_plot_x_values(self, x_scaling, width, step_size):
        if x_scaling == 1:
            x_values = np.logspace(
                self.plot_params['xMin'],
                self.plot_params['xMax'], width // (step_size ** 2)
            )
            x_values = np.log10(x_values[x_values > 0])
        else:
            x_values = np.linspace(
                self.plot_params['xMin'],
                self.plot_params['xMax'], width // (step_size ** 2)
            )

        return x_values

    def export(self, path:str):
        """
        Export the current plot to a PNG file.
        """
        if not path.lower().endswith('png'):
            path += ".png"
        self._plot(path)


    def _setup_plot(self, width, height, dpi, step_size):
        fig, ax = plt.subplots(figsize=(width / dpi, height / dpi), dpi=dpi)
        ax.margins(0)
        ax.grid(color='#777', linewidth=0.5, alpha=0.3)
        ax.axhline(0, color='#777', linewidth=1)
        ax.axvline(0, color='#777', linewidth=1)
        ax.set_position([0, 0, 1, 1])
        ax.set_facecolor((0, 0, 0, 0))
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        ax.set_xlim(self.plot_params['xMin'], self.plot_params['xMax'])
        ax.set_ylim(self.plot_params['yMin'], self.plot_params['yMax'])
        if step_size == 1:
            ax.tick_params(
                axis='both',
                direction='in',
                which='major',
                labelsize=6,
                pad=-12,
                colors='#777'
            )
        else:
            ax.set_xticklabels([])
            ax.set_yticklabels([])
        ax.set_autoscale_on(False)
        fig.subplots_adjust(left=0, right=1, top=1, bottom=0)
        return fig, ax


    def _draw_legend(self, ax):
        if self.plot_params['darkMode']:
            ax.legend(
                loc="upper right",
                framealpha=0.6,
                borderpad = 1,
                labelcolor='white',
                facecolor="#444",
                edgecolor="#222",
                prop=GraphingCalculator.LEGEND_PROPS
            )
        else:
            ax.legend(
                loc="upper right",
                framealpha=0.6,
                borderpad = 1,
                labelcolor='#333',
                facecolor="#f8f8f8",
                edgecolor="#ddd",
                prop=GraphingCalculator.LEGEND_PROPS
            )


    def _plot_radial(self, ax, pro, palette, v_params):
        _x_r_values = []
        _y_r_values = []
        for t in v_params[0]:
            pro['calc'].set_substitute_value('X', t, zero_limit=True)
            try:
                r = pro['calc'].process()
                _x_r_values.append(r * np.cos(t))
                _y_r_values.append(r * np.sin(t))
            except ArithmeticError:
                pass

        ax.plot(
            _x_r_values,
            _y_r_values,
            label='r = ' + pro['eq'].get_expression(),
            color=palette[pro['eq'].get_index() % len(palette)],
            rasterized=True,
            aa=v_params[1]==1
        )


    def _plot_cartesian(self, ax, pro, palette, v_params):
        y_values = []
        for x in v_params[0]:
            pro['calc'].set_substitute_value('X', x, zero_limit=True)
            try:
                y_values.append(pro['calc'].process())
            except ArithmeticError:
                pass

        if v_params[3] == 1:
            y_values = np.log10(y_values)

        ax.plot(
            v_params[0],
            y_values,
            label='y = ' + pro['eq'].get_expression(),
            color=palette[pro['eq'].get_index() % len(palette)],
            rasterized=True,
            aa=v_params[1]==1
        )

        if v_params[2] == 1:
            ax.set_xscale('symlog', linthresh=0.1)
        else:
            ax.set_xscale('linear')


    def _configure_labels(self, ax):
        for label in ax.get_xticklabels():
            label.set_horizontalalignment('left')

        ax.get_xticklabels()[-1].set_visible(False)

        for label in ax.get_yticklabels():
            label.set_verticalalignment('bottom')

        ax.get_yticklabels()[-1].set_visible(False)
