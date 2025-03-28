# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Graphing Calculator"""

from io import BytesIO
import threading
import json
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
from gi.repository import Pebbles, GdkPixbuf
from pebbles.core.scientific_calculator import ScientificCalculator
from pebbles.core.tokenizer import Tokenizer

matplotlib.use("Agg")

class GraphingCalculator():
    """The graphing calculator."""

    def __init__(self):
        self.plot_thread:threading.Thread = None
        self.on_plot_ready = None
        self.cancel_event = threading.Event()
        self.calculators = []
        self.plot_params = {}


    def set_plot_params_and_plot(self, payload):
        """
        Set parameters for plotting.
        """
        if payload.get_equations() is not None:
            self.calculators = []
            for eq in payload.get_equations():
                self.calculators.append({
                    'eq': eq,
                    'calc': ScientificCalculator(
                        json.dumps({'input': eq.get_expression(), 'angleMode': int(payload.get_angle_unit())}),
                        None,
                        Tokenizer.GRAPHING_TOKEN_MAP
                    )
                })

        self.plot_params = {
            'width': payload.get_width(),
            'height': payload.get_height(),
            'dpi': payload.get_dpi(),
            'xMin': payload.get_x_min(),
            'xMax': payload.get_x_max(),
            'yMin': payload.get_y_min(),
            'yMax': payload.get_y_max(),
            'xScaling': payload.get_x_scaling(),
            'yScaling': payload.get_y_scaling(),
            'darkMode': payload.get_dark_mode()
        }

        self.start_plotting()


    def set_plot_ready_callback(self, cb):
        """
        Set a callback for when the plot pixbuf is ready and it's ready to draw.
        """
        self.on_plot_ready = cb

    def start_plotting(self):
        print (self.calculators)
        print (self.plot_params)

        if self.plot_thread and self.plot_thread.is_alive():
            self.cancel_event.set()  # Cancel existing thread
            self.plot_thread.join()

        self.cancel_event.clear()
        self.plot_thread = threading.Thread(target=self._plot)
        self.plot_thread.start()


    def _plot(self):
        steps = [32, 16, 8, 4, 1]
        palette = Pebbles.get_palette(self.plot_params['darkMode'])
        dpi = self.plot_params['dpi']
        width = self.plot_params['width']
        height = self.plot_params['height']
        plt.tight_layout(pad=4 / dpi)

        for step_size in steps:
            if self.cancel_event.is_set():
                print("Computation cancelled.")
                return

            fig, ax = plt.subplots(figsize=(width / dpi, height / dpi), dpi=dpi)
            ax.grid(color='#777', linestyle='--', linewidth=0.5, alpha=0.3)
            ax.axhline(0, color='#777', linewidth=1)  # Horizontal axis
            ax.axvline(0, color='#777', linewidth=1)  # Vertical axis
            ax.set_position([0, 0, 1, 1])
            ax.set_facecolor((0, 0, 0, 0))
            ax.spines['top'].set_visible(False)
            ax.spines['right'].set_visible(False)
            ax.spines['bottom'].set_visible(False)
            ax.spines['left'].set_visible(False)
            ax.tick_params(axis='both', direction='in', which='major', labelsize=8, pad=-20, colors='#777')
            # ax.tick_params(axis='y', direction='in', pad=-20)
            fig.subplots_adjust(left=0, right=1, top=1, bottom=0)

            # x_values = np.arange(, , step_size)
            x_values = np.linspace(self.plot_params['xMin'], self.plot_params['xMax'], width // step_size)
            for pro in self.calculators:
                calc: ScientificCalculator = pro['calc']
                y_values = []
                for x in x_values:
                    calc.set_substitute_value('X', x, zero_limit=True)
                    y_values.append(calc.process())

                print(pro['eq'].get_expression())
                print('x=', x_values)
                print('y=', y_values)

                ax.plot(x_values, y_values, label=pro['eq'].get_expression(), color=palette[pro['eq'].get_index() % len(palette)])

            ax.legend(
                loc="upper right",
                fontsize=8,
                framealpha=0.6,
                labelcolor='white',
                facecolor="#333",
                edgecolor="#444"
            )

            # Save figure to a BytesIO buffer in PNG format
            buf = BytesIO()
            fig.set_size_inches(width / dpi, height / dpi, forward=True)
            fig.patch.set_alpha(0)
            fig.savefig(buf, format="png", bbox_inches='tight', pad_inches=0)
            plt.close(fig)  # Close the figure to free memory

            # Convert buffer to GdkPixbuf
            buf.seek(0)
            loader = GdkPixbuf.PixbufLoader.new_with_type("png")
            loader.write(buf.getvalue())
            loader.close()
            if self.on_plot_ready:
                self.on_plot_ready(loader.get_pixbuf(), True)

            plt.pause(0.1)
