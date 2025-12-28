// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/conv_mass_view.ui")]
    public class ConvMassView : ConverterView {
        construct {
            conversion_factors = {
                1000000.0,
                1000.0,
                1.0,
                0.001,
                0.000001,
                (1.0 / 907184.74),
                1.0 / 1016000.0,
                (1.0 / 28.35),
                (1.0 / 453.592),
                (1.0 / 6350.293),
            };


            string[] units = {
                (_("Microgram")),
                (_("Milligram")),
                (_("Gram")),
                (_("Kilogram")),
                (_("Tonne")),
                (_("US ton")),
                (_("Imperial Ton")),
                (_("Ounce")),
                (_("Pound")),
                (_("Stone")),
            };

            unit_options = new Gtk.StringList (units);
        }
    }
}
