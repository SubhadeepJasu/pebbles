namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/conv_data_view.ui")]
    public class ConvDataView : ConverterView {
        construct {
            conversion_factors = {
                8000000,
                8000,
                7812.5,
                8,
                7.62939,
                0.008,
                1.0 / 134.218,
                1.0 / 125000.0,
                1.0 / 137438.953,
                1.0 / 125000000.0,
                1.0 / 140700000.0,
                1000000.0,
                1000.0,
                976.563,
                1.0,
                1.0 / 1.049,
                0.001,
                1 / 1073.742,
                0.000001,
                1.0 / 1100000.0,
                0.000000001,
                1.0 / 1126000000.0,
            };


            string[] units = {
                (_("Bit")),
                (_("Kilobit")),
                (_("Kibibit")),
                (_("Megabit")),
                (_("Mebibit")),
                (_("Gigabit")),
                (_("Gibibit")),
                (_("Terabit")),
                (_("Tebibit")),
                (_("Petabit")),
                (_("Pebibit")),
                (_("Byte")),
                (_("Kilobyte")),
                (_("Kibibyte")),
                (_("Megabyte")),
                (_("Mebibyte")),
                (_("Gigabyte")),
                (_("Gibibyte")),
                (_("Terabyte")),
                (_("Tebibyte")),
                (_("Petabyte")),
                (_("Pebibyte")),
            };

            unit_options = new Gtk.StringList (units);
        }
    }
}
