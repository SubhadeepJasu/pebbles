namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/conv_pressure_view.ui")]
    public class ConvPressureView : ConverterView {
        construct {
            conversion_factors = {
                0.000009869,
                0.00001,
                0.00750062,
                1.0,
                0.000145038,
                0.00750062,
            };


            string[] units = {
                (_("Atmosphere")),
                (_("Bar")),
                (_("Millimetre of mercury")),
                (_("Pascal")),
                (_("Pound-force / sq-inch")),
                (_("Torr")),
            };

            unit_options = new Gtk.StringList (units);
        }
    }
}
