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
    public class ProgrammerDisplay : Gtk.Grid {
        //Settings;
        Pebbles.Settings settings;
        // Status Bar
        Gtk.Grid  lcd_status_bar;
        Gtk.Label qwd_label;
        Gtk.Label dwd_label;
        Gtk.Label wrd_label;
        Gtk.Label byt_label;
        Gtk.Label memory_label;
        Gtk.Label shift_label;
        
        // Number System label
        Gtk.Grid number_system_grid;

        public Gtk.Label hex_label;
        public Gtk.Label dec_label;
        public Gtk.Label oct_label;
        public Gtk.Label bin_label;
        
        Gtk.Label hex_number_label;
        Gtk.Label dec_number_label;
        Gtk.Label oct_number_label;
        Gtk.Label bin_number_label;
        
        // Answer label
        public Gtk.Label answer_label;
        
        // Input entry
        public Gtk.Entry input_entry;
        
        // Word length mode
        GlobalWordLength word_mode;

        // 
        ProgrammerCalculator programmer_calculator_front_end;
        ProgrammerView prog_view;

        // Programmer Calculator memory store
        private int64 _memory_reserve;
        private int64 memory_reserve {
            get { return _memory_reserve; }
            set {
                _memory_reserve = value;
                if (_memory_reserve == 0) {
                    set_memory_status (false);
                }
                else {
                    set_memory_status (true);
                }
                //settings.sci_memory_value = _memory_reserve.to_string ();
            }
        }

        public signal void last_token_changed (bool[] bool_arr);

        public ProgrammerDisplay (ProgrammerView view) {
            this.settings = Settings.get_default ();
            this.prog_view = view;
            programmer_calculator_front_end = new ProgrammerCalculator ();

            prog_display_make_ui ();
            prog_display_make_events ();
        }

        private void prog_display_make_ui () {
            // Stylize background;
            get_style_context ().add_class ("Pebbles_Display_Unit_Bg");
            
            // Make status bar
            lcd_status_bar = new Gtk.Grid ();
            qwd_label      = new Gtk.Label ("QWD");
            qwd_label.get_style_context ().add_class ("pebbles_h4");
            dwd_label      = new Gtk.Label ("DWD");
            dwd_label.get_style_context ().add_class ("pebbles_h4");
            wrd_label      = new Gtk.Label ("WRD");
            wrd_label.get_style_context ().add_class ("pebbles_h4");
            byt_label      = new Gtk.Label ("BYT");
            byt_label.get_style_context ().add_class ("pebbles_h4");
            memory_label   = new Gtk.Label ("M");
            memory_label.get_style_context ().add_class ("pebbles_h4");
            memory_label.set_opacity (0.2);
            shift_label    = new Gtk.Label ("SHIFT");
            shift_label.get_style_context ().add_class ("pebbles_h4");
            shift_label.set_opacity (0.2);
            
            var word_mode_display = new Gtk.Grid ();
            word_mode_display.attach (qwd_label, 0, 0, 1, 1);
            word_mode_display.attach (dwd_label, 1, 0, 1, 1);
            word_mode_display.attach (wrd_label, 2, 0, 1, 1);
            word_mode_display.attach (byt_label, 3, 0, 1, 1);
            word_mode_display.column_spacing = 10;
            
            lcd_status_bar.attach (word_mode_display, 0, 0, 1, 1);
            lcd_status_bar.attach (memory_label, 1, 0, 1, 1);
            lcd_status_bar.attach (shift_label, 2, 0, 1, 1);
            lcd_status_bar.column_spacing = 187;
            lcd_status_bar.width_request  = 530;
            lcd_status_bar.set_halign (Gtk.Align.END);
            
            // Make number system view
            number_system_grid = new Gtk.Grid ();
            hex_label = new Gtk.Label ("HEX");
            dec_label = new Gtk.Label ("DEC");
            oct_label = new Gtk.Label ("OCT");
            bin_label = new Gtk.Label ("BIN");
            
            hex_label.get_style_context ().add_class ("PebblesLCDSwitch");
            dec_label.get_style_context ().add_class ("PebblesLCDSwitch");
            oct_label.get_style_context ().add_class ("PebblesLCDSwitch");
            bin_label.get_style_context ().add_class ("PebblesLCDSwitch");
            bin_label.set_yalign (0);
            bin_label.set_margin_bottom (12);
            
            hex_number_label  = new Gtk.Label ("0");
            dec_number_label  = new Gtk.Label ("0");
            oct_number_label  = new Gtk.Label ("0");
            bin_number_label = new Gtk.Label (get_binary_length ());
            bin_number_label.set_line_wrap_mode (Pango.WrapMode.CHAR);
            bin_number_label.set_line_wrap (true);
            bin_number_label.lines = 2;
            bin_number_label.set_width_chars (34);
            bin_number_label.set_max_width_chars (34);
            bin_number_label.single_line_mode = false;
            bin_number_label.set_xalign (0);
            bin_number_label.set_yalign (0);
            
            hex_number_label.halign = Gtk.Align.START;
            dec_number_label.halign = Gtk.Align.START;
            oct_number_label.halign = Gtk.Align.START;
            bin_number_label.halign = Gtk.Align.START;
            
            hex_number_label.get_style_context ().add_class ("PebblesLCDLabelSmall");
            dec_number_label.get_style_context ().add_class ("PebblesLCDLabelSmall");
            oct_number_label.get_style_context ().add_class ("PebblesLCDLabelSmall");
            bin_number_label.get_style_context ().add_class ("PebblesLCDLabelSmall");
            
            
            number_system_grid.attach (hex_label,      0, 0, 1, 1);
            number_system_grid.attach (hex_number_label, 1, 0, 1, 1);
            number_system_grid.attach (dec_label,      0, 1, 1, 1);
            number_system_grid.attach (dec_number_label, 1, 1, 1, 1);
            number_system_grid.attach (oct_label,      0, 2, 1, 1);
            number_system_grid.attach (oct_number_label, 1, 2, 1, 1);
            number_system_grid.attach (bin_label,      0, 3, 1, 1);
            number_system_grid.attach (bin_number_label, 1, 3, 1, 1);
            number_system_grid.column_spacing = 8;
            number_system_grid.row_spacing    = 4;
            number_system_grid.margin_top     = 8;
            
            
            // Make LCD Answer label
            answer_label = new Gtk.Label ("0");
            answer_label.set_halign (Gtk.Align.END);
            answer_label.get_style_context ().add_class ("pebbles_h1");
            var scrollable = new Gtk.ScrolledWindow (null, null);
            scrollable.add (answer_label);
            scrollable.propagate_natural_height = true;
            scrollable.shadow_type = Gtk.ShadowType.NONE;
            scrollable.get_style_context ().add_class ("pebbles_h1");
            
            // Make Input Entry
            input_entry = new Gtk.Entry ();
            input_entry.set_has_frame (false);
            input_entry.set_text ("0");
            input_entry.get_style_context ().add_class ("pebbles_h2");
            input_entry.set_halign (Gtk.Align.START);
            input_entry.width_request = 265;
            input_entry.max_width_chars = 20;
            
            
            // Make seperator
            Gtk.Separator lcd_separator_h = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            lcd_separator_h.set_opacity (0.6);
            Gtk.Separator lcd_separator_v = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            lcd_separator_v.set_opacity (0.6);
            lcd_separator_v.margin_bottom = 8;
            lcd_separator_v.margin_end   = 7;
            lcd_separator_v.halign = Gtk.Align.CENTER;
            
            // Put it together
            attach (lcd_status_bar,     0, 0, 3, 1);
            attach (number_system_grid, 0, 1, 1, 3);
            attach (lcd_separator_v,    1, 1, 1, 3);
            attach (scrollable,         2, 1, 1, 1);
            attach (lcd_separator_h,    2, 2, 1, 1);
            attach (input_entry,        2, 3, 1, 1);

            width_request = 530;
        }

        public void get_answer_evaluate () {
            bool[] answer_array;
            if (!this.prog_view.window.history_manager.is_empty ()) {
                bool[] last_output_array= this.prog_view.window.history_manager.get_last_evaluation_result ().prog_output;
                string last_answer = programmer_calculator_front_end.bool_array_to_string (last_output_array, settings.global_word_length, settings.number_system);
                input_entry.set_text (input_entry.get_text().replace ("ans", last_answer));
                this.set_number_system ();
            }
            string result = programmer_calculator_front_end.evaluate_exp (settings.global_word_length, settings.number_system, out answer_array);
            this.answer_label.set_text (result);
            this.prog_view.window.history_manager.append_from_strings (EvaluationResult.ResultSource.PROG, 
                                                                       input_entry.get_text (), 
                                                                       result, 
                                                                       null, 
                                                                       null, 
                                                                       0, 
                                                                       0, 
                                                                       0,
                                                                       programmer_calculator_front_end.get_token_array(),
                                                                       answer_array,
                                                                       settings.global_word_length);
            this.prog_view.ans_button.set_sensitive (true);
        }

        public void memory_append (bool subtract) {
            string output = answer_label.get_text();
            bool[] output_array = programmer_calculator_front_end.string_to_bool_array (output, settings.number_system, settings.global_word_length);
            string int_string = programmer_calculator_front_end.bool_array_to_string (output_array, settings.global_word_length, NumberSystem.DECIMAL);
            int64 output_integer = 0;
            int64.from_string (int_string, out output_integer);
            print("memory: %s\n", output_integer.to_string ());
            if (subtract) {
                memory_reserve -= output_integer;
            } else {
                memory_reserve += output_integer;
            }
        }

        public void memory_recall () {
            bool[] output_array = programmer_calculator_front_end.string_to_bool_array (memory_reserve.to_string (), NumberSystem.DECIMAL, settings.global_word_length);
            string output = programmer_calculator_front_end.bool_array_to_string (output_array, settings.global_word_length, settings.number_system);
            insert_text (output);
        }

        public void memory_clear () {
            memory_reserve = 0;
        }

        public void set_last_token_from_bit_grid (bool[] arr) {
            input_entry.set_text (programmer_calculator_front_end.set_last_token (arr, settings.global_word_length, settings.number_system));
            input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
        }

        private void prog_display_make_events () {
            input_entry.changed.connect (() => {
                if (input_entry.get_text ().has_prefix ("0") && input_entry.get_text () != null) {
                    if (input_entry.get_text ().length != 1) {
                        input_entry.set_text (input_entry.get_text ().slice (1, input_entry.get_text().length));
                    }
                }
                if (input_entry.get_text().chug () != "")
                    programmer_calculator_front_end.populate_token_array (input_entry.get_text ());
                display_all_number_systems ();
            });
        }
        private void display_all_number_systems () {
            ProgrammerCalculator.Token current_input = programmer_calculator_front_end.get_last_token ();
            string binary_value = get_binary_length ();
            string decimal_value = "0";
            string octal_value = "0";
            string hex_value = "0";
            if (current_input.type == ProgrammerCalculator.TokenType.OPERAND) {
                if (current_input.number_system == NumberSystem.DECIMAL) {
                    decimal_value = current_input.token;
                    octal_value = programmer_calculator_front_end.convert_decimal_to_octal (current_input.token, settings.global_word_length);
                    hex_value = programmer_calculator_front_end.convert_decimal_to_hexadecimal (current_input.token);
                    binary_value = programmer_calculator_front_end.convert_decimal_to_binary (current_input.token, settings.global_word_length, true);
                } else
                if (current_input.number_system == NumberSystem.BINARY) {
                    decimal_value = programmer_calculator_front_end.convert_binary_to_decimal (current_input.token, settings.global_word_length);
                    binary_value = programmer_calculator_front_end.represent_binary_by_word_length (current_input.token, settings.global_word_length, true);
                    octal_value = programmer_calculator_front_end.convert_binary_to_octal (current_input.token, settings.global_word_length);
                    hex_value = programmer_calculator_front_end.convert_binary_to_hexadecimal (current_input.token, settings.global_word_length);
                } else
                if (current_input.number_system == NumberSystem.HEXADECIMAL) {
                    hex_value = current_input.token;
                    octal_value = programmer_calculator_front_end.convert_hexadecimal_to_octal (current_input.token, settings.global_word_length);
                    binary_value = programmer_calculator_front_end.convert_hexadecimal_to_binary (current_input.token, settings.global_word_length, true);
                    decimal_value = programmer_calculator_front_end.convert_hexadecimal_to_decimal (current_input.token, settings.global_word_length);
                } else
                if (current_input.number_system == NumberSystem.OCTAL) {
                    binary_value = programmer_calculator_front_end.convert_octal_to_binary (current_input.token, settings.global_word_length, true);
                    decimal_value = programmer_calculator_front_end.convert_octal_to_decimal (current_input.token, settings.global_word_length);
                    octal_value = current_input.token;
                    hex_value = programmer_calculator_front_end.convert_octal_to_hexadecimal (current_input.token, settings.global_word_length);
                }
                
            }
            hex_number_label.set_text (hex_value);
            dec_number_label.set_text (decimal_value);
            oct_number_label.set_text (octal_value);
            bin_number_label.set_text (binary_value);

            bool[] bool_array = programmer_calculator_front_end.string_to_bool_array (
                current_input.token,
                current_input.number_system,
                settings.global_word_length
            );

            last_token_changed (bool_array);
        }
        private string get_binary_length () {
            string binary_value = "";
            int max_num = 0;
            switch (settings.global_word_length) {
                case GlobalWordLength.BYT:
                max_num = 8;
                break;
                case GlobalWordLength.WRD:
                max_num = 16;
                break;
                case GlobalWordLength.DWD:
                max_num = 32;
                break;
                case GlobalWordLength.QWD:
                max_num = 64;
                break;
            }
            for (int i = 0; i < max_num; i++) {
                binary_value += "0";
                if ((i + 1) % 8 == 0) {
                    binary_value += " ";
                }
            }
            return binary_value;
        }
        public void set_number_system () {
            switch (settings.number_system) {
                case NumberSystem.HEXADECIMAL:
                dec_label.get_style_context ().remove_class ("PebblesLCDSwitchSelected");
                oct_label.get_style_context ().remove_class ("PebblesLCDSwitchSelected");
                bin_label.get_style_context ().remove_class ("PebblesLCDSwitchSelected");
                hex_label.get_style_context ().add_class    ("PebblesLCDSwitchSelected");
                break;
                case NumberSystem.BINARY:
                dec_label.get_style_context ().remove_class ("PebblesLCDSwitchSelected");
                oct_label.get_style_context ().remove_class ("PebblesLCDSwitchSelected");
                bin_label.get_style_context ().add_class    ("PebblesLCDSwitchSelected");
                hex_label.get_style_context ().remove_class ("PebblesLCDSwitchSelected");
                break;
                case NumberSystem.DECIMAL:
                dec_label.get_style_context ().add_class    ("PebblesLCDSwitchSelected");
                oct_label.get_style_context ().remove_class ("PebblesLCDSwitchSelected");
                bin_label.get_style_context ().remove_class ("PebblesLCDSwitchSelected");
                hex_label.get_style_context ().remove_class ("PebblesLCDSwitchSelected");
                break;
                case NumberSystem.OCTAL:
                dec_label.get_style_context ().remove_class ("PebblesLCDSwitchSelected");
                oct_label.get_style_context ().add_class    ("PebblesLCDSwitchSelected");
                bin_label.get_style_context ().remove_class ("PebblesLCDSwitchSelected");
                hex_label.get_style_context ().remove_class ("PebblesLCDSwitchSelected");
                break;
            }
            input_entry.set_text (programmer_calculator_front_end.set_number_system (input_entry.get_text (), settings.global_word_length));
        }
        public void set_shift_enable (bool s_on) {
            if (s_on) {
                shift_label.set_opacity (1);
            }
            else {
                shift_label.set_opacity (0.2);
            }
        }
        public void set_word_length_status (int state) {
            switch (state) {
                case 1 :
                    qwd_label.set_opacity  (0.2);
                    dwd_label.set_opacity  (1);
                    wrd_label.set_opacity  (0.2);
                    byt_label.set_opacity  (0.2);
                    word_mode = GlobalWordLength.DWD;
                    break;
                case 2 :
                    qwd_label.set_opacity  (0.2);
                    dwd_label.set_opacity  (0.2);
                    wrd_label.set_opacity  (1);
                    byt_label.set_opacity  (0.2);
                    word_mode = GlobalWordLength.WRD;
                    break;
                case 3 :
                    qwd_label.set_opacity  (0.2);
                    dwd_label.set_opacity  (0.2);
                    wrd_label.set_opacity  (0.2);
                    byt_label.set_opacity  (1);
                    word_mode = GlobalWordLength.BYT;
                    break;
                default :
                    qwd_label.set_opacity  (1);
                    dwd_label.set_opacity  (0.2);
                    wrd_label.set_opacity  (0.2);
                    byt_label.set_opacity  (0.2);
                    word_mode = GlobalWordLength.QWD;
                    break;
            }
        }
        // Just eye-candy
        public void display_off () {
            answer_label.set_opacity (0.1);
            number_system_grid.set_opacity (0.1);
            input_entry.set_opacity (0.1);
            lcd_status_bar.set_opacity (0.1);
        }

        public void display_on () {
            answer_label.set_opacity (1);
            number_system_grid.set_opacity (1);
            input_entry.set_opacity (1);
            lcd_status_bar.set_opacity (1);
        }

        public void send_backspace () {
            input_entry.backspace ();
            if (input_entry.get_text ().chug () == "") {
                input_entry.set_text ("0");
                input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
            }
        }

        public void insert_text (string text) {
            if (input_entry.get_text () == "0") {
                input_entry.set_text ("");
            }
            input_entry.grab_focus_without_selecting ();
            input_entry.insert_at_cursor (text);
        }

        public void set_memory_status (bool state) {
            if (state) {
                memory_label.set_opacity (1);
            }
            else {
                memory_label.set_opacity (0.2);
            }
        }
    }
}
