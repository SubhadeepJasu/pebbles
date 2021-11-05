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
    public class ConvCurrView : Gtk.Overlay {
        private CommonKeyPadConverter keypad;

        public Gtk.Entry from_entry;
        public Gtk.Entry to_entry;
        private int from_to = 0;
        private bool allow_change = true;
        Converter conv;
        private Gtk.ComboBoxText from_unit;
        private Gtk.ComboBoxText to_unit;
        private Gtk.Button interchange_button;

        private Granite.Widgets.Toast toast;
        private Granite.Widgets.OverlayBar waiting_overlay_bar;

        private CurrencyConverter curr;
        public signal void start_update ();
        public signal void update_done_or_failed ();

        bool ctrl_held = false;

        private Settings settings;
        public ResponsiveBox wrapbox;

        private double[] unit_multipliers = {
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
        };

        private string[] units = {
            (_("US Dollar") + ": $"),
            (_("Euro") + ": €"),
            (_("British Pounds") + ": £"),
            (_("Australian Dollar") + ": $"),
            (_("Brazilian Real") + ": R$"),
            (_("Canadian Dollar") + ": $"),
            (_("Chinese Yuan") + ": ¥"),
            (_("Indian Rupee") + ": ₹"),
            (_("Japanese Yen") + ": ¥"),
            (_("Russian Ruble") + ": руб"),
            (_("South African Rand") + ": R"),
        };

        private const int[] precision_override_structure = {
            2,
            2,
            2,
            2,
            2,
            2,
            2,
            2,
            3,
            2,
            2
        };

        construct {
            /* Initialize Currency Converter API 
             *
             * Uses Currency Converter API v6
             * <https://www.currencyconverterapi.com/>
             */
            settings = Settings.get_default ();

            curr = new CurrencyConverter ();

            var main_grid = new Gtk.Grid ();

            conv = new Converter (unit_multipliers, true, precision_override_structure);
            keypad = new CommonKeyPadConverter ();
            
            // Make Header Label
            var header_title = new Gtk.Label (_("Currency"));
            header_title.get_style_context ().add_class ("h2");
            header_title.set_justify (Gtk.Justification.LEFT);
            header_title.halign = Gtk.Align.START;
            header_title.margin_start = 8;
            
            // Make Upper Unit Box
            from_entry = new Gtk.Entry ();
            from_entry.set_text (settings.conv_curr_from_entry);
            from_entry.get_style_context ().add_class ("Pebbles_Conversion_Text_Box");
            from_entry.max_width_chars = 35;
            from_unit = new Gtk.ComboBoxText ();
            for (int i = 0; i < units.length; i++) {
                from_unit.append_text (units [i]);
            }
            from_unit.active = 0;

            // Make Lower Unit Box
            to_entry = new Gtk.Entry ();
            to_entry.set_text (settings.conv_curr_to_entry);
            to_entry.get_style_context ().add_class ("Pebbles_Conversion_Text_Box");
            to_entry.max_width_chars = 35;
            to_unit = new Gtk.ComboBoxText ();
            for (int i = 0; i < units.length; i++) {
                to_unit.append_text (units [i]);
            }
            to_unit.active = 1;

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
            conversion_grid.row_homogeneous = true;
            conversion_grid.column_homogeneous = true;
            conversion_grid.margin_start = 8;
            conversion_grid.margin_end = 8;
            conversion_grid.valign = Gtk.Align.CENTER;
            conversion_grid.row_spacing = 8;

            wrapbox = new ResponsiveBox (8);
            wrapbox.margin_bottom = 8;
            wrapbox.pack_end (keypad, true, true, 0);
            wrapbox.pack_start (conversion_grid, true, true, 0);
            
            halign = Gtk.Align.FILL;
            valign = Gtk.Align.FILL;
            main_grid.attach (header_title, 0, 0, 1, 1);
            main_grid.attach (wrapbox, 0, 1, 1, 1);

            main_grid.row_spacing = 8;
            main_grid.valign = Gtk.Align.CENTER;
            
            add (main_grid);
            
            toast = new Granite.Widgets.Toast (_("Failed to update forex data!"));
            waiting_overlay_bar = new Granite.Widgets.OverlayBar (this);
            waiting_overlay_bar.label = _("Updating foreign exchange data");
            waiting_overlay_bar.active = true;
            waiting_overlay_bar.opacity = 0.0;
            
            add_overlay (toast);
            double[] saved_data = curr.load_from_save ();
            if (saved_data.length > 0)
                conv.update_multipliers (saved_data);
            handle_events ();
        }
        public void update_currency_data () {
            start_update ();
            waiting_overlay_bar.opacity = 1.0;
            curr.request_update ();
        }
        private void handle_events () {
            curr.update_failed.connect (() => {
                toast.send_notification ();
                waiting_overlay_bar.opacity = 0.0;
                update_done_or_failed ();
            });
            
            curr.currency_updated.connect ((currency_val) => {
                unit_multipliers = currency_val;
                conv.update_multipliers (unit_multipliers);
                waiting_overlay_bar.opacity = 0.0;
                update_done_or_failed ();
            });

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
                if (event.keyval == KeyboardHandler.KeyMap.CTRL) {
                    ctrl_held = true;
                }
                switch (event.keyval) {
                    case KeyboardHandler.KeyMap.C_UPPER:
                    case KeyboardHandler.KeyMap.C_LOWER:
                    if (ctrl_held) {
                        write_answer_to_clipboard ();
                    }
                    break;
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
                    case KeyboardHandler.KeyMap.R_UPPER:
                    case KeyboardHandler.KeyMap.R_LOWER:
                    update_currency_data ();
                    break;
                }
                return false;
            });

            this.key_release_event.connect ((event) => {
                keypad.key_released ();
                interchange_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
                if (event.keyval == KeyboardHandler.KeyMap.CTRL) {
                    ctrl_held = false;
                }
                return false;
            });


            from_entry.changed.connect (() => {
                if (from_to == 0 && allow_change) {
                    string result = conv.convert ((from_entry.get_text ()), from_unit.active, to_unit.active);
                    if (result == "-nan" || result == "nan")
                        result = "E";
                    to_entry.set_text (result);
                }
                save_state ();
            });

            to_entry.changed.connect (() => {
                if (from_to == 1 && allow_change) {
                    string result = conv.convert ((to_entry.get_text ()), to_unit.active, from_unit.active);
                    if (result == "-nan" || result == "nan")
                        result = "E";
                    from_entry.set_text (result);
                }
                save_state ();
            });

            from_unit.changed.connect (() => {
                if (allow_change) {
                    string result = conv.convert ((to_entry.get_text ()), to_unit.active, from_unit.active);
                    if (result == "-nan" || result == "nan")
                        result = "E";
                    from_entry.set_text (result);
                }
                save_state ();
            });

            to_unit.changed.connect (() => {
                if (allow_change) {
                    string result = conv.convert ((from_entry.get_text ()), from_unit.active, to_unit.active);
                    if (result == "-nan" || result == "nan")
                        result = "E";
                    to_entry.set_text (result);
                }
                save_state ();
            });

            interchange_button.clicked.connect (() => {
                allow_change = false;
                int temp = to_unit.active;
                to_unit.active = from_unit.active;
                from_unit.active = temp;
                string result = conv.convert ((from_entry.get_text ()), from_unit.active, to_unit.active);
                if (result == "-nan" || result == "nan")
                        result = "E";
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
            string result = conv.convert ((from_entry.get_text ()), from_unit.active, to_unit.active);
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

        private void save_state () {
            settings.conv_curr_from_entry = from_entry.get_text ();
            settings.conv_curr_to_entry = to_entry.get_text ();
        }

        public void write_answer_to_clipboard () {
            Gdk.Display display = this.get_display ();
            Gtk.Clipboard clipboard = Gtk.Clipboard.get_for_display (display, Gdk.SELECTION_CLIPBOARD);
            if (from_to == 0) {
                string last_answer = to_entry.get_text().replace(Utils.get_local_separator_symbol(), "");
                clipboard.set_text (last_answer, -1);
            } else {
                string last_answer = from_entry.get_text().replace(Utils.get_local_separator_symbol(), "");
                clipboard.set_text (last_answer, -1);
            } 
        }
    }
}
