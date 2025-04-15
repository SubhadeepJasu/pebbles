namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/conv_volume_view.ui")]
    public class ConvVolumeView : ConverterView {
        construct {
            conversion_factors = {
                1000000.0,
                1000000.0,
                1000.0,
                1.0,
                202884.0,
                67628.0,
                33814.0,
                4166.667,
                2113.376,
                1056.688,
                264.172,
                168936.313,
                56312.104,
                35195.08,
                3519.508,
                1759.754,
                879.877,
                219.969,
                61023.744,
                35.3147,
                1.30795,
            };


            string[] units = {
                (_("Millilitre")),
                (_("Cubic centimetre")),
                (_("Litre")),
                (_("Cubic metre")),
                (_("US teaspoon")),
                (_("US tablespoon")),
                (_("US fluid ounce")),
                (_("US legal cup")),
                (_("US pint")),
                (_("US quart")),
                (_("US gallon")),
                (_("Imperial teaspoon")),
                (_("Imperial tablespoon")),
                (_("Imperial fluid ounce")),
                (_("Imperial cup")),
                (_("Imperial pint")),
                (_("Imperial quart")),
                (_("Imperial gallon")),
                (_("Cubic inch")),
                (_("Cubic foot")),
                (_("Cubic yard")),
            };

            unit_options = new Gtk.StringList (units);
        }
    }
}
