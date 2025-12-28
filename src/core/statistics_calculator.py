# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Statistics Calculator"""


from io import StringIO
import threading
import json
import hashlib
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
from gi.repository import Pebbles
from pebbles.core.memory import ContextualMemory
from pebbles.core.utils import Utils

matplotlib.use("Agg")

class StatisticsCalculator():
    """The statistics calculator."""

    MODE = Pebbles.Context.STATISTICS
    AXIS_COLOR = "#272863"

    def __init__(self, memory: ContextualMemory):
        self.memory = memory
        self.data = np.ndarray(shape=(0,0))
        self.plot_params = (1, 1, 100, 0) # width, height, dpi, type
        self.plot_thread:threading.Thread = None
        self.plot_lock = threading.Lock()
        self.on_plot_ready = None
        self.is_plotting = False


    def update_value(self, value: float, index: int, series_index: int):
        """
        Update the value of a cell.
        """
        current_rows, current_cols = self.data.shape

        # Step 1: Calculate new shape
        new_rows = max(current_rows, series_index + 1)
        new_cols = max(current_cols, index + 1)

        # Step 2: Resize only if needed
        if new_rows > current_rows or new_cols > current_cols:
            new_data = np.zeros((new_rows, new_cols), dtype=float)
            new_data[:current_rows, :current_cols] = self.data  # Copy existing data
            self.data = new_data  # Replace with resized array

        # Step 3: Update the value
        self.data[series_index, index] = value

        # Step 4: Trim empty rows/columns
        self._trim()

        self.start_plotting ()
        # print(self.data)
        return self.data.shape[1]


    def _trim(self):
        # Trim only trailing all-zero rows
        while self.data.shape[0] > 0 and np.all(self.data[-1] == 0):
            self.data = self.data[:-1, :]

        # Trim only trailing all-zero columns
        while self.data.shape[1] > 0 and np.all(self.data[:, -1] == 0):
            self.data = self.data[:, :-1]


    def get_value(self, index: int, series_index: int):
        """
        Returns the value at (series_index, index) or None if out of bounds.
        """
        if series_index >= self.data.shape[0] or index >= self.data.shape[1]:
            return None
        return self.data[series_index, index]


    def load_csv_data(self, csv_data: str):
        """
        Import data from a CSV string.
        """
        try:
            csv_file = StringIO(csv_data)
            first_line = csv_file.readline().strip()
            first_values = first_line.split(",")
            try:
                list(map(float, first_values))  # Test conversion
                csv_file.seek(0)  # Reset file pointer if first row is numeric
            except ValueError:
                pass  # First row is non-numeric, so we skip it
            self.data = np.loadtxt(csv_file, delimiter=",", dtype=float).T

            if len(self.data.shape) == 1:
                self.data = self.data.reshape(1, -1) # Ensure that the table has two dimensions
            # print (self.data)
        except ValueError as ve:
            raise ve

        self.start_plotting()
        return json.dumps({'mode': self.MODE, 'result': '', 'shape': self.data.shape})


    def hash_dataset(self):
        """Get the sha256 hash of the dataset."""
        data = self.data.tobytes()
        return hashlib.sha256(data).hexdigest()


    def clear_dataset(self):
        """
        Empty the table.
        """
        self.data = np.ndarray(shape=(1, 1))
        self.data[0, 0] = 0.0
        return json.dumps({'mode': self.MODE, 'result': '0', 'cleared': True})


    def clear_series(self, series_index:int):
        """
        Clear the given series in the dataset
        """
        if 0 <= series_index < self.data.shape[0]:  # Ensure index is valid
            self.data[series_index, :] = 0.0
            return json.dumps({'mode': self.MODE, 'result': '0', 'cleared': True})

        return json.dumps({'mode': self.MODE, 'result': 'E', 'cleared': False})


    def fetch_series(self, series_index: int) -> list[float]:
        """
        Fetch the given series/row data as per the given `series_index`.
        """

        if 0 <= series_index < len(self.data):
            return list(self.data[series_index])
        return []


    def fetch_table_shape(self):
        """
        Fetch data table shape.
        """

        return self.data.shape


    def set_plot_ready_callback(self, cb):
        """
        Set a callback for when the plot pixbuf is ready and it's ready to draw.
        """
        self.on_plot_ready = cb


    def set_plot_params_and_plot(self, width:float, height:float, plot_type=0, dpi=100.0):
        """
        Set parameters for plotting.
        """
        self.plot_params = (width, height, dpi, plot_type)
        self.start_plotting()


    def start_plotting(self, m=None, b=None):
        """
        Plot the graph for the data table
        """
        if self.is_plotting:
            return

        self.is_plotting = True
        if self.plot_thread is None or not self.plot_thread.is_alive():
            self.plot_thread = threading.Thread(target=self._plot, args=(m, b,))
            self.plot_thread.start()
        else:
            self.plot_lock.release()


    def _plot(self, m=None, b=None):
        try:
            with self.plot_lock:
                width, height, dpi, plot_type = self.plot_params
                if self.data.shape[0] == 0 or self.data.shape[1] < 2:
                    self.is_plotting = False
                    return

                if self.data.shape[0] > 20 or self.data.shape[1] > 2000:
                    self.is_plotting = False
                    if self.on_plot_ready:
                        self.on_plot_ready(None, False)
                    return

                fig, ax = plt.subplots(figsize=(width / dpi, height / dpi), dpi=dpi)

                # Plot the data
                ax.set_yticklabels([])
                ax.set_xticklabels([])
                ax.set_position([0, 0, 1, 1])
                ax.spines["top"].set_visible(False)
                ax.spines["right"].set_visible(False)
                ax.set_facecolor((0, 0, 0, 0))
                fig.subplots_adjust(left=0, right=1, top=1, bottom=0)
                ax.spines["left"].set_color(self.AXIS_COLOR)
                ax.spines["bottom"].set_color(self.AXIS_COLOR)
                plt.rcParams["axes.prop_cycle"] = plt.cycler(color=Pebbles.get_palette(False))
                plt.tight_layout(pad=4 / dpi)

                try:
                    if plot_type == 0:
                        self._line_plot(ax, m, b)
                    elif plot_type == 1:
                        self._pie_plot(ax)
                    elif plot_type == 2:
                        self._bar_plot(ax, m, b)
                    elif plot_type == 3:
                        self._scatter_plot(ax, m, b)
                except ValueError:
                    self.is_plotting = False
                    if self.on_plot_ready:
                        self.on_plot_ready(None, False)
                        return

                # Save figure to a BytesIO buffer in PNG format
                plt_buf = Utils.plot_to_pixbuf(plt, fig, (width, height), dpi, 1)
                self.is_plotting = False
                if self.on_plot_ready:
                    self.on_plot_ready(plt_buf, True)
        except RuntimeError:
            self.is_plotting = False


    def _line_plot(self, ax, m=None, b=None):
        if self.data.shape[0] > 20 or self.data.shape[1] > 2000:
            raise ValueError

        ax.axhline(y=0, color=self.AXIS_COLOR, linewidth=1, linestyle="--")
        ax.plot(self.data.T, linewidth=0.5)

        # Draw regression line if both m (slope) and b (intercept) are provided
        if m is not None and b is not None:
            x = np.arange(self.data.shape[1])  # Use row indices as X
            y_pred = m * x + b  # Compute Y using y = mx + b
            ax.plot(x, y_pred, linestyle="dotted", color="red", linewidth=1)


    def _pie_plot(self, ax):
        if self.data.shape[0] > 10 or self.data.shape[1] > 360:
            raise ValueError

        try:
            num_rings = self.data.shape[0]
            if num_rings > 0:
                max_radius = 1.2  # Ensure everything fits within the figure
                radius_step = max_radius / (num_rings + 1)  # Scale radius properly

                for i, row in enumerate(self.data):
                    ax.pie(
                        row,
                        radius=(i + 1) * radius_step,  # Adjust radius so it scales correctly
                        wedgeprops={"width": radius_step}
                    )
        except ValueError:
            pass


    def _bar_plot(self, ax, m, b):
        if self.data.shape[0] > 10 or self.data.shape[1] > 100:
            raise ValueError

        ax.axhline(y=0, color=self.AXIS_COLOR, linewidth=1, linestyle="--")
        x = np.arange(self.data.shape[1])  # Column indices
        num_bars = self.data.shape[0]
        if num_bars > 0:
            width_step = min((1 / num_bars) * 0.8, 0.8)  # Scale width based on num_bars
            for i, row in enumerate(self.data):
                ax.bar(x + i * width_step, row, width=width_step, label=f"Row {i+1}")

        # Draw regression line if both m (slope) and b (intercept) are provided
        if m is not None and b is not None:
            x = np.arange(self.data.shape[1])  # Use row indices as X
            y_pred = m * x + b  # Compute Y using y = mx + b
            ax.plot(x, y_pred, linestyle="dotted", color="red", linewidth=1)


    def _scatter_plot(self, ax, m, b):
        num_rows, num_cols = self.data.shape
        if num_rows > 20 or num_cols > 2000:
            raise ValueError

        # Generate x (column indices repeated for each row)
        x = np.tile(np.arange(num_cols), num_rows)
        # Flattened y-values (actual data values)
        y = self.data.flatten()
        # Assign colors per row, repeating for each column
        colors = np.repeat(Pebbles.get_palette(False)[:num_rows], num_cols)

        ax.axhline(y=0, color=self.AXIS_COLOR, linewidth=1, linestyle="--")
        ax.scatter(x, y, c=colors, edgecolor="none", s=4)

        # Draw regression line if both m (slope) and b (intercept) are provided
        if m is not None and b is not None:
            x = np.arange(self.data.shape[1])  # Use row indices as X
            y_pred = m * x + b  # Compute Y using y = mx + b
            ax.plot(x, y_pred, linestyle="dotted", color="red", linewidth=1)


    def evaluate(self, op:int, series_index:int):
        """
        Evaluate.
        """

        _op = Pebbles.StatOp(op)
        res = "E"
        input_exp = Pebbles.stat_op_to_exp(op)
        val = None

        if _op == Pebbles.StatOp.TREND:
            res, val = self._trend(series_index)
        elif _op == Pebbles.StatOp.SHAPE:
            res, val = self._shape()
        elif _op == Pebbles.StatOp.MODE:
            res, val = self._mode(series_index)
        elif _op == Pebbles.StatOp.MEDIAN:
            res, val = self._median(series_index)
        elif _op == Pebbles.StatOp.SUM:
            res, val = self._sum(series_index)
        elif _op == Pebbles.StatOp.SUM_SQUARED:
            res, val = self._sum_sq(series_index)
        elif _op in [Pebbles.StatOp.SAMPLE_VAR, Pebbles.StatOp.POPULATION_VAR]:
            res, val = self._variance(series_index, sample=_op == Pebbles.StatOp.SAMPLE_VAR)
        elif _op in [Pebbles.StatOp.SAMPLE_SD, Pebbles.StatOp.POPULATION_SD]:
            res, val = self._deviation(series_index, sample=_op == Pebbles.StatOp.SAMPLE_SD)
        elif _op == Pebbles.StatOp.MEAN:
            res, val = self._mean(series_index)
        elif _op == Pebbles.StatOp.MEAN_SQUARED:
            res, val = self._mean_sq(series_index)
        elif _op == Pebbles.StatOp.GEOMETRIC_MEAN:
            res, val = self._geometric_mean(series_index)

        if res != "E":
            self.memory.push_history(
                Pebbles.Context.STATISTICS,
                input_exp,
                str(val),
                {
                    'metadata_1': op,
                    'metadata_2': series_index,
                    'metadata_3': '\n'.join(map(str, self.data[series_index])),
                    'metadata_4': self.hash_dataset()
                }
            )

        return json.dumps({'mode': self.MODE, 'result': res}), val


    def _trend (self, series_index:int):
        _data = self.data.T
        if self.data.shape[1] <= series_index:
            return "E"

        x = np.arange(_data.shape[0])
        y = y = _data[:, series_index]

        m, b = np.polyfit(x, y, 1)

        self.start_plotting (m, b)

        return Utils.format_float(m), m


    def _shape(self):
        return f"{self.data.shape[1]}, {self.data.shape[0]}", self.data.shape[1]


    def _mode(self, series_index:int):
        row = self.data[series_index]
        values, counts = np.unique(row, return_counts=True)
        mode_val = values[np.argmax(counts)]
        return Utils.format_float(mode_val), mode_val


    def _median(self, series_index:int):
        median_val = np.median(self.data[series_index])
        return Utils.format_float(median_val), median_val


    def _sum(self, series_index:int):
        sum_val = np.sum(self.data[series_index])
        return Utils.format_float(sum_val), sum_val


    def _sum_sq(self, series_index:int):
        sumsq = np.sum(np.square(self.data[series_index]))
        return Utils.format_float(sumsq), sumsq


    def _variance(self, series_index:int, sample=False):
        var = np.var(self.data[series_index], ddof=1 if sample else 0)
        return Utils.format_float(var), var


    def _deviation(self, series_index:int, sample=False):
        dev = np.std(self.data[series_index], ddof=1 if sample else 0)
        return Utils.format_float(dev), dev


    def _mean(self, series_index:int):
        mean = np.mean(self.data[series_index])
        return Utils.format_float(mean), mean


    def _mean_sq(self, series_index:int):
        msq = np.mean(np.square(self.data[series_index]))
        return Utils.format_float(msq), msq


    def _geometric_mean(self, series_index:int):
        series = self.data[series_index]
        if np.any(series <= 0):
            return "E", None

        gm = np.exp(np.mean(np.log(series)))
        return Utils.format_float(gm), gm


    def export(self, path: str):
        """
        Saves the current dataset (`self.data`) as a CSV file.
        """
        try:
            if not path.endswith(".csv"):
                path += ".csv"
            np.savetxt(path, self.data.T, delimiter=",")  # Transpose to match input format
        except PermissionError:
            print(f"ERROR: No permission to write to {path}")
        except OSError as e:
            print(f"ERROR: OS error while saving CSV: {e}")
