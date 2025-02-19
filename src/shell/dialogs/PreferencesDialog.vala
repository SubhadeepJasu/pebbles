namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/preferences_dialog.ui")]
    public class PreferencesDialog : Adw.PreferencesDialog {
        protected Gtk.StringList constant_button_model { get; private set; }
        protected List<string> constants_list;

        // Settings
        public Pebbles.Settings settings { get; set construct; }

        [GtkChild]
        private unowned Gtk.Scale integration_resolution_scale;

        private bool loaded = false;

        construct {
            settings = Pebbles.Settings.get_default ();

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

            realize.connect (load_settings);
            closed.connect (() => {
                loaded = false;
            });
        }

        [GtkCallback]
        protected void load_session_notify_active_cb (Object obj, ParamSpec params) {
            settings.load_last_session = (obj as Adw.SwitchRow)?.active;
        }

        [GtkCallback]
        protected void precision_notify_active_cb (Object obj, ParamSpec params) {
            settings.decimal_places = (uint) ((obj as Gtk.SpinButton)?.value);
        }

        [GtkCallback]
        protected void forex_api_key_cb (Object obj, ParamSpec params) {
            settings.forex_api_key = (obj as Adw.EntryRow)?.text;
        }

        [GtkCallback]
        protected void constant_button_1_cb (Object obj, ParamSpec params) {
            if (loaded)
                settings.constant_key_value1 = uint_to_constant_key ((obj as Adw.ComboRow)?.selected);
        }

        [GtkCallback]
        protected void constant_button_2_cb (Object obj, ParamSpec params) {
            if (loaded)
                settings.constant_key_value2 = uint_to_constant_key ((obj as Adw.ComboRow)?.selected);
        }

        private ConstantKeyIndex uint_to_constant_key (uint index) {
            switch (index) {
                case 0:
                default:
                    return EULER;
                case 1:
                    return ARCHIMEDES;
                case 2:
                    return GOLDEN_RATIO;
                case 3:
                    return IMAGINARY;
                case 4:
                    return EULER_MASCH;
                case 5:
                    return CONWAY;
                case 6:
                    return KHINCHIN;
                case 7:
                    return FEIGEN_ALPHA;
                case 8:
                    return FEIGEN_DELTA;
                case 9:
                    return APERY;

            }

        }

        private void load_settings () {
            Idle.add (() => {
                integration_resolution_scale.set_value (settings.integration_resolution);
                loaded = true;
                return false;
            });

        }
    }
}
