# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

"""Main Application"""

from gi.repository import Gio, Pebbles
from pebbles.window import PythonWindow

class PythonApplication(Pebbles.Application):
    """The main application singleton class."""

    __gtype_name__ = "PebblesPythonApplication"


    def __init__(self, application_id, **kwargs):
        super().__init__(
            application_id=application_id,
            flags=Gio.ApplicationFlags.HANDLES_OPEN,
            **kwargs,
        )
        self.connect("create_window_request", PythonApplication._on_create_window_request)


    def setup(self):
        import logging
        from gettext import gettext as _

        settings = Gio.Settings(self.props.application_id)
        self.props.settings = settings


    @staticmethod
    def _on_create_window_request(self) -> Pebbles.Window:
        print("Creating Window")
        return PythonWindow(self)
