/*-
 * Copyright (c) 2017-2020 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright (c) 2017-2020 Saunak Biswas  <saunakbis97@gmail.com>
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
        private int decimal_places;
        // Display
        StatisticsDisplay display_unit;

        // Input section left side
        Gtk.Grid button_container_left;

        // Input section right side
        Gtk.Grid button_container_right;

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

        // Button Leaflet
        public Hdy.Leaflet button_leaflet;

        // Toolbar
        Gtk.Revealer bottom_button_bar_revealer;
        StyledButton result_button;

        private bool ctrl_held = false;
        
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
            var settings = Pebbles.Settings.get_default ();
            this.decimal_places = settings.decimal_places;
            stat_make_ui ();
            stat_make_event ();
        }

        public void stat_make_ui () {
            // Make fake lcd display
            var display_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            display_container.height_request = 120;
            display_container.margin_start = 8;
            display_container.margin_end = 8;
            display_container.margin_top = 8;
            display_container.margin_bottom = 8;
            display_unit = new StatisticsDisplay (this);
            display_container.pack_start (display_unit);


            // Make Input section on the left
            button_container_left = new Gtk.Grid ();
            button_container_left.height_request = 250;
            button_container_left.margin_start = 8;
            button_container_left.margin_end = 8;
            button_container_left.margin_bottom = 8;
            button_container_left.column_spacing = 8;
            button_container_left.row_spacing = 8;
            button_container_left.vexpand = true;

            // Make Input section on the right
            button_container_right = new Gtk.Grid ();
            button_container_right.height_request = 250;
            button_container_right.margin_start = 8;
            button_container_right.margin_end = 8;
            button_container_right.margin_bottom = 8;
            button_container_right.column_spacing = 8;
            button_container_right.row_spacing = 8;
            button_container_left.vexpand = true;

            // Make buttons on the left
            all_clear_button = new StyledButton ("AC", (_("All Clear")), {"Delete"});
            all_clear_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            all_clear_button.get_style_context ().add_class ("pebbles_button_font_size");
            del_button = new Gtk.Button.from_icon_name ("edit-clear-symbolic", Gtk.IconSize.BUTTON);
            del_button.set_tooltip_text (_("Backspace"));
            del_button.sensitive = false;
            del_button.get_style_context ().remove_class ("image-button");
            del_button.get_style_context ().add_class ("pebbles_button_font_size");
            reset_button = new StyledButton (_("Reset"), _("Clear sample"), {"End"});
            reset_button.get_style_context ().add_class ("pebbles_button_font_size");
            seven_button = new StyledButton ("7");
            seven_button.get_style_context ().add_class ("pebbles_button_font_size");
            eight_button = new StyledButton ("8");
            eight_button.get_style_context ().add_class ("pebbles_button_font_size");
            nine_button = new StyledButton ("9");
            nine_button.get_style_context ().add_class ("pebbles_button_font_size");
            four_button = new StyledButton ("4");
            four_button.get_style_context ().add_class ("pebbles_button_font_size");
            five_button = new StyledButton ("5");
            five_button.get_style_context ().add_class ("pebbles_button_font_size");
            six_button = new StyledButton ("6");
            six_button.get_style_context ().add_class ("pebbles_button_font_size");
            one_button = new StyledButton ("1");
            one_button.get_style_context ().add_class ("pebbles_button_font_size");
            two_button = new StyledButton ("2");
            two_button.get_style_context ().add_class ("pebbles_button_font_size");
            three_button = new StyledButton ("3");
            three_button.get_style_context ().add_class ("pebbles_button_font_size");
            zero_button = new StyledButton ("0");
            zero_button.get_style_context ().add_class ("pebbles_button_font_size");
            decimal_button = new StyledButton (".");
            decimal_button.get_style_context ().add_class ("pebbles_button_font_size");
            negative_button = new StyledButton ("+/-", _("Negative"));
            negative_button.get_style_context ().add_class ("pebbles_button_font_size_h3");

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

            button_container_left.hexpand = true;
            button_container_left.set_column_homogeneous (true);
            button_container_left.set_row_homogeneous (true);

            // Make buttons on the right
            nav_left_button = new StyledButton ("❰", _("Navigate to the cell on the left"), {"Left"});
            nav_left_button.get_style_context ().add_class ("pebbles_button_font_size");
            nav_right_button = new StyledButton ("❱", _("Navigate to the cell on the right"), {"Right"});
            nav_right_button.get_style_context ().add_class ("pebbles_button_font_size");
            add_cell_button = new StyledButton ("▭⁺", _("Left click: Add cell, Right click: Insert cell"), {"Page_Up", "Page_Down"});
            add_cell_button.get_style_context ().add_class ("pebbles_button_font_size_h3");
            add_cell_button.get_style_context ().add_class ("pebbles_button_prompt");
            remove_cell_button = new StyledButton ("▭⁻", _("Remove current cell"), {"Home"});
            remove_cell_button.get_style_context ().add_class ("pebbles_button_font_size_h3");
            cardinality_button = new StyledButton ("n", _("Sample size"), {"N"});
            cardinality_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            cardinality_button.get_style_context ().add_class ("pebbles_button_font_size");
            statistical_mode_button = new StyledButton ("mode", _("Mode of the sample data"), {"O"});
            statistical_mode_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            statistical_mode_button.get_style_context ().add_class ("pebbles_button_font_size");
            median_button = new StyledButton ("M", _("Median"), {"E"});
            median_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            median_button.get_style_context ().add_class ("pebbles_button_font_size");
            memory_plus_button = new StyledButton ("M+", _("Add to Memory"), {"F2"});
            memory_plus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            memory_plus_button.get_style_context ().add_class ("pebbles_button_font_size");
            summation_button = new StyledButton ("Σx", _("Summation of all data values"), {"S"});
            summation_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            summation_button.get_style_context ().add_class ("pebbles_button_font_size");
            summation_sq_button = new StyledButton ("Σx<sup>2</sup>", _("Summation of all data values squared"), {"Q"});
            summation_sq_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            summation_sq_button.get_style_context ().add_class ("pebbles_button_font_size");
            sample_variance_button = new StyledButton ("SV", _("Sample variance"), {"V"});
            sample_variance_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            sample_variance_button.get_style_context ().add_class ("pebbles_button_font_size");
            memory_minus_button = new StyledButton ("M-", _("Subtract from Memory"), {"F3"});
            memory_minus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            memory_minus_button.get_style_context ().add_class ("pebbles_button_font_size");
            mean_button = new StyledButton ("x̄", _("Mean"), {"M"});
            mean_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            mean_button.get_style_context ().add_class ("pebbles_button_font_size");
            mean_sq_button = new StyledButton ("x̄<sup>2</sup>", _("Mean of squared data values"), {"A"});
            mean_sq_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            mean_sq_button.get_style_context ().add_class ("pebbles_button_font_size");
            sample_std_dev_button = new StyledButton ("SD", _("Standard deviation"), {"D"});
            sample_std_dev_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            sample_std_dev_button.get_style_context ().add_class ("pebbles_button_font_size");
            memory_recall_button = new StyledButton ("MR", _("Memory Recall"), {"F4"});
            memory_recall_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            memory_recall_button.get_style_context ().add_class ("pebbles_button_font_size");
            geometric_mean_button = new StyledButton ("GM", _("Geometric mean"), {"G"});
            geometric_mean_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            geometric_mean_button.get_style_context ().add_class ("pebbles_button_font_size");
            pop_variance_button = new StyledButton ("σ<sup>2</sup>", _("Population Variance"), {"P"});
            pop_variance_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            pop_variance_button.get_style_context ().add_class ("pebbles_button_font_size");
            pop_std_dev_button = new StyledButton ("σ", _("Population standard deviation"), {"L"});
            pop_std_dev_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            pop_std_dev_button.get_style_context ().add_class ("pebbles_button_font_size");
            memory_clear_button = new StyledButton ("MC", _("Memory Clear"), {"F5"});
            memory_clear_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            memory_clear_button.get_style_context ().add_class ("pebbles_button_font_size");



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

            button_container_right.hexpand = true;
            button_container_right.set_column_homogeneous (true);
            button_container_right.set_row_homogeneous (true);

            button_leaflet = new Hdy.Leaflet ();
            button_leaflet.add (button_container_left);
            button_leaflet.add (button_container_right);
            button_leaflet.set_visible_child (button_container_left);
            //  button_leaflet.hhomogeneous_unfolded = true;
            button_leaflet.can_swipe_back = true;
            button_leaflet.can_swipe_forward = true;

            bottom_button_bar_revealer = new Gtk.Revealer ();
            var bottom_toolbar = new Gtk.ActionBar ();
            bottom_toolbar.height_request = 40;

            result_button = new StyledButton ("=", _("Query Result"));
            result_button.width_request = 72;
            result_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            result_button.halign = Gtk.Align.CENTER;
            result_button.hexpand = true;

            bottom_button_bar_revealer.add (bottom_toolbar);
            bottom_button_bar_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;

            var toolbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
            toolbox.set_homogeneous (true);
            toolbox.pack_start (result_button);
            toolbox.margin = 8;
            toolbox.margin_start = 4;
            toolbox.margin_end = 4;

            bottom_toolbar.pack_start (toolbox);

            attach (display_container, 0, 0, 1, 1);
            attach (button_leaflet, 0, 1, 1, 1);
            attach (bottom_button_bar_revealer, 0, 2, 1, 1);
            //set_column_homogeneous (true);
        }

        private void toggle_leaf () {
            if (!button_leaflet.get_child_transition_running ()) {
                if (button_leaflet.get_visible_child () == button_container_left) {
                    button_leaflet.set_visible_child (button_container_right);
                } else {
                    button_leaflet.set_visible_child (button_container_left);
                }
            }
        }

        void stat_make_event () {
            this.size_allocate.connect ((event) => {
                if (button_leaflet.folded) {
                    bottom_button_bar_revealer.set_reveal_child (true);
                } else {
                    bottom_button_bar_revealer.set_reveal_child (false);
                }
            });
            result_button.clicked.connect (() => {
                toggle_leaf ();
            });
            // Numeric Buttons
            seven_button.clicked.connect (() => {
                display_unit.insert_text ("7");
            });
            eight_button.clicked.connect (() => {
                display_unit.insert_text ("8");
            });
            nine_button.clicked.connect (() => {
                display_unit.insert_text ("9");
            });
            four_button.clicked.connect (() => {
                display_unit.insert_text ("4");
            });
            five_button.clicked.connect (() => {
                display_unit.insert_text ("5");
            });
            six_button.clicked.connect (() => {
                display_unit.insert_text ("6");
            });
            one_button.clicked.connect (() => {
                display_unit.insert_text ("1");
            });
            two_button.clicked.connect (() => {
                display_unit.insert_text ("2");
            });
            three_button.clicked.connect (() => {
                display_unit.insert_text ("3");
            });
            zero_button.clicked.connect (() => {
                display_unit.insert_text ("0");
            });
            decimal_button.clicked.connect (() => {
                display_unit.insert_text (".");
            });
            negative_button.clicked.connect (() => {
                display_unit.insert_text ("-");
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

            reset_button.button_press_event.connect (() => {
                display_unit.display_off ();
                return false;
            });
            reset_button.button_release_event.connect (() => {
                display_unit.reset_sample ();
                del_button.sensitive = false;
                display_unit.display_on ();
                return false;
            });


            // Function Buttons
            cardinality_button.button_press_event.connect (() => {
                display_unit.display_off ();
                return false;
            });
            cardinality_button.button_release_event.connect (() => {
                display_unit.set_result_type (2);
                display_unit.set_answer_label (display_unit.get_cardinality ().to_string ());
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
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.mode (display_unit.get_samples ()));
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
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.median (display_unit.get_samples ()));
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
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.summation_x (display_unit.get_samples ()));
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
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.summation_x_square (display_unit.get_samples ()));
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
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.sample_variance (display_unit.get_samples ()));
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
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.mean_x (display_unit.get_samples ()));
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
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.mean_x_square (display_unit.get_samples ()));
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
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.sample_standard_deviation (display_unit.get_samples ()));
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
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.geometric_mean (display_unit.get_samples ()));
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
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.population_variance (display_unit.get_samples ()));
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
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.population_standard_deviation (display_unit.get_samples ()));
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
                display_unit.insert_text (memory_reserve.to_string ());
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
                key_released (event);
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

            this.button_release_event.connect ((event) => {
                nav_left_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
                nav_right_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
                return false;
            });
        }

        public void key_pressed (Gdk.EventKey event) {
            stdout.printf ("key: %u\n", event.keyval);
            display_unit.set_editable_cell ();
            if (event.keyval == KeyboardHandler.KeyMap.CTRL) {
                ctrl_held = true;
            }
            switch (event.keyval) {
                case KeyboardHandler.KeyMap.BACKSPACE:
                display_unit.send_backspace ();
                del_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_7: // 7 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_7:
                display_unit.insert_text ("7");
                seven_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_8: // 8 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_8:
                display_unit.insert_text ("8");
                eight_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_9: // 9 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_9:
                display_unit.insert_text ("9");
                nine_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_4: // 4 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_4:
                display_unit.insert_text ("4");
                four_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_5: // 5 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_5:
                display_unit.insert_text ("5");
                five_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_6: // 6 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_6:
                display_unit.insert_text ("6");
                six_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_1: // 1 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_1:
                display_unit.insert_text ("1");
                one_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_2: // 2 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_2:
                display_unit.insert_text ("2");
                two_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_3: // 3 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_3:
                display_unit.insert_text ("3");
                three_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_0: // 0 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_0:
                display_unit.insert_text ("0");
                zero_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_RADIX:
                case KeyboardHandler.KeyMap.KEYPAD_RADIX:
                display_unit.insert_text (".");
                decimal_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.F2:
                display_unit.display_off ();
                if (display_unit.answer_label.get_text () != "nan" && !display_unit.answer_label.get_text ().contains (",")) {
                    memory_reserve += double.parse (display_unit.answer_label.get_text ());
                }
                memory_plus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory_Pressed");
                break;
                case KeyboardHandler.KeyMap.F3:
                display_unit.display_off ();
                if (display_unit.answer_label.get_text () != "nan" && !display_unit.answer_label.get_text ().contains (",")) {
                    memory_reserve -= double.parse (display_unit.answer_label.get_text ());
                }
                memory_minus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory_Pressed");
                break;
                case KeyboardHandler.KeyMap.F4:
                display_unit.insert_text (memory_reserve.to_string ());
                memory_recall_button.get_style_context ().add_class ("Pebbles_Buttons_Memory_Pressed");
                break;
                case KeyboardHandler.KeyMap.F5:
                display_unit.display_off ();
                memory_reserve = 0.0;
                memory_clear_button.get_style_context ().add_class ("Pebbles_Buttons_Memory_Pressed");
                break;
                case KeyboardHandler.KeyMap.TAB:
                display_unit.tab_navigate ();
                add_cell_button.get_style_context ().remove_class ("pebbles_button_prompt");
                break;
                case KeyboardHandler.KeyMap.SHIFT_TAB:
                display_unit.shift_tab_navigate ();
                add_cell_button.get_style_context ().remove_class ("pebbles_button_prompt");
                break;
                case KeyboardHandler.KeyMap.DELETE:
                display_unit.display_off ();
                display_unit.clear_cell ();
                add_cell_button.get_style_context ().remove_class ("pebbles_button_prompt");
                break;
                case KeyboardHandler.KeyMap.PAGE_UP:
                display_unit.display_off ();
                display_unit.insert_cell (true);
                add_cell_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                add_cell_button.get_style_context ().remove_class ("pebbles_button_prompt");
                break;
                case KeyboardHandler.KeyMap.PAGE_DOWN:
                display_unit.display_off ();
                display_unit.insert_cell (false);
                add_cell_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                add_cell_button.get_style_context ().remove_class ("pebbles_button_prompt");
                break;
                case KeyboardHandler.KeyMap.MINUS_NUMPAD:
                display_unit.insert_text ("-");
                negative_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_HOME:
                display_unit.display_off ();
                display_unit.remove_cell ();
                remove_cell_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;

                case KeyboardHandler.KeyMap.NAV_LEFT:
                display_unit.navigate_left ();
                break;
                case KeyboardHandler.KeyMap.NAV_RIGHT:
                display_unit.navigate_right ();
                break;

                // Function Buttons
                case KeyboardHandler.KeyMap.N_LOWER:
                case KeyboardHandler.KeyMap.N_UPPER:
                display_unit.set_result_type (2);
                display_unit.set_answer_label (display_unit.get_cardinality ().to_string ());
                display_unit.display_off ();
                cardinality_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.O_LOWER:
                case KeyboardHandler.KeyMap.O_UPPER:
                display_unit.set_result_type (3);
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.mode (display_unit.get_samples ()));
                display_unit.display_off ();
                statistical_mode_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.E_LOWER:
                case KeyboardHandler.KeyMap.E_UPPER:
                display_unit.set_result_type (1);
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.median (display_unit.get_samples ()));
                display_unit.display_off ();
                median_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.S_LOWER:
                case KeyboardHandler.KeyMap.S_UPPER:
                display_unit.set_result_type (4);
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.summation_x (display_unit.get_samples ()));
                display_unit.display_off ();
                summation_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.Q_LOWER:
                case KeyboardHandler.KeyMap.Q_UPPER:
                display_unit.set_result_type (5);
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.summation_x_square (display_unit.get_samples ()));
                display_unit.display_off ();
                summation_sq_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.V_LOWER:
                case KeyboardHandler.KeyMap.V_UPPER:
                if (!ctrl_held) {
                    display_unit.set_result_type (10);
                    Statistics stat_calc = new Statistics(decimal_places);
                    display_unit.set_answer_label (stat_calc.sample_variance (display_unit.get_samples ()));
                    display_unit.display_off ();
                    sample_variance_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                }
                break;
                case KeyboardHandler.KeyMap.M_LOWER:
                case KeyboardHandler.KeyMap.M_UPPER:
                display_unit.set_result_type (6);
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.mean_x (display_unit.get_samples ()));
                display_unit.display_off ();
                mean_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.A_LOWER:
                case KeyboardHandler.KeyMap.A_UPPER:
                display_unit.set_result_type (7);
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.mean_x_square (display_unit.get_samples ()));
                display_unit.display_off ();
                mean_sq_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.D_LOWER:
                case KeyboardHandler.KeyMap.D_UPPER:
                display_unit.set_result_type (11);
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.sample_standard_deviation (display_unit.get_samples ()));
                display_unit.display_off ();
                sample_std_dev_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.C_UPPER:
                case KeyboardHandler.KeyMap.C_LOWER:
                if (ctrl_held) {
                    display_unit.write_answer_to_clipboard ();
                }
                break;
                case KeyboardHandler.KeyMap.G_LOWER:
                case KeyboardHandler.KeyMap.G_UPPER:
                display_unit.set_result_type (0);
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.geometric_mean (display_unit.get_samples ()));
                display_unit.display_off ();
                geometric_mean_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.P_LOWER:
                case KeyboardHandler.KeyMap.P_UPPER:
                display_unit.set_result_type (9);
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.population_variance (display_unit.get_samples ()));
                display_unit.display_off ();
                pop_variance_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.L_LOWER:
                case KeyboardHandler.KeyMap.L_UPPER:
                display_unit.set_result_type (8);
                Statistics stat_calc = new Statistics(decimal_places);
                display_unit.set_answer_label (stat_calc.population_standard_deviation (display_unit.get_samples ()));
                display_unit.display_off ();
                pop_std_dev_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_END:
                display_unit.display_off ();
                display_unit.reset_sample ();
                reset_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
            }
        }
        public void key_released (Gdk.EventKey event) {
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
            negative_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            memory_plus_button.get_style_context ().remove_class ("Pebbles_Buttons_Memory_Pressed");
            memory_minus_button.get_style_context ().remove_class ("Pebbles_Buttons_Memory_Pressed");
            memory_recall_button.get_style_context ().remove_class ("Pebbles_Buttons_Memory_Pressed");
            memory_clear_button.get_style_context ().remove_class ("Pebbles_Buttons_Memory_Pressed");
            add_cell_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            nav_left_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            nav_right_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            all_clear_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            remove_cell_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");

            cardinality_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            statistical_mode_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            median_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            summation_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            summation_sq_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            sample_variance_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            mean_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            mean_sq_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            sample_std_dev_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            geometric_mean_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            pop_variance_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            pop_std_dev_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            reset_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");

            display_unit.set_editable_cell ();
            display_unit.display_on ();
            if (event.keyval == KeyboardHandler.KeyMap.CTRL) {
                ctrl_held = false;
            }
        }
    }
}
