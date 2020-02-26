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
    public class ConvPressView : Gtk.Grid {
        private CommonKeyPadConverter keypad;

        public Gtk.Entry from_entry;
        public Gtk.Entry to_entry;
        private int from_to = 0;
        private bool allow_change = true;
        private Converter conv;
        private Gtk.ComboBoxText from_unit;
        private Gtk.ComboBoxText to_unit;
        private Gtk.Button interchange_button;

        private const double[] unit_multipliers = {
            0.000009869,
            0.00001,
            0.00750062,
            1,
            0.000145038,
            0.00750062,
        };

        private const string[] units = {
            "Atmosphere",
            "Bar",
            "Millimetre of mercury",
            "Pascal",
            "Pound-force / sq-inch",
            "Torr",
        };

        construct {
            conv = new Converter (unit_multipliers);
            keypad = new CommonKeyPadConverter ();
            
            // Make Header Label
            var header_title = new Gtk.Label ("Pressure");
            header_title.get_style_context ().add_class ("h1");
            header_title.set_justify (Gtk.Justification.LEFT);
            header_title.halign = Gtk.Align.START;
            header_title.margin_start = 6;
            
            // Make Upper Unit Box
            from_entry = new Gtk.Entry ();
            from_entry.set_text ("0");
            from_entry.get_style_context ().add_class ("Pebbles_Conversion_Text_Box");
            from_entry.max_width_chars = 35;
            from_unit = new Gtk.ComboBoxText ();
            for (int i = 0; i < units.length; i++) {
                from_unit.append_text (units [i]);
            }
            from_unit.active = 0;

            // Make Lower Unit Box
            to_entry = new Gtk.Entry ();
            to_entry.set_text ("0");
            to_entry.get_style_context ().add_class ("Pebbles_Conversion_Text_Box");
            to_entry.max_width_chars = 35;
            to_unit = new Gtk.ComboBoxText ();
            for (int i = 0; i < units.length; i++) {
                to_unit.append_text (units [i]);
            }
            to_unit.active = 3;
            
            // Create Conversion active section
            interchange_button = new Gtk.Button ();
            var up_button = new Gtk.Image.from_icon_name ("go-up-symbolic", Gtk.IconSize.BUTTON);
            var down_button = new Gtk.Image.from_icon_name ("go-down-symbolic", Gtk.IconSize.BUTTON);
            var up_down_grid = new Gtk.Grid ();
            up_down_grid.valign = Gtk.Align.CENTER;
            up_down_grid.halign = Gtk.Align.CENTER;
            up_down_grid.attach (up_button, 0, 0, 1, 1);
            up_down_grid.attach (down_button, 1, 0, 1, 1);
            interchange_button.add (up_down_grid);
            interchange_button.margin_top = 8;
            interchange_button.margin_bottom = 8;
            interchange_button.margin_start = 100;
            interchange_button.margin_end   = 100;
            
            Gtk.Grid conversion_grid = new Gtk.Grid ();
            conversion_grid.attach (from_unit, 0, 0, 1, 1);
            conversion_grid.attach (from_entry, 0, 1, 1, 1);
            conversion_grid.attach (interchange_button, 0, 2, 1, 1);
            conversion_grid.attach (to_unit, 0, 3, 1, 1);
            conversion_grid.attach (to_entry, 0, 4, 1, 1);
            conversion_grid.width_request = 240;
            conversion_grid.height_request = 210;
            conversion_grid.set_row_homogeneous (true);
            conversion_grid.margin_start = 8;
            conversion_grid.margin_end = 8;
            conversion_grid.valign = Gtk.Align.CENTER;
            conversion_grid.halign = Gtk.Align.CENTER;
            conversion_grid.row_spacing = 8;
            
            var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            separator.margin_start = 25;
            separator.margin_end = 25;
            
            halign = Gtk.Align.CENTER;
            valign = Gtk.Align.CENTER;
            attach (header_title, 0, 0, 3, 1);
            attach (keypad, 0, 1, 1, 1);
            attach (separator, 1, 1, 1, 1);
            attach (conversion_grid, 2, 1, 1, 1);
            row_spacing = 8;

            handle_events ();
        }

        private void handle_events () {
            from_entry.button_press_event.connect (() => {
                from_to = 0;
                return false;
            });

            to_entry.button_press_event.connect (() => {
                from_to = 1;
                return false;
            });

            this.key_press_event.connect ((event) => {
                keypad.key_pressed (event);
                grab_focus_on_view_switch ();
                switch (event.keyval) {
                    case KeyboardHandler.KeyMap.TAB:
                    case KeyboardHandler.KeyMap.SHIFT_TAB:
                    if (this.from_entry.has_focus) {
                        this.to_entry.grab_focus_without_selecting ();
                        to_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                        from_to = 1;
                    } else {
                        this.from_entry.grab_focus_without_selecting ();
                        from_to = 0;
                        from_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                    }
                    break;
                    case KeyboardHandler.KeyMap.NAV_UP:
                    this.from_entry.grab_focus_without_selecting ();
                    from_to = 0;
                    from_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                    break;
                    case KeyboardHandler.KeyMap.NAV_DOWN:
                    this.to_entry.grab_focus_without_selecting ();
                    to_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                    from_to = 1;
                    break;
                    case KeyboardHandler.KeyMap.RETURN:
                    interchange_entries ();
                    interchange_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    break;
                }
                return false;
            });

            this.key_release_event.connect (() => {
                keypad.key_released ();
                interchange_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
                return false;
            });

            from_entry.changed.connect (() => {
                if (from_to == 0 && allow_change) {
                    string result = conv.convert (double.parse (from_entry.get_text ()), from_unit.active, to_unit.active);
                    to_entry.set_text (result);
                }
            });

            to_entry.changed.connect (() => {
                if (from_to == 1 && allow_change) {
                    string result = conv.convert (double.parse (to_entry.get_text ()), to_unit.active, from_unit.active);
                    from_entry.set_text (result);
                }
            });

            from_unit.changed.connect (() => {
                if (allow_change) {
                    string result = conv.convert (double.parse (to_entry.get_text ()), to_unit.active, from_unit.active);
                    from_entry.set_text (result);
                }
            });

            to_unit.changed.connect (() => {
                if (allow_change) {
                    string result = conv.convert (double.parse (from_entry.get_text ()), from_unit.active, to_unit.active);
                    to_entry.set_text (result);
                }
            });

            interchange_button.clicked.connect (() => {
                allow_change = false;
                int temp = to_unit.active;
                to_unit.active = from_unit.active;
                from_unit.active = temp;
                string result = conv.convert (double.parse (from_entry.get_text ()), from_unit.active, to_unit.active);
                to_entry.set_text (result);
                allow_change = true;
            });
            
            keypad.button_clicked.connect ((val) => {
                if (from_to == 0) {
                    if (val == "C") {
                        from_entry.grab_focus_without_selecting ();
                        from_entry.set_text ("0");
                    }
                    else if (val == "del") {
                        from_entry.grab_focus_without_selecting ();
                        from_entry.backspace ();
                    }
                    else {
                        if (from_entry.get_text () == "0"){
                            from_entry.set_text("");
                        }
                        from_entry.grab_focus_without_selecting ();
                        from_entry.insert_at_cursor (val);
                    }
                }
                else {
                    if (val == "C") {
                        to_entry.grab_focus_without_selecting ();
                        to_entry.set_text ("0");
                    }
                    else if (val == "del") {
                        to_entry.grab_focus_without_selecting ();
                        to_entry.backspace ();
                    }
                    else {
                        if (to_entry.get_text () == "0"){
                            to_entry.set_text("");
                        }
                        to_entry.grab_focus_without_selecting ();
                        to_entry.insert_at_cursor (val);
                    }
                }
            });
        }

        private void interchange_entries () {
            allow_change = false;
            int temp = to_unit.active;
            to_unit.active = from_unit.active;
            from_unit.active = temp;
            string result = conv.convert (double.parse (from_entry.get_text ()), from_unit.active, to_unit.active);
            to_entry.set_text (result);
            allow_change = true;
        }

        public void grab_focus_on_view_switch () {
            switch (from_to) {
                case 0: 
                    this.from_entry.grab_focus_without_selecting ();
                    break;
                case 1:
                    this.to_entry.grab_focus_without_selecting ();
                    break;
            }
        }
    }
}
