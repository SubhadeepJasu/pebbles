// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/conv_angle_view.ui")]
    public class ConvAngleView : ConverterView {
        construct {
            conversion_factors = {
                1.0,
                (Math.PI / 180.0),
                (1.111111111),
                ((Math.PI * 1000.0) / 180.0),
                3600.0,
                60.0,
            };


            string[] units = {
                (_("Degree")),
                (_("Radian")),
                (_("Gradian")),
                (_("Milliradian")),
                (_("Second of arc")),
                (_("Minute of arc")),
            };

            unit_options = new Gtk.StringList (units);
        }
    }
}
