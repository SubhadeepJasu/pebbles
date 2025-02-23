# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Statistics Calculator"""


from io import BytesIO
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import json
from gi.repository import GdkPixbuf

matplotlib.use("Agg")

class StatisticsCalculator():
    """The statistics calculator."""

    MODE = 'stat'
    AXIS_COLOR = "#272863"
    PALETTE = ["#272863", "#3689e6", "#c6262e", "#3a9104", "#d48e15", "#f37329",
               "#bc245d", "#7239b3", "#b6802e", "#57392d", "#485a6c", "#333333"]

    def __init__(self):
        self.data = np.ndarray(shape=(0,0))


    def populate(self, series:list[float], series_index:int):
        """
        Populate the data table using the given `series` at `series_index`.
        """
        data_np = np.array(series, dtype=np.float32)

        num_rows, num_cols = self.data.shape

        if series_index < num_rows:
            if len(series) == num_cols:
                self.data[series_index] = data_np
            else:
                new_cols = max(num_cols, len(series))
                new_array = np.zeros((num_rows, new_cols), dtype=np.float32)
                new_array[:, :num_cols] = self.data  # Copy existing data
                new_array[series_index, :len(series)] = data_np
                self.data = new_array
        else:
            # Expand rows to accommodate series_index
            new_rows = series_index + 1
            new_cols = max(num_cols, len(series))
            new_array = np.zeros((new_rows, new_cols), dtype=np.float32)
            new_array[:num_rows, :num_cols] = self.data  # Copy existing series
            new_array[series_index, :len(series)] = data_np
            self.data = new_array

        row_mask = ~(self.data == 0).all(axis=1)  # Rows that have at least one non-zero value
        col_mask = ~(self.data == 0).all(axis=0)  # Columns that have at least one non-zero value

        if not row_mask.any() or not col_mask.any():
            self.data = np.zeros((1, 1), dtype=np.float32)
        else:
            self.data = self.data[np.ix_(row_mask, col_mask)]

        print(self.data)

        return json.dumps({'mode': self.MODE, 'result': ''})


    def plot(self, width:float, height:float, plot_type=0, dpi=100.0):
        """
        Plot the graph for the data table
        """

        fig, ax = plt.subplots(figsize=(width / dpi, height / dpi), dpi=dpi)

        # Plot the data
        ax.set_yticklabels([])
        ax.set_xticklabels([])
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.set_facecolor((0, 0, 0, 0))
        fig.subplots_adjust(left=0, right=1, top=1, bottom=0)
        ax.spines["left"].set_color(self.AXIS_COLOR)
        ax.spines["bottom"].set_color(self.AXIS_COLOR)
        plt.rcParams["axes.prop_cycle"] = plt.cycler(color=self.PALETTE)

        if plot_type == 0:
            self._line_plot(ax)
        elif plot_type == 1:
            self._pie_plot(ax)
        elif plot_type == 2:
            self._bar_plot(ax, width, dpi)
        elif plot_type == 3:
            self._scatter_plot(ax)

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
        pixbuf = loader.get_pixbuf()
        return pixbuf


    def _line_plot(self, ax):
        ax.plot(self.data.T)


    def _pie_plot(self, ax):
        num_rings = self.data.shape[0]
        radius_step = 0.8 / num_rings
        # Draw each concentric ring
        for i, row in enumerate(self.data):
            ax.pie(
                row,
                radius=1 + i * radius_step,  # Increase radius for each layer
                startangle=140,
                wedgeprops={"width": radius_step}
            )


    def _bar_plot(self, ax, width, dpi):
        x = np.arange(self.data.shape[1])  # Column indices
        num_bars = self.data.shape[0]
        width_step = max(((width / dpi) / num_bars) - 0.1, 0.1)
        for i, row in enumerate(self.data):
            ax.bar(x + i * 0.1, row, width=width_step, label=f"Row {i+1}")


    def _scatter_plot(self, ax):
        x = np.repeat(np.arange(self.data.shape[0]), self.data.shape[1])  # Row indices repeated
        y = np.tile(np.arange(self.data.shape[1]), self.data.shape[0])    # Column indices tiled
        values = self.data.flatten()
        ax.scatter(x, y, c=values)
