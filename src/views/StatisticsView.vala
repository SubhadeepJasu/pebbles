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
        StyledButton del_button;
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
        StyledButton exp_button;

        // Right Buttons
        StyledButton nav_left_button;
        StyledButton nav_right_button;
        Gtk.Button add_cell_button;
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
            del_button = new StyledButton ("Del", "Backspace");
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
            exp_button = new StyledButton ("e<sup>x</sup>", "exponential");

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
            button_container_left.attach (exp_button, 2, 4, 1, 1);

            button_container_left.set_column_homogeneous (true);
            button_container_left.set_row_homogeneous (true);

            // Make buttons on the right
            nav_left_button = new StyledButton ("❰", "Navigate to the cell on the left");
            nav_right_button = new StyledButton ("❱", "Navigate to the cell on the right");
            add_cell_button = new Gtk.Button.from_icon_name ("document-new-symbolic", Gtk.IconSize.BUTTON);
            add_cell_button.set_tooltip_text ("Insert new cell");
            remove_cell_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.BUTTON);
            remove_cell_button.set_tooltip_text ("Remove current cell");
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
            cardinality_button.clicked.connect (() => {
                display_unit.set_result_type (2);
            });
            statistical_mode_button.clicked.connect (() => {
                display_unit.set_result_type (3);
            });
            median_button.clicked.connect (() => {
                display_unit.set_result_type (1);
            });
            summation_button.clicked.connect (() => {
                display_unit.set_result_type (4);
            });
            summation_sq_button.clicked.connect (() => {
                display_unit.set_result_type (5);
            });
            sample_variance_button.clicked.connect (() => {
                display_unit.set_result_type (10);
            });
            mean_button.clicked.connect (() => {
                display_unit.set_result_type (6);
            });
            mean_sq_button.clicked.connect (() => {
                display_unit.set_result_type (7);
            });
            sample_std_dev_button.clicked.connect (() => {
                display_unit.set_result_type (11);
            });
            geometric_mean_button.clicked.connect (() => {
                display_unit.set_result_type (0);
            });
            pop_variance_button.clicked.connect (() => {
                display_unit.set_result_type (9);
            });
            pop_std_dev_button.clicked.connect (() => {
                display_unit.set_result_type (8);
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
                return false;
            });
            add_cell_button.button_release_event.connect (() => {
                display_unit.set_editable_cell ();
                return false;
            });

            nav_left_button.clicked.connect (() => {
                display_unit.navigate_left ();
            });

            nav_right_button.clicked.connect (() => {
                display_unit.navigate_right ();
            });

            remove_cell_button.clicked.connect (() => {
                display_unit.remove_cell ();
            });
        }
    }
}