# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Utilities"""

from io import BytesIO
from gi.repository import GdkPixbuf
from gi.repository import Pebbles

class Utils():
    """Utilities"""

    float_accuracy: int = 2

    @staticmethod
    def format_float(x: float, scientific_threshold=1e5) -> str:
        """
        Format a given floating point number into a string given
        that float_accuracy and decimal_point_char was set.
        """

        if abs(x) >= scientific_threshold or (0 < abs(x) < 1/scientific_threshold):
            return f"{x:.{Utils.float_accuracy}e}"  # scientific notation

        format_string = f"{{:.{Utils.float_accuracy}f}}"
        rounded_value = format_string.format(x)

        # Remove trailing zeros and the decimal point if not needed
        return rounded_value.rstrip('0').rstrip(Pebbles.get_local_radix_symbol()) \
            if Pebbles.get_local_radix_symbol() in rounded_value else rounded_value

    @staticmethod
    def plot_to_pixbuf(plt, fig, size, dpi, step_size):
        """
        Save figure to a BytesIO buffer in PNG format
        """

        buf = BytesIO()
        fig.set_size_inches((size[0] / dpi), (size[1] / dpi), forward=True)
        fig.patch.set_alpha(0)
        fig.savefig(buf, format="png", bbox_inches='tight', pad_inches=0, dpi=dpi / step_size)
        plt.close(fig)

        buf.seek(0)
        loader = GdkPixbuf.PixbufLoader.new_with_type("png")
        loader.write(buf.getvalue())
        loader.close()
        return loader.get_pixbuf()
