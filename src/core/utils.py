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
    def format_float(x: float, scientific_threshold=1e7) -> str:
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

    @staticmethod
    def plot_to_image(plt, fig, size, dpi, step_size, path):
        fig.set_size_inches((size[0] / dpi), (size[1] / dpi), forward=True)
        fig.patch.set_alpha(0)
        fig.savefig(path, format="png", bbox_inches='tight', dpi=dpi / step_size)
        plt.close(fig)


    @staticmethod
    def get_natural_expression(expr: str) -> str:
        ret_val = expr
        ret_val = ret_val.replace("<", "lsh")
        ret_val = ret_val.replace(">", "rsh")
        ret_val = ret_val.replace("!", "[0]")
        ret_val = ret_val.replace("&", "[1]")
        ret_val = ret_val.replace("|", "[2]")
        ret_val = ret_val.replace("m", "[3]")
        ret_val = ret_val.replace("_", "[4]")
        ret_val = ret_val.replace("o", "[5]")
        ret_val = ret_val.replace("x", "[6]")
        ret_val = ret_val.replace("n", "[7]")
        ret_val = ret_val.replace("[0]", "not")
        ret_val = ret_val.replace("[1]", "and")
        ret_val = ret_val.replace("[2]", "or")
        ret_val = ret_val.replace("[3]", "mod")
        ret_val = ret_val.replace("[4]", "nand")
        ret_val = ret_val.replace("[5]", "nor")
        ret_val = ret_val.replace("[6]", "xor")
        ret_val = ret_val.replace("[7]", "xnor")
        ret_val = ret_val.replace("*", "×")
        ret_val = ret_val.replace("/", "÷")
        ret_val = ret_val.replace("-", "−")  # Unicode minus
        return ret_val


    @staticmethod
    def remove_leading_zeroes(text):
        """
        Remove leading Zeroes from text.
        """
        if text == "0":
            return "0"

        for i, ch in enumerate(text):
            if ch != '0':
                return text[i:]

        return "0"
