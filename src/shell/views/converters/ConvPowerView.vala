// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/conv_power_view.ui")]
    public class ConvPowerView : ConverterView {
        construct {
            conversion_factors = {
                1.0,
                0.001,
                0.00135962,
                0.00134102,
                44.25,
                3.412142,
            };


            string[] units = {
                (_("Watt")),
                (_("Kilowatt")),
                (_("Metric horsepower")),
                (_("Mechanical horsepower")),
                (_("Foot-pound / minute")),
                (_("BTU / hour")),
            };

            unit_options = new Gtk.StringList (units);
        }
    }
}
