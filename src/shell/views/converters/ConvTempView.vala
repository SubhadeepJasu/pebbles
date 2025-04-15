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
