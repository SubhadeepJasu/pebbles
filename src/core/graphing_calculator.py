# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>
# SPDX-FileCopyrightText: 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Graphing Calculator"""

from io import BytesIO, StringIO
import threading
import json
import hashlib
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
from gi.repository import Pebbles, GdkPixbuf
from pebbles.core.memory import ContextualMemory
from pebbles.core.utils import Utils

matplotlib.use("Agg")

class GraphingCalculator():
    """The graphing calculator."""

    def __init__(self):
        self.plot_thread:threading.Thread = None
        self.plot_lock = threading.Lock()
        self.on_plot_ready = None
        self.is_plotting = False
        self.plot_params = {}


    def set_plot_params_and_plot(self, payload):
        """
        Set parameters for plotting.
        """
        self.start_plotting()


    def set_plot_ready_callback(self, cb):
        """
        Set a callback for when the plot pixbuf is ready and it's ready to draw.
        """
        self.on_plot_ready = cb

    def start_plotting(self):
        pass
