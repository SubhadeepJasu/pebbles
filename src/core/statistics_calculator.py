# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Statistics Calculator"""


from io import BytesIO
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
from gi.repository import GdkPixbuf

matplotlib.use("Agg")

class StatisticsCalculator():
    """The statistics calculator."""


    def plot(self, data:list[float], width:float, height:float):
        print ("Plotting ", data, width, height)
        dataset = np.asarray(data, dtype=np.float32)

        fig, ax = plt.subplots(figsize=(width / 100, height / 100), dpi=100)

        # Plot the data
        ax.plot(dataset, color='blue')

        # Save figure to a BytesIO buffer in PNG format
        buf = BytesIO()
        fig.savefig(buf, format="png", bbox_inches='tight', pad_inches=0)
        plt.close(fig)  # Close the figure to free memory

        # Convert buffer to GdkPixbuf
        buf.seek(0)
        loader = GdkPixbuf.PixbufLoader.new_with_type("png")
        loader.write(buf.getvalue())
        loader.close()
        pixbuf = loader.get_pixbuf()
        return pixbuf
