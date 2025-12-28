// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/conv_temp_view.ui")]
    public class ConvTempView : ConverterView {
        construct {
            conversion_factors = {
                1,
                1,
                1
            };


            string[] units = {
                (_("Celsius")),
                (_("Fahrenheit")),
                (_("Kelvin")),
            };

            unit_options = new Gtk.StringList (units);
        }
    }
}
