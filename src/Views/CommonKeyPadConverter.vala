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
    public class CommonKeyPadConverter : Gtk.Grid {

        public string val {
            get {return val;}
            set {send_button_press (val);}
        }

        Gtk.Button   del_button;
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
        StyledButton decimal_button;

        public signal void button_clicked (string input_text);
    
        construct {
            // Make the buttons
            del_button = new Gtk.Button.from_icon_name ("edit-clear-symbolic", Gtk.IconSize.BUTTON);
            del_button.set_tooltip_text (_("Backspace"));
            del_button.get_style_context ().remove_class ("image-button");
            all_clear_button = new StyledButton ("AC", (_("Clear Entry")));
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
            decimal_button = new StyledButton (".");

            // Arange the buttons
            attach (all_clear_button, 0, 0, 1, 1);
            attach (del_button, 1, 0, 1, 1);
            attach (seven_button, 0, 1, 1, 1);
            attach (eight_button, 1, 1, 1, 1);
            attach (nine_button, 2, 1, 1, 1);
            attach (four_button, 0, 2, 1, 1);
            attach (five_button, 1, 2, 1, 1);
            attach (six_button, 2, 2, 1, 1);
            attach (one_button, 0, 3, 1, 1);
            attach (two_button, 1, 3, 1, 1);
            attach (three_button, 2, 3, 1, 1);
            attach (zero_button, 0, 4, 1, 1);
            attach (decimal_button, 1, 4, 1, 1);
            set_column_homogeneous (true);
            set_row_homogeneous (true);
            
            width_request = 250;
            height_request = 210;
            margin_start = 8;
            margin_end = 8;
            column_spacing = 8;
            row_spacing = 8;
            
            // Handle events
            del_button.clicked.connect (() => send_button_press ("del"));
            all_clear_button.clicked.connect (() => send_button_press ("C"));
            seven_button.clicked.connect (() => send_button_press ("7"));
            eight_button.clicked.connect (() => send_button_press ("8"));
            nine_button.clicked.connect (() => send_button_press ("9"));
            four_button.clicked.connect (() => send_button_press ("4"));
            five_button.clicked.connect (() => send_button_press ("5"));
            six_button.clicked.connect (() => send_button_press ("6"));
            one_button.clicked.connect (() => send_button_press ("1"));
            two_button.clicked.connect (() => send_button_press ("2"));
            three_button.clicked.connect (() => send_button_press ("3"));
            zero_button.clicked.connect (() => send_button_press ("0"));
            decimal_button.clicked.connect (() => send_button_press ("."));
        }
        private void send_button_press (string label) {
            button_clicked (label);
        }
        public void key_pressed (Gdk.EventKey event) {
            switch (event.keyval) {
                case KeyboardHandler.KeyMap.BACKSPACE:
                if (del_button.get_sensitive ()) {
                    send_button_press ("del");
                    del_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                }
                break;
                case KeyboardHandler.KeyMap.NUMPAD_7: // 7 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_7:
                send_button_press ("7");
                seven_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_8: // 8 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_8:
                send_button_press ("8");
                eight_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_9: // 9 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_9:
                send_button_press ("9");
                nine_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_4: // 4 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_4:
                send_button_press ("4");
                four_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_5: // 5 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_5:
                send_button_press ("5");
                five_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_6: // 6 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_6:
                send_button_press ("6");
                six_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_1: // 1 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_1:
                send_button_press ("1");
                one_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_2: // 2 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_2:
                send_button_press ("2");
                two_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_3: // 3 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_3:
                send_button_press ("3");
                three_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_0: // 0 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_0:
                send_button_press ("0");
                zero_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_RADIX:
                case KeyboardHandler.KeyMap.KEYPAD_RADIX:
                send_button_press (".");
                decimal_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.DELETE:
                send_button_press ("C");
                all_clear_button.get_style_context ().add_class ("Pebbles_Buttons_Destructive_Pressed");
                break;
            }
        }
        public void key_released () {
            del_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
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
            decimal_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            all_clear_button.get_style_context ().remove_class ("Pebbles_Buttons_Destructive_Pressed");
        }
    }
}
