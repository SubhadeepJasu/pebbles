/*-
 * Copyright (c) 2017-2020 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright (c) 2017-2020 Saunak Biswas <saunakbis97@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 *              Saunak Biswas  <saunakbis97@gmail.com>
 */


namespace Pebbles { 
    public class PreferencesOverlay : Gtk.Window {
        Pebbles.Settings settings;
        Gtk.SpinButton precision_entry;
        Gtk.Entry forex_api_key;
        Gtk.LinkButton forex_api_link;
        Gtk.ComboBoxText constants_select_1;
        Gtk.ComboBoxText constants_select_2;
        Gtk.Scale accuracy_scale;

        public signal void update_settings ();

        public PreferencesOverlay () {
            settings = Pebbles.Settings.get_default ();
            var main_grid = new Gtk.Grid ();
            main_grid.halign = Gtk.Align.CENTER;
            main_grid.row_spacing = 8;
            

            var precision_label = new Gtk.Label (_("Number of decimal places:"));
            precision_label.get_style_context ().add_class ("h4");
            precision_label.halign = Gtk.Align.START;
            precision_entry = new Gtk.SpinButton.with_range (1, 9, 1);
            precision_entry.max_length = 1;

            var accuracy_label = new Gtk.Label (_("Integral Calculus Accuracy"));
            accuracy_label.halign = Gtk.Align.START;
            accuracy_label.get_style_context ().add_class ("h4");
            accuracy_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 500, 100000, 100);
            accuracy_scale.set_draw_value (false);
            accuracy_scale.add_mark (500, Gtk.PositionType.TOP, _("Fast"));
            accuracy_scale.add_mark (100000, Gtk.PositionType.TOP, _("Accurate"));

            var constant_button_label = new Gtk.Label (_("Scientific constants button:"));
            constant_button_label.get_style_context ().add_class ("h4");
            constant_button_label.halign = Gtk.Align.START;
            var constant_label1 = new Gtk.Label (_("Constant 1"));
            constant_label1.halign = Gtk.Align.START;
            constants_select_1 = new Gtk.ComboBoxText ();
            constants_select_1.append_text (_("Euler's constant (exponential)") + "  \"e\"");
            constants_select_1.append_text (_("Archimedes' constant (pi)") + "  \"\xCF\x80\"");
            constants_select_1.append_text (_("Parabolic constant") + "  \"\xF0\x9D\x91\x83\"");
            constants_select_1.append_text (_("Golden ratio (phi)") + "  \"\xCF\x86\"");
            constants_select_1.append_text (_("Euler–Mascheroni constant (gamma)") + "  \"\xF0\x9D\x9B\xBE\"");
            constants_select_1.append_text (_("Conway's constant (lambda)") + "  \"\xCE\xBB\"");
            constants_select_1.append_text (_("Khinchin's constant") + "  \"K\"");
            constants_select_1.append_text (_("The Feigenbaum constant alpha") + "  \"\xCE\xB1\"");
            constants_select_1.append_text (_("The Feigenbaum constant delta") + "  \"\xCE\xB4\"");
            constants_select_1.append_text (_("Apery's constant") + "  \"\xF0\x9D\x9B\x87(3)\"");

            var constant_label2 = new Gtk.Label (_("Constant 2 (Hold Shift)"));
            constant_label2.halign = Gtk.Align.START;
            constants_select_2 = new Gtk.ComboBoxText ();
            constants_select_2.append_text (_("Euler's constant (exponential)") + "  \"e\"");
            constants_select_2.append_text (_("Archimedes' constant (pi)") + "  \"\xCF\x80\"");
            constants_select_2.append_text (_("Parabolic constant") + "  \"\xF0\x9D\x91\x83\"");
            constants_select_2.append_text (_("Golden ratio (phi)") + "  \"\xCF\x86\"");
            constants_select_2.append_text (_("Euler–Mascheroni constant (gamma)") + "  \"\xF0\x9D\x9B\xBE\"");
            constants_select_2.append_text (_("Conway's constant (lambda)") + "  \"\xCE\xBB\"");
            constants_select_2.append_text (_("Khinchin's constant") + "  \"K\"");
            constants_select_2.append_text (_("The Feigenbaum constant alpha") + "  \"\xCE\xB1\"");
            constants_select_2.append_text (_("The Feigenbaum constant delta") + "  \"\xCE\xB4\"");
            constants_select_2.append_text (_("Apery's constant") + "  \"\xF0\x9D\x9B\x87(3)\"");

            this.delete_event.connect (() => {
                save_settings ();
                return false;
            });

            main_grid.attach (precision_label, 0, 0, 1, 1);
            main_grid.attach (precision_entry, 0, 1, 1, 1);
            main_grid.attach (accuracy_label,  0, 2, 1, 1);
            main_grid.attach (accuracy_scale,  0, 3, 1, 1);
            main_grid.attach (constant_button_label, 0, 4, 1, 1);
            main_grid.attach (constant_label1, 0, 5, 1, 1);
            main_grid.attach (constants_select_1, 0, 6, 1, 1);
            main_grid.attach (constant_label2, 0, 7, 1, 1);
            main_grid.attach (constants_select_2, 0, 8, 1, 1);

            var forex_label = new Gtk.Label (_("Currency Converter API Key"));
            forex_label.halign = Gtk.Align.START;
            forex_label.get_style_context ().add_class ("h4");
            forex_api_link = new Gtk.LinkButton.with_label ("https://free.currencyconverterapi.com/", _("Get your own API key"));
            forex_api_key = new Gtk.Entry ();
            forex_api_key.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY,"edit-undo-symbolic");
            forex_api_key.placeholder_text = "03eb97e97cbf3fa3e228";
            
            main_grid.attach (forex_label, 0, 9, 1, 1);
            main_grid.attach (forex_api_key, 0, 10, 1, 1);
            main_grid.attach (forex_api_link, 0, 11, 1, 1);

            this.add (main_grid);

            var headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.set_show_close_button (true);
            headerbar.title = _("Preferences");

            headerbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            set_titlebar (headerbar);
            get_style_context ().add_class ("rounded");

            // Set up window attributes
            this.resizable = false;
            this.set_default_size (460, 520);
            this.set_size_request (460, 520);

            //this.add (scrolled_window);

            this.destroy_with_parent = true;
            this.modal = true;
            show_all ();
            make_events ();
            load_settings ();
        }

        private void save_settings () {
            if (precision_entry.get_value_as_int () != 0) {
                settings.decimal_places = precision_entry.get_value_as_int ();
            }

            settings.constant_key_value1 = (ConstantKeyIndex)constants_select_1.get_active ();
            settings.constant_key_value2 = (ConstantKeyIndex)constants_select_2.get_active ();
            if (forex_api_key.get_text () != "")
                settings.forex_api_key = forex_api_key.get_text ();
            else
                settings.forex_api_key = "03eb97e97cbf3fa3e228";
            
            settings.integration_accuracy = (int)(accuracy_scale.get_value ());
            this.update_settings ();
        }

        private void load_settings () {
            precision_entry.set_value ((double)settings.decimal_places);
            load_constant_button_settings ();
            forex_api_key.set_text (settings.forex_api_key);
            accuracy_scale.set_value ((double)settings.integration_accuracy);
        }

        private void load_constant_button_settings () {
            switch (settings.constant_key_value1) {
                case ConstantKeyIndex.ARCHIMEDES:
                constants_select_1.set_active(1);
                break;
                case ConstantKeyIndex.PARABOLIC:
                constants_select_1.set_active(2);
                break;
                case ConstantKeyIndex.GOLDEN_RATIO:
                constants_select_1.set_active(3);
                break;
                case ConstantKeyIndex.EULER_MASCH:
                constants_select_1.set_active(4);
                break;
                case ConstantKeyIndex.CONWAY:
                constants_select_1.set_active(5);
                break;
                case ConstantKeyIndex.KHINCHIN:
                constants_select_1.set_active(6);
                break;
                case ConstantKeyIndex.FEIGEN_ALPHA:
                constants_select_1.set_active(7);
                break;
                case ConstantKeyIndex.FEIGEN_DELTA:
                constants_select_1.set_active(8);
                break;
                case ConstantKeyIndex.APERY:
                constants_select_1.set_active(9);
                break;
                default:
                constants_select_1.set_active(0);
                break;
            }
            switch (settings.constant_key_value2) {
                case ConstantKeyIndex.ARCHIMEDES:
                constants_select_2.set_active(1);
                break;
                case ConstantKeyIndex.PARABOLIC:
                constants_select_2.set_active(2);
                break;
                case ConstantKeyIndex.GOLDEN_RATIO:
                constants_select_2.set_active(3);
                break;
                case ConstantKeyIndex.EULER_MASCH:
                constants_select_2.set_active(4);
                break;
                case ConstantKeyIndex.CONWAY:
                constants_select_2.set_active(5);
                break;
                case ConstantKeyIndex.KHINCHIN:
                constants_select_2.set_active(6);
                break;
                case ConstantKeyIndex.FEIGEN_ALPHA:
                constants_select_2.set_active(7);
                break;
                case ConstantKeyIndex.FEIGEN_DELTA:
                constants_select_2.set_active(8);
                break;
                case ConstantKeyIndex.APERY:
                constants_select_2.set_active(9);
                break;
                default:
                constants_select_2.set_active(0);
                break;
            }
        }
        private void make_events () {
            this.key_release_event.connect ((event) => {
                if (event.keyval == KeyboardHandler.KeyMap.ESCAPE) {
                    this.hide ();
                }
                return false;
            });
            this.forex_api_key.icon_release.connect ((pos, event) => {
                settings.forex_api_key = "03eb97e97cbf3fa3e228";
                this.forex_api_key.set_text ("03eb97e97cbf3fa3e228");
            });
        }
    }
}
