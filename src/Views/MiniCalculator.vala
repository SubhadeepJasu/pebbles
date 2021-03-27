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
 */

namespace Pebbles {
    public class MiniCalculator : Gtk.Window {
        public signal void mini_window_restore ();
        Pebbles.Settings settings;
        
        Gtk.Button close_button;
        Gtk.Entry  main_entry;
        Gtk.Button clear_button;
        Gtk.Button restore_button;
        StyledButton all_clear_button;
        StyledButton seven_button;
        StyledButton eight_button;
        StyledButton nine_button;
        StyledButton four_button;
        StyledButton five_button;
        StyledButton six_button;
        StyledButton one_button;
        StyledButton two_button;
        StyledButton three_button;
        StyledButton zero_button;
        StyledButton radix_button;
        StyledButton add_button;
        StyledButton subtract_button;
        StyledButton divide_button;
        StyledButton multiply_button;
        StyledButton result_button;
        StyledButton answer_button;

        string last_answer = "0";

        construct {
            settings = Pebbles.Settings.get_default ();
            settings.notify["use-dark-theme"].connect (() => {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.use_dark_theme;
            });
        }

        public MiniCalculator () {
            close_button = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.BUTTON);
            close_button.get_style_context ().add_class ("titlebutton");
            close_button.get_style_context ().add_class ("close");
            close_button.get_style_context ().remove_class ("image-button");
            close_button.margin = 3;
            close_button.margin_start = 0;

            main_entry = new Gtk.Entry ();
            main_entry.margin = 3;
            main_entry.placeholder_text = "0";
            main_entry.set_text ("0");
            main_entry.xalign = (float)1.0;
            clear_button = new Gtk.Button.from_icon_name ("edit-clear-symbolic", Gtk.IconSize.BUTTON);
            clear_button.sensitive = false;
            clear_button.get_style_context ().add_class ("titlebutton");
            clear_button.get_style_context ().add_class ("close");
            clear_button.get_style_context ().remove_class ("image-button");
            clear_button.margin = 3;
            clear_button.margin_end = 0;

            all_clear_button = new StyledButton ("AC", (_("All Clear")), {"Delete"});
            all_clear_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            seven_button = new StyledButton ("7");
            eight_button = new StyledButton ("8");
            nine_button = new StyledButton ("9");
            four_button = new StyledButton ("4");
            five_button = new StyledButton ("5");
            six_button = new StyledButton ("6");
            one_button = new StyledButton ("1");
            two_button = new StyledButton ("2");
            three_button = new StyledButton ("3");
            zero_button = new StyledButton ("0");
            radix_button = new StyledButton (".");
            add_button = new StyledButton ("+", "Add");
            add_button.get_style_context ().add_class ("h3");
            subtract_button = new StyledButton ("\xE2\x88\x92", (_("Subtract")));
            subtract_button.get_style_context ().add_class ("h3");
            divide_button = new StyledButton ("\xC3\xB7", (_("Divide")));
            divide_button.get_style_context ().add_class ("h3");
            multiply_button = new StyledButton ("\xC3\x97", (_("Multiply")));
            multiply_button.get_style_context ().add_class ("h3");
            result_button = new StyledButton ("=", (_("Result")), {"Return"});
            result_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            result_button.get_style_context ().add_class ("h3");
            answer_button = new StyledButton ("Ans", (_("Last Result")), {"F1"});

            var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            header_box.pack_start (close_button);
            header_box.pack_end (clear_button);
            header_box.pack_end (main_entry);
            
            var button_grid = new Gtk.Grid ();
            button_grid.attach (all_clear_button, 0, 0, 1, 1);
            button_grid.attach (divide_button, 1, 0, 1, 1);
            button_grid.attach (multiply_button, 2, 0, 1, 1);
            button_grid.attach (subtract_button, 3, 0, 1, 1);
            button_grid.attach (seven_button, 0, 1, 1, 1);
            button_grid.attach (eight_button, 1, 1, 1, 1);
            button_grid.attach (nine_button, 2, 1, 1, 1);
            button_grid.attach (add_button, 3, 1, 1, 3);
            button_grid.attach (four_button, 0, 2, 1, 1);
            button_grid.attach (five_button, 1, 2, 1, 1);
            button_grid.attach (six_button, 2, 2, 1, 1);
            button_grid.attach (one_button, 0, 3, 1, 1);
            button_grid.attach (two_button, 1, 3, 1, 1);
            button_grid.attach (three_button, 2, 3, 1, 1);
            button_grid.attach (zero_button, 0, 4, 1, 1);
            button_grid.attach (radix_button, 1, 4, 1, 1);
            button_grid.attach (answer_button, 2, 4, 1, 1);
            button_grid.attach (result_button, 3, 4, 1, 1);
            button_grid.column_homogeneous = true;
            button_grid.row_homogeneous = true;
            button_grid.margin = 4;
            button_grid.column_spacing = 4;
            button_grid.row_spacing = 4;

            this.resizable = false;
            this.set_titlebar (header_box);
            this.title = _("Pebbles Mini Mode");

            // Set up window attributes
            this.set_default_size (300, 200);
            this.set_size_request (300, 200);

            this.add (button_grid);
            this.set_keep_above (true);
            load_settings ();
            make_events ();
        }

        private void load_settings () {
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.use_dark_theme;
        }

        void make_events () {
            this.key_press_event.connect ((event) => {
                if (event.keyval == KeyboardHandler.KeyMap.NAV_LEFT 
                || event.keyval == KeyboardHandler.KeyMap.NAV_RIGHT
                || event.keyval == KeyboardHandler.KeyMap.SPACE_BAR
                || event.keyval == KeyboardHandler.KeyMap.PARENTHESIS_L
                || event.keyval == KeyboardHandler.KeyMap.PARENTHESIS_R) {
                    return false;
                }
                this.key_pressed (event);
                return true;
            });
            this.key_release_event.connect ((event) => {
                this.key_released ();
                return false;
            });
            close_button.clicked.connect (() => {
                this.close ();
            });

            divide_button.clicked.connect (() => {
                insert_text (" ÷ ");
            });
            seven_button.clicked.connect (() => {
                insert_text ("7");
            });
            eight_button.clicked.connect (() => {;
                insert_text ("8");
            });
            nine_button.clicked.connect (() => {;
                insert_text ("9");
            });
            multiply_button.clicked.connect (() => {;
                insert_text (" × ");
            });
            four_button.clicked.connect (() => {;
                insert_text ("4");
            });
            five_button.clicked.connect (() => {;
                insert_text ("5");
            });
            six_button.clicked.connect (() => {;
                insert_text ("6");
            });
            subtract_button.clicked.connect (() => {;
                insert_text (" - ");
            });
            one_button.clicked.connect (() => {;
                insert_text ("1");
            });
            two_button.clicked.connect (() => {;
                insert_text ("2");
            });
            three_button.clicked.connect (() => {;
                insert_text ("3");
            });
            add_button.clicked.connect (() => {;
                insert_text (" + ");
            });
            zero_button.clicked.connect (() => {;
                insert_text ("0");
            });
            radix_button.clicked.connect (() => {;
                insert_text (".");
            });
            clear_button.clicked.connect (() => {
                main_entry.backspace ();
                if (main_entry.get_text () == "") {
                    main_entry.set_text ("0");
                    main_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                }
            });
            all_clear_button.clicked.connect (() => {
                main_entry.set_text ("0");
                main_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
            });
            answer_button.clicked.connect (() => {
                insert_text ("ans");
            });
            result_button.clicked.connect (() => {
                get_answer_evaluate ();
                if (main_entry.get_text ().length == 0 && main_entry.get_text () != "0") {
                    main_entry.set_text ("0");
                }
            });

            main_entry.changed.connect (() => {
                if (main_entry.get_text () == "0" || main_entry.get_text () == "")
                    clear_button.sensitive = false;
                else
                    clear_button.sensitive = true;
            });
        }

        private void get_answer_evaluate () {
            var sci_calc = new ScientificCalculator ();
            string result = "";
            Settings accuracy_settings = Settings.get_default ();
            //if (this.sci_view.window.history_stack.length () > 0) {
                //unowned List<string>? last_answer = this.sci_view.window.history_stack.last ();
            //    result = sci_calc.get_result (main_entry.get_text ().replace ("ans", "2"), GlobalAngleUnit.DEG, accuracy_settings.decimal_places);
            //}
            //else {
                result = sci_calc.get_result (main_entry.get_text ().replace ("ans", last_answer).replace (Utils.get_local_separator_symbol (), ""), GlobalAngleUnit.DEG, accuracy_settings.decimal_places);
            //}
            main_entry.set_text (Utils.format_result(result));
            if (result != "E") {
                last_answer = result.replace (Utils.get_local_separator_symbol (), "");
            }
            main_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
        }

        private void key_pressed (Gdk.EventKey event) {
            switch (event.keyval) {
                case KeyboardHandler.KeyMap.BACKSPACE:
                main_entry.backspace ();
                if (main_entry.get_text () == "") {
                    main_entry.set_text ("0");
                    main_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                }
                break;
                case KeyboardHandler.KeyMap.NUMPAD_7:
                case KeyboardHandler.KeyMap.KEYPAD_7:
                this.insert_text ("7");
                seven_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_8:
                case KeyboardHandler.KeyMap.KEYPAD_8:
                this.insert_text ("8");
                eight_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_9:
                case KeyboardHandler.KeyMap.KEYPAD_9:
                this.insert_text ("9");
                nine_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_4:
                case KeyboardHandler.KeyMap.KEYPAD_4:
                this.insert_text ("4");
                four_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_5:
                case KeyboardHandler.KeyMap.KEYPAD_5:
                this.insert_text ("5");
                five_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_6:
                case KeyboardHandler.KeyMap.KEYPAD_6:
                this.insert_text ("6");
                six_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_1:
                case KeyboardHandler.KeyMap.KEYPAD_1:
                this.insert_text ("1");
                one_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_2:
                case KeyboardHandler.KeyMap.KEYPAD_2:
                this.insert_text ("2");
                two_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_3:
                case KeyboardHandler.KeyMap.KEYPAD_3:
                this.insert_text ("3");
                three_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_0:
                case KeyboardHandler.KeyMap.KEYPAD_0:
                if (main_entry.get_text () != "0") {
                    this.insert_text ("0");
                }
                zero_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_RADIX:
                case KeyboardHandler.KeyMap.KEYPAD_RADIX:
                this.insert_text (".");
                radix_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;

                case KeyboardHandler.KeyMap.PLUS_NUMPAD:
                case KeyboardHandler.KeyMap.PLUS_KEYPAD:
                this.insert_text (" + ");
                add_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.MINUS_NUMPAD:
                case KeyboardHandler.KeyMap.MINUS_KEYPAD:
                this.insert_text (" - ");
                subtract_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.SLASH_NUMPAD:
                case KeyboardHandler.KeyMap.SLASH_KEYPAD:
                this.insert_text (" ÷ ");
                divide_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.STAR_NUMPAD:
                case KeyboardHandler.KeyMap.STAR_KEYPAD:
                this.insert_text (" × ");
                multiply_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.RETURN:
                case KeyboardHandler.KeyMap.RETURN_NUMPAD:
                get_answer_evaluate ();
                if (main_entry.get_text ().length == 0 && main_entry.get_text () != "0") {
                    main_entry.set_text ("0");
                }
                result_button.get_style_context ().add_class ("Pebbles_Buttons_Suggested_Pressed");
                break;
                case KeyboardHandler.KeyMap.DELETE:
                main_entry.set_text ("0");
                main_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                all_clear_button.get_style_context ().add_class ("Pebbles_Buttons_Destructive_Pressed");
                break;
                case KeyboardHandler.KeyMap.F6:
                insert_text ("ans");
                answer_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
            }
        }

        private void insert_text (string text) {
            if (main_entry.get_text () == "0") {
                main_entry.set_text ("");
            }
            main_entry.grab_focus_without_selecting ();
            main_entry.insert_at_cursor (text);
        }

        private void key_released () {
            seven_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            eight_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            nine_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            four_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            five_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            six_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            one_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            two_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            three_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            zero_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            radix_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            answer_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");

            add_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            subtract_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            divide_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            multiply_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");

            result_button.get_style_context ().remove_class ("Pebbles_Buttons_Suggested_Pressed");
            all_clear_button.get_style_context ().remove_class ("Pebbles_Buttons_Destructive_Pressed");
        }
    }
}
