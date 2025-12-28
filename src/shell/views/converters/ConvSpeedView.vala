// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/conv_speed_view.ui")]
    public class ConvSpeedView : ConverterView {
        construct {
            conversion_factors = {
                100.0,
                1.0,
                3.6,
                3.28084,
                2.23694,
                1.94384,
                1.0 / 343.0,
            };


            string[] units = {
                (_("Centimetre per second")),
                (_("Metre per second")),
                (_("Kilometre per hour")),
                (_("Foot per second")),
                (_("Miles per hour")),
                (_("Knot")),
                (_("Mach")),
            };

            unit_options = new Gtk.StringList (units);
        }
    }
}
