/*-
 * Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright (c) 2018-2019 Saunak Biswas  <saunakbis97@gmail.com>
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
    public class StatisticsView : Gtk.Grid {
        // Display
        StatisticsDisplay display_unit;

        // Left Buttons
        StyledButton all_clear_button;
        Gtk.Button del_button;
        StyledButton reset_button;
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
        StyledButton negative_button;

        // Right Buttons
        StyledButton nav_left_button;
        StyledButton nav_right_button;
        StyledButton add_cell_button;
        Gtk.Button remove_cell_button;
        StyledButton cardinality_button;
        StyledButton statistical_mode_button;
        StyledButton median_button;
        StyledButton memory_plus_button;
        StyledButton summation_button;
        StyledButton summation_sq_button;
        StyledButton sample_variance_button;
        StyledButton memory_minus_button;
        StyledButton mean_button;
        StyledButton mean_sq_button;
        StyledButton sample_std_dev_button;
        StyledButton memory_recall_button;
        StyledButton geometric_mean_button;
        StyledButton pop_variance_button;
        StyledButton pop_std_dev_button;
        StyledButton memory_clear_button;
        
        // Statistics Calculator Memory Store
        private double _memory_reserve;
        private double memory_reserve {
            get { return _memory_reserve; }
            set {
                _memory_reserve = value;
                if (_memory_reserve == 0 || _memory_reserve == 0.0) {
                    display_unit.set_memory_status (false);
                }
                else {
                    display_unit.set_memory_status (true);
                }
            }
        }

        public StatisticsView () {
            stat_make_ui ();
            stat_make_event ();
        }

        public void stat_make_ui () {
            // Make fake lcd display
            var display_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            display_container.height_request = 120;
            display_container.width_request = 560;
            display_container.margin_start = 8;
            display_container.margin_end = 8;
            display_container.margin_top = 8;
            display_container.margin_bottom = 8;
            display_unit = new StatisticsDisplay (this);
            display_container.pack_start (display_unit);


            // Make Input section on the left
            var button_container_left = new Gtk.Grid ();
            button_container_left.height_request = 250;
            button_container_left.margin_start = 8;
            button_container_left.margin_end = 8;
            button_container_left.margin_bottom = 8;
            button_container_left.column_spacing = 8;
            button_container_left.row_spacing = 8;

            // Make Input section on the right
            var button_container_right = new Gtk.Grid ();
            button_container_right.height_request = 250;
            button_container_right.margin_start = 8;
            button_container_right.margin_end = 8;
            button_container_right.margin_bottom = 8;
            button_container_right.column_spacing = 8;
            button_container_right.row_spacing = 8;

            // Make buttons on the left
            all_clear_button = new StyledButton ("C", "Clear cell data");
            all_clear_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            del_button = new Gtk.Button.from_icon_name ("edit-clear-symbolic", Gtk.IconSize.BUTTON);
            del_button.set_tooltip_text ("Backspace");
            del_button.sensitive = false;
            reset_button = new StyledButton ("Reset", "Clear sample");
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
            negative_button = new StyledButton ("+/-", "Negative");

            button_container_left.attach (all_clear_button, 0, 0, 1, 1);
            button_container_left.attach (del_button, 1, 0, 1, 1);
            button_container_left.attach (reset_button, 2, 0, 1, 1);
            button_container_left.attach (seven_button, 0, 1, 1, 1);
            button_container_left.attach (eight_button, 1, 1, 1, 1);
            button_container_left.attach (nine_button, 2, 1, 1, 1);
            button_container_left.attach (four_button, 0, 2, 1, 1);
            button_container_left.attach (five_button, 1, 2, 1, 1);
            button_container_left.attach (six_button, 2, 2, 1, 1);
            button_container_left.attach (one_button, 0, 3, 1, 1);
            button_container_left.attach (two_button, 1, 3, 1, 1);
            button_container_left.attach (three_button, 2, 3, 1, 1);
            button_container_left.attach (zero_button, 0, 4, 1 ,1);
            button_container_left.attach (decimal_button, 1, 4, 1, 1);
            button_container_left.attach (negative_button, 2, 4, 1, 1);

            button_container_left.set_column_homogeneous (true);
            button_container_left.set_row_homogeneous (true);

            // Make buttons on the right
            nav_left_button = new StyledButton ("❰", "Navigate to the cell on the left");
            nav_right_button = new StyledButton ("❱", "Navigate to the cell on the right");
            add_cell_button = new StyledButton ("▭⁺", "Left click: Add cell, Right click: Insert cell");
            add_cell_button.get_style_context ().add_class ("h3");
            add_cell_button.get_style_context ().add_class ("pebbles_button_prompt");
            remove_cell_button = new StyledButton ("▭⁻", "Remove current cell");
            remove_cell_button.get_style_context ().add_class ("h3");
            cardinality_button = new StyledButton ("n", "Sample size");
            cardinality_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            statistical_mode_button = new StyledButton ("mode", "Mode of the sample data");
            statistical_mode_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            median_button = new StyledButton ("M", "Median");
            median_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            memory_plus_button = new StyledButton ("M+");
            memory_plus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            summation_button = new StyledButton ("Σx", "Summation of all data values");
            summation_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            summation_sq_button = new StyledButton ("Σx<sup>2</sup>", "Summation of all data values squared");
            summation_sq_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            sample_variance_button = new StyledButton ("SV", "Sample variance");
            sample_variance_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            memory_minus_button = new StyledButton ("M-");
            memory_minus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            mean_button = new StyledButton ("x̄", "Mean");
            mean_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            mean_sq_button = new StyledButton ("x̄<sup>2</sup>", "Mean of squared data values");
            mean_sq_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            sample_std_dev_button = new StyledButton ("SD", "Standard deviation");
            sample_std_dev_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            memory_recall_button = new StyledButton ("MR", "Memory Recall");
            memory_recall_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            geometric_mean_button = new StyledButton ("GM", "Geometric mean");
            geometric_mean_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            pop_variance_button = new StyledButton ("σ<sup>2</sup>", "Population Variance");
            pop_variance_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            pop_std_dev_button = new StyledButton ("σ", "Population standard deviation");
            pop_std_dev_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            memory_clear_button = new StyledButton ("MC");
            memory_clear_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");



            button_container_right.attach (nav_left_button, 0, 0, 1, 1);
            button_container_right.attach (nav_right_button, 1, 0, 1, 1);
            button_container_right.attach (add_cell_button, 2, 0, 1, 1);
            button_container_right.attach (remove_cell_button, 3, 0, 1, 1);
            button_container_right.attach (cardinality_button, 0, 1, 1, 1);
            button_container_right.attach (statistical_mode_button, 1, 1, 1, 1);
            button_container_right.attach (median_button, 2, 1, 1, 1);
            button_container_right.attach (memory_plus_button, 3, 1, 1, 1);
            button_container_right.attach (summation_button, 0, 2, 1, 1);
            button_container_right.attach (summation_sq_button, 1, 2, 1, 1);
            button_container_right.attach (sample_variance_button, 2, 2, 1, 1);
            button_container_right.attach (memory_minus_button, 3, 2, 1, 1);
            button_container_right.attach (mean_button, 0, 3, 1, 1);
            button_container_right.attach (mean_sq_button, 1, 3, 1, 1);
            button_container_right.attach (sample_std_dev_button, 2, 3, 1, 1);
            button_container_right.attach (memory_recall_button, 3, 3, 1, 1);
            button_container_right.attach (geometric_mean_button, 0, 4, 1, 1);
            button_container_right.attach (pop_variance_button, 1, 4, 1, 1);
            button_container_right.attach (pop_std_dev_button, 2, 4, 1, 1);
            button_container_right.attach (memory_clear_button, 3, 4, 1, 1);

            button_container_right.set_column_homogeneous (true);
            button_container_right.set_row_homogeneous (true);

            attach (display_container, 0, 0, 2, 1);
            attach (button_container_left, 0, 1, 1, 1);
            attach (button_container_right, 1, 1, 1, 1);
            //set_column_homogeneous (true);
        }

        void stat_make_event () {
            // Numeric Buttons
            seven_button.clicked.connect (() => {
                display_unit.char_button_click ("7");
            });
            eight_button.clicked.connect (() => {
                display_unit.char_button_click ("8");
            });
            nine_button.clicked.connect (() => {
                display_unit.char_button_click ("9");
            });
            four_button.clicked.connect (() => {
                display_unit.char_button_click ("4");
            });
            five_button.clicked.connect (() => {
                display_unit.char_button_click ("5");
            });
            six_button.clicked.connect (() => {
                display_unit.char_button_click ("6");
            });
            one_button.clicked.connect (() => {
                display_unit.char_button_click ("1");
            });
            two_button.clicked.connect (() => {
                display_unit.char_button_click ("2");
            });
            three_button.clicked.connect (() => {
                display_unit.char_button_click ("3");
            });
            zero_button.clicked.connect (() => {
                display_unit.char_button_click ("0");
            });
            decimal_button.clicked.connect (() => {
                display_unit.char_button_click (".");
            });
            negative_button.clicked.connect (() => {
                display_unit.char_button_click ("-");
            });

            display_unit.cell_content_changed.connect ((content) => {
                if (content != "" && content != null) {
                    del_button.sensitive = true;
                } else {
                    del_button.sensitive = false;
                }
            });

            del_button.clicked.connect (() => {
                display_unit.send_backspace ();
            });

            all_clear_button.clicked.connect (() => {
                display_unit.clear_cell ();
            });

            reset_button.clicked.connect (() => {
                display_unit.reset_sample ();
                del_button.sensitive = false;
            });


            // Function Buttons
            cardinality_button.button_press_event.connect (() => {
                display_unit.display_off ();
                return false;
            });
            cardinality_button.button_release_event.connect (() => {
                display_unit.set_result_type (2);
                display_unit.answer_label.set_text (display_unit.get_cardinality ().to_string ());
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });
            statistical_mode_button.button_press_event.connect (() => {
                display_unit.display_off ();
                return false;
            });
            statistical_mode_button.button_release_event.connect (() => {
                display_unit.set_result_type (3);
                Statistics stat_calc = new Statistics();
                display_unit.answer_label.set_text (stat_calc.mode (display_unit.get_samples ()));
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });
            median_button.button_press_event.connect (() => {
                display_unit.display_off ();
                return false;
            });
            median_button.button_release_event.connect (() => {
                display_unit.set_result_type (1);
                Statistics stat_calc = new Statistics();
                display_unit.answer_label.set_text (stat_calc.median (display_unit.get_samples ()));
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });
            summation_button.button_press_event.connect (() => {
                display_unit.display_off ();
                return false;
            });
            summation_button.button_release_event.connect (() => {
                display_unit.set_result_type (4);
                Statistics stat_calc = new Statistics();
                display_unit.answer_label.set_text (stat_calc.summation_x (display_unit.get_samples ()));
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });
            summation_sq_button.button_press_event.connect (() => {
                display_unit.display_off ();
                return false;
            });
            summation_sq_button.button_release_event.connect (() => {
                display_unit.set_result_type (5);
                Statistics stat_calc = new Statistics();
                display_unit.answer_label.set_text (stat_calc.summation_x_square (display_unit.get_samples ()));
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });
            sample_variance_button.button_press_event.connect (() => {
                display_unit.display_off ();
                return false;
            });
            sample_variance_button.button_release_event.connect (() => {
                display_unit.set_result_type (10);
                Statistics stat_calc = new Statistics();
                display_unit.answer_label.set_text (stat_calc.sample_variance (display_unit.get_samples ()));
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });
            mean_button.button_press_event.connect (() => {
                display_unit.display_off ();
                return false;
            });
            mean_button.button_release_event.connect (() => {
                display_unit.set_result_type (6);
                Statistics stat_calc = new Statistics();
                display_unit.answer_label.set_text (stat_calc.mean_x (display_unit.get_samples ()));
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });
            mean_sq_button.button_press_event.connect (() => {
                display_unit.display_off ();
                return false;
            });
            mean_sq_button.button_release_event.connect (() => {
                display_unit.set_result_type (7);
                Statistics stat_calc = new Statistics();
                display_unit.answer_label.set_text (stat_calc.mean_x_square (display_unit.get_samples ()));
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });
            sample_std_dev_button.button_press_event.connect (() => {
                display_unit.display_off ();
                return false;
            });
            sample_std_dev_button.button_release_event.connect (() => {
                display_unit.set_result_type (11);
                Statistics stat_calc = new Statistics();
                display_unit.answer_label.set_text (stat_calc.sample_standard_deviation (display_unit.get_samples ()));
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });
            geometric_mean_button.button_press_event.connect (() => {
                display_unit.display_off ();
                return false;
            });
            geometric_mean_button.button_release_event.connect (() => {
                display_unit.set_result_type (0);
                Statistics stat_calc = new Statistics();
                display_unit.answer_label.set_text (stat_calc.geometric_mean (display_unit.get_samples ()));
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });
            pop_variance_button.button_press_event.connect (() => {
                display_unit.display_off ();
                return false;
            });
            pop_variance_button.button_release_event.connect (() => {
                display_unit.set_result_type (9);
                Statistics stat_calc = new Statistics();
                display_unit.answer_label.set_text (stat_calc.population_variance (display_unit.get_samples ()));
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });
            pop_std_dev_button.button_press_event.connect (() => {
                display_unit.display_off ();
                return false;
            });
            pop_std_dev_button.button_release_event.connect (() => {
                display_unit.set_result_type (8);
                Statistics stat_calc = new Statistics();
                display_unit.answer_label.set_text (stat_calc.population_standard_deviation (display_unit.get_samples ()));
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });

            add_cell_button.button_press_event.connect ((event) => {
                switch (event.button) {
                    case 1:
                        display_unit.insert_cell (true);
                        break;
                    case 3:
                        display_unit.insert_cell (false);
                        break;
                }
                display_unit.display_off ();
                return false;
            });
            add_cell_button.button_release_event.connect (() => {
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                add_cell_button.get_style_context ().remove_class ("pebbles_button_prompt");
                return false;
            });

            nav_left_button.button_press_event.connect (() => {
                display_unit.navigate_left();
                return false;
            });
            nav_left_button.button_release_event.connect (() => {
                display_unit.set_editable_cell ();
                return false;
            });

            nav_right_button.button_press_event.connect (() => {
                display_unit.navigate_right ();
                return false;
            });
            nav_right_button.button_release_event.connect (() => {
                display_unit.set_editable_cell ();
                return false;
            });

            remove_cell_button.button_press_event.connect (() => {
                display_unit.remove_cell ();
                display_unit.display_off ();
                return false;
            });
            remove_cell_button.button_release_event.connect (() => {
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });

            memory_plus_button.button_press_event.connect ((event) => {
                if (event.button == 1) {
                    display_unit.display_off ();
                    if (display_unit.answer_label.get_text () != "nan" && !display_unit.answer_label.get_text ().contains (",")) {
                        memory_reserve += double.parse (display_unit.answer_label.get_text ());
                    }
                }
                return false;
            });
            memory_plus_button.button_release_event.connect (() => {
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });

            memory_minus_button.button_press_event.connect ((event) => {
                if (event.button == 1) {
                    display_unit.display_off ();
                    if (display_unit.answer_label.get_text () != "nan" && !display_unit.answer_label.get_text ().contains (",")) {
                        memory_reserve -= double.parse (display_unit.answer_label.get_text ());
                    }
                }
                return false;
            });
            memory_minus_button.button_release_event.connect (() => {
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });

            memory_recall_button.button_press_event.connect (() => {
                display_unit.display_off ();
                display_unit.char_button_click (memory_reserve.to_string ());
                return false;
            });

            memory_recall_button.button_release_event.connect (() => {
                display_unit.set_editable_cell ();
                display_unit.display_on ();
                return false;
            });

            memory_clear_button.button_press_event.connect ((event) => {
                display_unit.display_off ();
                memory_reserve = 0.0;
                return false;
            });
            memory_clear_button.button_release_event.connect (() => {
                display_unit.display_on ();
                return false;
            });

            this.key_release_event.connect ((event) => {
                key_released ();
                return false;
            });

            this.display_unit.navigate_cell.connect ((navigating, direction_left) => {
                if (navigating) {
                    if (direction_left) {
                        nav_left_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    } else {
                        nav_right_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    }
                } else {
                    add_cell_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                }
            });
        }

        public void key_pressed (Gdk.EventKey event) {
            stdout.printf ("key: %u\n", event.keyval);
            display_unit.set_editable_cell ();
            switch (event.keyval) {
                case 65288:
                    del_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    break;
                case 65463: // 7 key numpad
                case 55:
                    seven_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    break;
                case 65464: // 8 key numpad
                case 56:
                    eight_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    break;
                case 65465: // 9 key numpad
                case 57:
                    nine_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    break;
                case 65460: // 4 key numpad
                case 52:
                    four_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    break;
                case 65461: // 5 key numpad
                case 53:
                    five_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    break;
                case 65462: // 6 key numpad
                case 54:
                    six_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    break;
                case 65457: // 1 key numpad
                case 49:
                    one_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    break;
                case 65458: // 2 key numpad
                case 50:
                    two_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    break;
                case 65459: // 3 key numpad
                case 51:
                    three_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    break;
                case 65456: // 0 key numpad
                case 48:
                    zero_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    break;
                case 65454:
                    decimal_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                    break;
                case 65471:
                    memory_plus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory_Pressed");
                    break;
                case 65472:
                    memory_minus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory_Pressed");
                    break;
                case 65473:
                    memory_recall_button.get_style_context ().add_class ("Pebbles_Buttons_Memory_Pressed");
                    break;
                case 65474:
                    memory_clear_button.get_style_context ().add_class ("Pebbles_Buttons_Memory_Pressed");
                    break;
                case 65289:
                    display_unit.tab_navigate ();
                    add_cell_button.get_style_context ().remove_class ("pebbles_button_prompt");
                    break;
                case 65056:
                    display_unit.shift_tab_navigate ();
                    add_cell_button.get_style_context ().remove_class ("pebbles_button_prompt");
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
            memory_plus_button.get_style_context ().remove_class ("Pebbles_Buttons_Memory_Pressed");
            memory_minus_button.get_style_context ().remove_class ("Pebbles_Buttons_Memory_Pressed");
            memory_recall_button.get_style_context ().remove_class ("Pebbles_Buttons_Memory_Pressed");
            memory_clear_button.get_style_context ().remove_class ("Pebbles_Buttons_Memory_Pressed");
            add_cell_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            nav_left_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            nav_right_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");

            display_unit.set_editable_cell ();
        }
    }
}