/*-
 * Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>
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
    public class ScientificView : Gtk.Grid {
        List<string> input_expression;
        // Reference of main window
        public MainWindow window;

        // Fake LCD display
        Gtk.Box display_container;
        public ScientificDisplay display_unit;

        // Input section left side
        Gtk.Grid button_container_left;

        // Input section right side
        Gtk.Grid button_container_right;

        // Input section left buttons
        StyledButton all_clear_button;
        StyledButton del_button;
        StyledButton percent_button;
        StyledButton divide_button;
        StyledButton seven_button;
        StyledButton eight_button;
        StyledButton nine_button;
        StyledButton multiply_button;
        StyledButton four_button;
        StyledButton five_button;
        StyledButton six_button;
        StyledButton subtract_button;
        StyledButton one_button;
        StyledButton two_button;
        StyledButton three_button;
        StyledButton plus_button;
        StyledButton zero_button;
        StyledButton decimal_button;
        StyledButton left_parenthesis_button;
        StyledButton right_parenthesis_button;

        // Input section right buttons
        StyledButton sqr_button;
        StyledButton pow_root_button;
        StyledButton expo_power_button;
        StyledButton memory_plus_button;
        StyledButton sin_button;
        StyledButton sinh_button;
        StyledButton log_cont_base_button;
        StyledButton memory_minus_button;
        StyledButton cos_button;
        StyledButton cosh_button;
        StyledButton log_mod_button;
        StyledButton memory_recall_button;
        StyledButton tan_button;
        StyledButton tanh_button;
        StyledButton perm_comb_button;
        StyledButton memory_clear_button;
        StyledButton fact_button;
        StyledButton constant_button;
        StyledButton last_answer_button;
        StyledButton result_button;

        // App Settings
        Pebbles.Settings settings;
        string constant_label_1;
        string constant_desc_1;
        string constant_label_2;
        string constant_desc_2;

        private bool shift_held = false;

        public ScientificView (MainWindow window) {
            this.window = window;
            load_constant_button_settings ();
            // Make UI
            sci_make_ui ();
            sci_make_events ();
        }

        construct { 
            halign = Gtk.Align.CENTER;
            valign = Gtk.Align.CENTER;
            column_spacing = 1;

            // Handle inputs
            input_expression = new List <string> ();
        }

        public void sci_make_ui () {
            //Make fake LCD display
            display_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            display_container.height_request = 120;
            display_container.width_request = 560;
            display_container.margin_start = 8;
            display_container.margin_end = 8;
            display_container.margin_top = 8;
            display_container.margin_bottom = 8;
            display_unit = new ScientificDisplay (this);
            display_container.pack_start (display_unit);

            // Make Input section on the left
            button_container_left = new Gtk.Grid ();
            button_container_left.height_request = 250;
            button_container_left.margin_start = 8;
            button_container_left.margin_end = 8;
            button_container_left.margin_bottom = 8;
            button_container_left.column_spacing = 8;
            button_container_left.row_spacing = 8;

            // Make Input section on the right
            button_container_right = new Gtk.Grid ();
            button_container_right.height_request = 250;
            button_container_right.margin_start = 8;
            button_container_right.margin_end = 8;
            button_container_right.margin_bottom = 8;
            button_container_right.column_spacing = 8;
            button_container_right.row_spacing = 8;

            // Make buttons on the left
            all_clear_button = new StyledButton ("C", "Clear entry");
            all_clear_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            del_button = new StyledButton ("Del", "Backspace");
            del_button.sensitive = false;
            display_unit.input_entry.changed.connect (() => {
                if (display_unit.input_entry.get_text () == "0" || display_unit.input_entry.get_text () == "")
                    del_button.sensitive = false;
                else
                    del_button.sensitive = true;
            });
            percent_button = new StyledButton ("%", "Percentage");
            percent_button.get_style_context ().add_class ("h3");
            divide_button = new StyledButton ("\xC3\xB7", "Divide");
            divide_button.get_style_context ().add_class ("h3");
            seven_button = new StyledButton ("7");
            eight_button = new StyledButton ("8");
            nine_button = new StyledButton ("9");
            multiply_button = new StyledButton ("\xC3\x97", "Multiply");
            multiply_button.get_style_context ().add_class ("h3");
            four_button = new StyledButton ("4");
            five_button = new StyledButton ("5");
            six_button = new StyledButton ("6");
            subtract_button = new StyledButton ("\xE2\x88\x92", "Subtract");
            subtract_button.get_style_context ().add_class ("h3");
            one_button = new StyledButton ("1");
            two_button = new StyledButton ("2");
            three_button = new StyledButton ("3");
            plus_button = new StyledButton ("+", "Add");
            plus_button.get_style_context ().add_class ("h3");
            zero_button = new StyledButton ("0");
            decimal_button = new StyledButton (".");
            left_parenthesis_button = new StyledButton ("(");
            right_parenthesis_button = new StyledButton (")");

            button_container_left.attach (all_clear_button, 0, 0, 1, 1);
            button_container_left.attach (del_button, 1, 0, 1, 1);
            button_container_left.attach (percent_button, 2, 0, 1, 1);
            button_container_left.attach (divide_button, 3, 0, 1, 1);
            button_container_left.attach (seven_button, 0, 1, 1, 1);
            button_container_left.attach (eight_button, 1, 1, 1, 1);
            button_container_left.attach (nine_button, 2, 1, 1, 1);
            button_container_left.attach (multiply_button, 3, 1, 1, 1);
            button_container_left.attach (four_button, 0, 2, 1, 1);
            button_container_left.attach (five_button, 1, 2, 1, 1);
            button_container_left.attach (six_button, 2, 2, 1, 1);
            button_container_left.attach (subtract_button, 3, 2, 1, 1);
            button_container_left.attach (one_button, 0, 3, 1, 1);
            button_container_left.attach (two_button, 1, 3, 1, 1);
            button_container_left.attach (three_button, 2, 3, 1, 1);
            button_container_left.attach (plus_button, 3, 3, 1, 1);
            button_container_left.attach (zero_button, 0, 4, 1, 1);
            button_container_left.attach (decimal_button, 1, 4, 1, 1);
            button_container_left.attach (left_parenthesis_button, 2, 4, 1, 1);
            button_container_left.attach (right_parenthesis_button, 3, 4, 1, 1);

            button_container_left.set_column_homogeneous (true);
            button_container_left.set_row_homogeneous (true);

            // Make buttons on the right
            sqr_button = new StyledButton ("x<sup>2</sup>", "Square a number");
            sqr_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            pow_root_button = new StyledButton ("x<sup>y</sup>", "x raised to the power y");
            pow_root_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            expo_power_button = new StyledButton ("10<sup>x</sup>", "10 raised to the power x");
            expo_power_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            memory_plus_button = new StyledButton ("M+", "Add it to the value in Memory");
            memory_plus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            sin_button = new StyledButton ("sin", "Sine");
            sin_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            sinh_button = new StyledButton ("sinh", "Hyperbolic Sine");
            sinh_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            log_cont_base_button = new StyledButton ("log x", "Log base 10");
            log_cont_base_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            memory_minus_button = new StyledButton ("M\xE2\x88\x92", "Subtract it from the value in Memory");
            memory_minus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            cos_button = new StyledButton ("cos", "Cosine");
            cos_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            cosh_button = new StyledButton ("cosh", "Hyperbolic Cosine");
            cosh_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            log_mod_button = new StyledButton ("Mod", "Modulus");
            log_mod_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            memory_recall_button = new StyledButton ("MR", "Recall value from Memory");
            memory_recall_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            tan_button = new StyledButton ("tan", "Tangent");
            tan_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            tanh_button = new StyledButton ("tanh", "Hyperbolic Tangent");
            tanh_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            perm_comb_button = new StyledButton ("<sup>n</sup>P\xE1\xB5\xA3", "Permutations");
            perm_comb_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            memory_clear_button = new StyledButton ("MC", "Memory Clear");
            memory_clear_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            fact_button = new StyledButton ("!", "Factorial");
            fact_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            constant_button = new StyledButton (constant_label_1, constant_desc_1);
            constant_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            last_answer_button = new StyledButton ("Ans", "Last answer");
            last_answer_button.sensitive = false;
            last_answer_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            result_button = new StyledButton ("=", "Result");
            result_button.get_style_context ().add_class ("h2");
            result_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

            button_container_right.attach (sqr_button, 0, 0, 1, 1);
            button_container_right.attach (pow_root_button, 1, 0, 1, 1);
            button_container_right.attach (expo_power_button, 2, 0, 1, 1);
            button_container_right.attach (memory_plus_button, 3, 0, 1, 1); 
            button_container_right.attach (sin_button, 0, 1, 1, 1);
            button_container_right.attach (sinh_button, 1, 1, 1, 1);
            button_container_right.attach (log_cont_base_button, 2, 1, 1, 1);
            button_container_right.attach (memory_minus_button, 3, 1, 1, 1);
            button_container_right.attach (cos_button, 0, 2, 1, 1);
            button_container_right.attach (cosh_button, 1, 2, 1, 1);
            button_container_right.attach (log_mod_button, 2, 2, 1, 1);
            button_container_right.attach (memory_recall_button, 3, 2, 1, 1);
            button_container_right.attach (tan_button, 0, 3, 1, 1);
            button_container_right.attach (tanh_button, 1, 3, 1, 1);
            button_container_right.attach (perm_comb_button, 2, 3, 1, 1);
            button_container_right.attach (memory_clear_button, 3, 3, 1, 1);
            button_container_right.attach (fact_button, 0, 4, 1, 1);
            button_container_right.attach (constant_button, 1, 4, 1, 1);
            button_container_right.attach (last_answer_button, 2, 4, 1, 1);
            button_container_right.attach (result_button, 3, 4, 1, 1);

            button_container_right.set_column_homogeneous (true);
            button_container_right.set_row_homogeneous (true);

            // Put it together
            attach (display_container, 0, 0, 2, 1);
            attach (button_container_left, 0, 1, 1, 1);
            attach (button_container_right, 1, 1, 1, 1);
            set_column_homogeneous (true);
        }
        public void hold_shift (bool hold) {
            shift_held = hold;
            display_unit.set_shift_enable (hold);
            set_alternative_button ();
        }
        
        public void set_alternative_button () {
            if (shift_held) {
                sqr_button.update_label ("\xE2\x88\x9A", "Square root over number");
                sqr_button.clicked.connect (() => {
                    shift_held = false;
                    window.shift_switch.set_active (false);
                    set_alternative_button ();
                });

                pow_root_button.update_label ("<sup>n</sup>\xE2\x88\x9A", "nth root over number");
                pow_root_button.clicked.connect (() => {
                    shift_held = false;
                    window.shift_switch.set_active (false);
                    set_alternative_button ();
                });

                expo_power_button.update_label ("e<sup>x</sup>", "e raised to the power x");
                expo_power_button.clicked.connect (() => {
                    shift_held = false;
                    window.shift_switch.set_active (false);
                    set_alternative_button ();
                });

                sin_button.update_label ("sin<sup>-1</sup>", "Sine Inverse");
                sin_button.clicked.connect (() => {
                    shift_held = false;
                    window.shift_switch.set_active (false);
                    set_alternative_button ();
                });

                cos_button.update_label ("cos<sup>-1</sup>", "Cosine Inverse");
                cos_button.clicked.connect (() => {
                    shift_held = false;
                    window.shift_switch.set_active (false);
                    set_alternative_button ();
                });

                tan_button.update_label ("tan<sup>-1</sup>", "Tangent Inverse");
                tan_button.clicked.connect (() => {
                    shift_held = false;
                    window.shift_switch.set_active (false);
                    set_alternative_button ();
                });

                sinh_button.update_label ("sinh<sup>-1</sup>", "Hyperbolic Sine Inverse");
                sinh_button.clicked.connect (() => {
                    shift_held = false;
                    window.shift_switch.set_active (false);
                    set_alternative_button ();
                });

                cosh_button.update_label ("cosh<sup>-1</sup>", "Hyperbolic Cosine Inverse");
                cosh_button.clicked.connect (() => {
                    shift_held = false;
                    window.shift_switch.set_active (false);
                    set_alternative_button ();
                });

                tanh_button.update_label ("tanh<sup>-1</sup>", "Hyperbolic Tangent Inverse");
                tanh_button.clicked.connect (() => {
                    shift_held = false;
                    window.shift_switch.set_active (false);
                    set_alternative_button ();
                });

                log_mod_button.update_label ("log\xE2\x82\x93y", "Log base x");
                log_mod_button.clicked.connect (() => {
                    shift_held = false;
                    window.shift_switch.set_active (false);
                    set_alternative_button ();
                });
                log_cont_base_button.update_label ("ln x", "Natural Logarithm");
                log_cont_base_button.clicked.connect (() => {
                    shift_held = false;
                    window.shift_switch.set_active (false);
                    set_alternative_button ();
                });
                perm_comb_button.update_label ("<sup>n</sup>C\xE1\xB5\xA3", "Combinations");
                perm_comb_button.clicked.connect (() => {
                    shift_held = false;
                    window.shift_switch.set_active (false);
                    set_alternative_button ();
                });
                constant_button.update_label (constant_label_2, constant_desc_2);
                constant_button.clicked.connect (() => {
                    shift_held = false;
                    window.shift_switch.set_active (false);
                    set_alternative_button ();
                });
            }
            else {
                sqr_button.update_label ("x<sup>2</sup>", "Square a number");
                pow_root_button.update_label ("x<sup>y</sup>", "x raised to the power y");
                expo_power_button.update_label ("10<sup>x</sup>", "10 raised to the power x");
                sin_button.update_label ("sin", "Sine");
                cos_button.update_label ("cos", "Cosine");
                tan_button.update_label ("tan", "Tangent");
                sinh_button.update_label ("sinh", "Hyperbolic Sine");
                cosh_button.update_label ("cosh", "Hyperbolic Cosine");
                tanh_button.update_label ("tanh", "Hyperbolic Tangent");
                log_mod_button.update_label ("Mod", "Modulus");
                log_cont_base_button.update_label ("log x", "Log base 10");
                perm_comb_button.update_label ("<sup>n</sup>P\xE1\xB5\xA3", "Permutations");
                constant_button.update_label (constant_label_1, constant_desc_1);
            }
        }

        private void load_constant_button_settings () {
            settings = Pebbles.Settings.get_default ();
            switch (settings.constant_key_value1) {
                case ConstantKeyIndex.ARCHIMEDES:
                    constant_label_1 = "\xCF\x80";
                    constant_desc_1 = "Archimedes' constant (pi)";
                    break;
                case ConstantKeyIndex.IMAGINARY:
                    constant_label_1 = "i";
                    constant_desc_1 = "Imaginary number (\xE2\x88\x9A-1)";
                    break;
                case ConstantKeyIndex.GOLDEN_RATIO:
                    constant_label_1 = "\xCF\x86";
                    constant_desc_1 = "Golden ratio (phi)";
                    break;
                case ConstantKeyIndex.EULER_MASCH:
                    constant_label_1 = "\xF0\x9D\x9B\xBE";
                    constant_desc_1 = "Euler–Mascheroni constant (gamma)";
                    break;
                case ConstantKeyIndex.CONWAY:
                    constant_label_1 = "\xCE\xBB";
                    constant_desc_1 = "Conway's constant (lamda)";
                    break;
                case ConstantKeyIndex.KHINCHIN:
                    constant_label_1 = "K";
                    constant_desc_1 = "Khinchin's constant";
                    break;
                case ConstantKeyIndex.FEIGEN_ALPHA:
                    constant_label_1 = "\xCE\xB1";
                    constant_desc_1 = "The Feigenbaum constant alpha";
                    break;
                case ConstantKeyIndex.FEIGEN_DELTA:
                    constant_label_1 = "\xCE\xB4";
                    constant_desc_1 = "The Feigenbaum constant delta";
                    break;
                case ConstantKeyIndex.APERY:
                    constant_label_1 = "\xF0\x9D\x9B\x87(3)";
                    constant_desc_1 = "Apery's constant";
                    break;
                default:
                    constant_label_1 = "e";
                    constant_desc_1 = "Euler's constant (exponential)";
                    break;
            }
            switch (settings.constant_key_value2) {
                case ConstantKeyIndex.ARCHIMEDES:
                    constant_label_2 = "\xCF\x80";
                    constant_desc_2 = "Archimedes' constant (pi)";
                    break;
                case ConstantKeyIndex.IMAGINARY:
                    constant_label_2 = "i";
                    constant_desc_2 = "Imaginary number (\xE2\x88\x9A-1)";
                    break;
                case ConstantKeyIndex.GOLDEN_RATIO:
                    constant_label_2 = "\xCF\x86";
                    constant_desc_2 = "Golden ratio (phi)";
                    break;
                case ConstantKeyIndex.EULER_MASCH:
                    constant_label_2 = "\xF0\x9D\x9B\xBE";
                    constant_desc_2 = "Euler–Mascheroni constant (gamma)";
                    break;
                case ConstantKeyIndex.CONWAY:
                    constant_label_2 = "\xCE\xBB";
                    constant_desc_2 = "Conway's constant (lamda)";
                    break;
                case ConstantKeyIndex.KHINCHIN:
                    constant_label_2 = "K";
                    constant_desc_2 = "Khinchin's constant";
                    break;
                case ConstantKeyIndex.FEIGEN_ALPHA:
                    constant_label_2 = "\xCE\xB1";
                    constant_desc_2 = "The Feigenbaum constant alpha";
                    break;
                case ConstantKeyIndex.FEIGEN_DELTA:
                    constant_label_2 = "\xCE\xB4";
                    constant_desc_2 = "The Feigenbaum constant delta";
                    break;
                case ConstantKeyIndex.APERY:
                    constant_label_2 = "\xF0\x9D\x9B\x87(3)";
                    constant_desc_2 = "Apery's constant";
                    break;
                default:
                    constant_label_2 = "e";
                    constant_desc_2 = "Euler's constant (exponential)";
                    break;
            }
        }
        private void sci_make_events () {
            result_button.button_press_event.connect ((event) => {
                if (event.button == 1) {
                    display_unit.display_off ();
                    display_unit.get_answer_evaluate ();
                    if (display_unit.input_entry.get_text ().length == 0 && display_unit.input_entry.get_text () != "0") {
                        display_unit.input_entry.set_text ("0");
                    }
                    display_unit.input_entry.set_text (Utils.preformat (display_unit.input_entry.get_text ()));
                    display_unit.input_entry.grab_focus_without_selecting ();
                    if (display_unit.input_entry.cursor_position < display_unit.input_entry.get_text ().length)
                        display_unit.input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                }
                return false;
            });
            result_button.button_release_event.connect (() => {
                display_unit.display_on ();
                return false;
            });
            all_clear_button.clicked.connect (() => {
                display_unit.input_entry.grab_focus_without_selecting ();
                display_unit.input_entry.set_text ("");
                display_unit.input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
            });
            del_button.clicked.connect (() => {
                display_unit.input_entry.grab_focus_without_selecting ();
                display_unit.input_entry.backspace ();
            });
            percent_button.clicked.connect (() => {
                char_button_click ("%");
            });
            divide_button.clicked.connect (() => {
                char_button_click ("÷");
            });
            seven_button.clicked.connect (() => {
                char_button_click ("7");
            });
            eight_button.clicked.connect (() => {;
                char_button_click ("8");
            });
            nine_button.clicked.connect (() => {;
                char_button_click ("9");
            });
            multiply_button.clicked.connect (() => {;
                char_button_click ("×");
            });
            four_button.clicked.connect (() => {;
                char_button_click ("4");
            });
            five_button.clicked.connect (() => {;
                char_button_click ("5");
            });
            six_button.clicked.connect (() => {;
                char_button_click ("6");
            });
            subtract_button.clicked.connect (() => {;
                char_button_click ("-");
            });
            one_button.clicked.connect (() => {;
                char_button_click ("1");
            });
            two_button.clicked.connect (() => {;
                char_button_click ("2");
            });
            three_button.clicked.connect (() => {;
                char_button_click ("3");
            });
            plus_button.clicked.connect (() => {;
                char_button_click ("+");
            });
            zero_button.clicked.connect (() => {;
                char_button_click ("0");
            });
            decimal_button.clicked.connect (() => {;
                char_button_click (".");
            });
            left_parenthesis_button.clicked.connect (() => {;
                char_button_click ("(");
            });
            right_parenthesis_button.clicked.connect (() => {;
                char_button_click (")");
            });
            sqr_button.clicked.connect (() => {
                if (shift_held)
                    char_button_click ("√");
                else
                    char_button_click ("^2");
            });
            pow_root_button.clicked.connect (() => {
                if (shift_held)
                    char_button_click ("\xE2\x81\xBF√");
                else
                    char_button_click ("^");
            });
            expo_power_button.clicked.connect (() => {
                if (shift_held)
                    char_button_click ("e^");
                else
                    char_button_click ("10^");
            });
            log_cont_base_button.clicked.connect (() => {
                if (shift_held)
                    char_button_click ("ln");
                else
                    char_button_click ("10log");
            });
            log_mod_button.clicked.connect (() => {
                if (shift_held)
                    char_button_click ("log");
                else
                    char_button_click ("mod");
            });
        }

        private void char_button_click (string input) {
            string sample = display_unit.input_entry.get_text ();
            display_unit.input_entry.grab_focus_without_selecting ();
            display_unit.input_entry.set_text (sample.concat (input));
            display_unit.input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
        }

        public void set_angle_mode_display (int state) {
            display_unit.set_angle_status (state);
        }
    }
}
