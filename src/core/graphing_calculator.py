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


    def _plot(self):
        try:
            with self.plot_lock:
                steps = [6, 5, 4, 3, 2, 1]
                palette = Pebbles.get_palette(self.plot_params['darkMode'])
                dpi = self.plot_params['dpi']
                width = self.plot_params['width']
                height = self.plot_params['height']
                plt.tight_layout(pad=4 / dpi)

                for step_size in steps:
                    if self.cancel_event.is_set():
                        return

                    fig, ax = self._setup_plot(width, height, dpi, step_size)

                    x_values = np.linspace(
                        self.plot_params['xMin'],
                        self.plot_params['xMax'], width // (step_size ** 2)
                    )
                    t_values = np.linspace(
                        0, 2*np.pi, width // (step_size ** 2)
                    )
                    for pro in self.calculators:
                        if pro['eq'].get_radial_coord_mode():
                            self._plot_radial(ax, pro, palette, (t_values, step_size))
                        else:
                            self._plot_cartesian(ax, pro, palette, (x_values, step_size))

                    if step_size == 1:
                        self._draw_legend(ax)
                        self._configure_labels(ax)

                    pixbuf = self._plot_to_pixbuf(fig, (width, height), dpi, step_size)

                    if self.on_plot_ready:
                        self.on_plot_ready(pixbuf, True)

        except RuntimeError:
            pass


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
                pad=-10,
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
                fontsize=6,
                framealpha=0.6,
                borderpad = 1,
                labelcolor='white',
                facecolor="#444",
                edgecolor="#222"
            )
        else:
            ax.legend(
                loc="upper right",
                fontsize=6,
                framealpha=0.6,
                borderpad = 1,
                labelcolor='#333',
                facecolor="#f8f8f8",
                edgecolor="#ddd"
            )


    def _plot_radial(self, ax, pro, palette, v_params):
        _x_r_values = []
        _y_r_values = []
        for t in v_params[0]:
            pro['calc'].set_substitute_value('X', t, zero_limit=True)
            r = pro['calc'].process()
            _x_r_values.append(r * np.cos(t))
            _y_r_values.append(r * np.sin(t))

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
            y_values.append(pro['calc'].process())

        ax.plot(
            v_params[0],
            y_values,
            label='y = ' + pro['eq'].get_expression(),
            color=palette[pro['eq'].get_index() % len(palette)],
            rasterized=True,
            aa=v_params[1]==1
        )


    def _configure_labels(self, ax):
        for label in ax.get_xticklabels():
            label.set_horizontalalignment('left')

        ax.get_xticklabels()[-1].set_visible(False)

        for label in ax.get_yticklabels():
            label.set_verticalalignment('bottom')

        ax.get_yticklabels()[-1].set_visible(False)


    def _plot_to_pixbuf(self, fig, size, dpi, step_size):
        # Save figure to a BytesIO buffer in PNG format
        buf = BytesIO()
        fig.set_size_inches((size[0] / dpi), (size[1] / dpi), forward=True)
        fig.patch.set_alpha(0)
        fig.savefig(buf, format="png", bbox_inches='tight', pad_inches=0, dpi=dpi / step_size)
        plt.close(fig)

        # Convert buffer to GdkPixbuf
        buf.seek(0)
        loader = GdkPixbuf.PixbufLoader.new_with_type("png")
        loader.write(buf.getvalue())
        loader.close()
        return loader.get_pixbuf()
