
// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/preferences_dialog.ui")]
    public class PreferencesDialog : Adw.PreferencesDialog {
        protected Gtk.StringList constant_button_model { get; private set; }

        // Settings
        public Pebbles.Settings settings { get; set construct; }

        [GtkChild]
        private unowned Gtk.Scale integration_resolution_scale;
        [GtkChild]
        private unowned Gtk.Scale derivative_accuracy_scale;
        [GtkChild]
        private unowned Adw.EntryRow api_key_entry;

        private bool loaded = false;

        construct {
            settings = Pebbles.Settings.get_default ();

            // TRANSLATORS: The left quotation mark symbol
            var laquo = _("“");
            // TRANSLATORS: The right quotation mark symbol
            var raquo = _("”");

            string[] constants_array = {
                _("Euler's constant (exponential)") + "  " + laquo + "e" + raquo,
                _("Archimedes' constant (pi)") + "  " + laquo + "\xCF\x80" + raquo,
                _("Golden ratio (phi)") + "  " + laquo + "\xCF\x86" + raquo,
                _("Imaginary number") + "  " + laquo + "j" + raquo,
                _("Euler–Mascheroni constant (gamma)") + "  " + laquo + "\xF0\x9D\x9B\xBE" + raquo,
                _("Conway's constant (lambda)") + "  " + laquo + "\xCE\xBB" + raquo,
                _("Khinchin's constant") + "  " + laquo + "K" + raquo,
                _("The Feigenbaum constant alpha") + "  " + laquo + "\xCE\xB1" + raquo,
                _("The Feigenbaum constant delta") + "  " + laquo + "\xCE\xB4" + raquo,
                _("Apery's constant") + "  " + laquo + "\xF0\x9D\x9B\x87(3)" + raquo
            };

            constant_button_model = new Gtk.StringList (constants_array);

            realize.connect (load_settings);
            closed.connect (() => {
                loaded = false;
                save_settings ();
            });
            close_attempt.connect (() => {
                save_settings ();
            });
        }

        [GtkCallback]
        protected void load_session_notify_active_cb (Object obj, ParamSpec params) {
            settings.load_last_session = (obj as Adw.SwitchRow)?.active;
        }

        [GtkCallback]
        protected void result_flow_notify_active_cb (Object obj, ParamSpec params) {
            settings.result_flow = (obj as Adw.SwitchRow)?.active;
        }

        [GtkCallback]
        protected void precision_notify_active_cb (Object obj, ParamSpec params) {
            settings.decimal_places = (uint) ((obj as Gtk.SpinButton)?.value);
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
                derivative_accuracy_scale.set_value (settings.derivative_accuracy);
                loaded = true;
                return false;
            });

        }

        private void save_settings () {
            settings.integration_resolution = (uint) integration_resolution_scale.get_value ();
            settings.derivative_accuracy = (uint) derivative_accuracy_scale.get_value ();
            settings.forex_api_key = api_key_entry.text;
        }

        [GtkCallback]
        protected void on_open_api_homepage_link () {
            try {
                AppInfo.launch_default_for_uri ("https://openexchangerates.org/signup", null);
            } catch (Error e) {
                print ("WARNING: Failed to open link");
            }
        }
    }
}
