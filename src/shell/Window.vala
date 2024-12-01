// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    public class Window : Gtk.ApplicationWindow {
        construct {
            default_width = 800;
            default_height = 600;
            title = "Pebbles";
        }
    }
}