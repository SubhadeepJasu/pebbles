namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/preferences_dialog.ui")]
    public class PreferencesDialog : Adw.PreferencesDialog {
        protected Gtk.StringList constant_button_model { get; private set; }
        protected List<string> constants_list;

        construct {
            // TRANSLATORS: The left quotation mark symbol
            var laquo = _("“");
            // TRANSLATORS: The right quotation mark symbol
            var raquo = _("”");

            constants_list = new List<string> ();
            constants_list.append (_("Euler's constant (exponential)") + "  " + laquo + "e" + raquo);
            constants_list.append (_("Archimedes' constant (pi)") + "  " + laquo + "\xCF\x80" + raquo);
            constants_list.append (_("Golden ratio (phi)") + "  " + laquo + "\xCF\x86" + raquo);
            constants_list.append (_("Imaginary number") + "  " + laquo + "j" + raquo);
            constants_list.append (_("Euler–Mascheroni constant (gamma)") + "  " + laquo + "\xF0\x9D\x9B\xBE" + raquo);
            constants_list.append (_("Conway's constant (lambda)") + "  " + laquo + "\xCE\xBB" + raquo);
            constants_list.append (_("Khinchin's constant") + "  " + laquo + "K" + raquo);
            constants_list.append (_("The Feigenbaum constant alpha") + "  " + laquo + "\xCE\xB1" + raquo);
            constants_list.append (_("The Feigenbaum constant delta") + "  " + laquo + "\xCE\xB4" + raquo);
            constants_list.append (_("Apery's constant") + "  " + laquo + "\xF0\x9D\x9B\x87(3)" + raquo);
            var constants_array = new string[constants_list.length ()];
            for (uint8 i = 0; i < constants_array.length; i++) {
                constants_array[i] = constants_list.nth_data (i);
            }

            constant_button_model = new Gtk.StringList (constants_array);
        }
    }
}
