namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/conv_energy_view.ui")]
    public class ConvEnergyView : ConverterView {
        construct {
            conversion_factors = {
                1.0,
                0.001,
                0.239006,
                0.000239006,
                1.0 / 3600.0,
                0.000000278,
                //6242000000000000000,  Future Support
                0.000947817,
                1.0 / 105500000.0,
                0.737562,
            };


            string[] units = {
                (_("Joule")),
                (_("Kilojoule")),
                (_("Gram calorie")),
                (_("Kilocalorie")),
                (_("Watt hour")),
                (_("Kilowatt hour")),
                //"Electronvolt",       Future Support
                (_("British thermal unit")),
                (_("US therm")),
                (_("Foot-pound")),
            };

            unit_options = new Gtk.StringList (units);
        }
    }
}
