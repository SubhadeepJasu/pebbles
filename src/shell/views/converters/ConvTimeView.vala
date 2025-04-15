namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/conv_time_view.ui")]
    public class ConvTimeView : ConverterView {
        construct {
            conversion_factors = {
                3600000000.0,
                3600000.0,
                3600.0,
                60.0,
                1.0,
                0.0416667,
                0.00595238,
                0.00136986,
                0.000114155,
                0.000011416,
                0.000001142,
            };


            string[] units = {
                (_("Microsecond")),
                (_("Millisecond")),
                (_("Second")),
                (_("Minute")),
                (_("Hour")),
                (_("Day")),
                (_("Week")),
                (_("Month")),
                (_("Year")),
                (_("Decade")),
                (_("Century")),
            };

            unit_options = new Gtk.StringList (units);
        }
    }
}
