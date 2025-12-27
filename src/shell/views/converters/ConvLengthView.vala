// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/conv_length_view.ui")]
    public class ConvLengthView : ConverterView {
        construct {
            conversion_factors = {
                1000000000.0, // Nano
                1000000.0,    // Micron
                1000.0,       // Milli
                100.0,        // Centi
                1.0,          // Metre
                0.001,        // Kilo
                39.3701,      // Inch
                3.28084,      // Foot
                1.09361,      // Yard
                0.000621371,  // Mile
                0.000539957,  // Nautical
            };


            string[] units = {
                (_("Nanometre")),
                (_("Micron")),
                (_("Millimetre")),
                (_("Centimetre")),
                (_("Metre")),
                (_("Kilometre")),
                (_("Inch")),
                (_("Foot")),
                (_("Yard")),
                (_("Mile")),
                (_("Nautical Mile")),
            };

            unit_options = new Gtk.StringList (units);
        }
    }
}
