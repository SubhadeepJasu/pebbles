// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/conv_area_view.ui")]
    public class ConvAreaView : ConverterView {
        construct {
            conversion_factors = {
                1000000.0,    // Sqaure millimetre
                10000.0,      // Square centimetre
                1.0,          // Square metre
                0.000001,     // Square kilometre
                1550.0,       // Square inch
                10.7639,      // Square foot
                1.19599,      // Square yard
                0.0001,       // Hectare
                0.000247105,  // Acre
                0.000000386,  // Square mile
            };


            string[] units = {
                (_("Square millimetre")),
                (_("Square centimetre")),
                (_("Square metre")),
                (_("Square kilometre")),
                (_("Square inch")),
                (_("Square foot")),
                (_("Square yard")),
                (_("Hectare")),
                (_("Acre")),
                (_("Square mile")),
            };

            unit_options = new Gtk.StringList (units);
        }
    }
}
