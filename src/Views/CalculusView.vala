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
    public class CalculusView : Gtk.Grid {
        // Reference of main window
        public MainWindow window;

        // Fake LCD display
        Gtk.Box display_container;
        public CalculusDisplay display_unit;

        // Input section left side
        Gtk.Grid button_container_left;

        // Input section right side
        Gtk.Grid button_container_right;

        // Input section left buttons
        StyledButton all_clear_button;
        Gtk.Button   del_button;
        StyledButton variable_button;
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
        StyledButton pow_root_button;
        StyledButton memory_plus_button;
        StyledButton sin_button;
        StyledButton sinh_button;
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
        public StyledButton last_answer_button;
        StyledButton integration_button;
        StyledButton derivation_button;

        Gtk.Entry int_limit_a;
        Gtk.Entry int_limit_b;
        Gtk.Entry int_limit_x;

        CommonNumericKeypad keypad_a;
        CommonNumericKeypad keypad_b;
        CommonNumericKeypad keypad_x;
        // App Settings
        Pebbles.Settings settings;
        string constant_label_1 = "";
        string constant_desc_1 = "";
        string constant_label_2 = "";
        string constant_desc_2 = "";

        // Button Leaflet
        public Hdy.Leaflet button_leaflet;

        // Toolbar
        Gtk.Revealer bottom_button_bar_revealer;
        public StyledButton toolbar_angle_mode_button;
        StyledButton toolbar_int_der_func_button;
        public StyledButton toolbar_shift_button;

        public int integral_accuracy { get; set; }

        Gtk.Entry editable_entry;

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


        public bool shift_held = false;
        private bool ctrl_held = false;

        public CalculusView (MainWindow window) {
            this.window = window;
            load_constant_button_settings ();
            // Make UI
            cal_make_ui ();
            cal_make_events ();
        }
        construct {
            halign = Gtk.Align.FILL;
            valign = Gtk.Align.FILL;
            column_spacing = 1;
            height_request = 400;
        }
        private void cal_make_ui () {
            // Make Fake LCD display
            display_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            display_container.height_request = 138;
            display_container.margin_start = 8;
            display_container.margin_end = 8;
            display_container.margin_top = 8;
            display_container.margin_bottom = 8;
            display_container.vexpand = true;
            display_unit = new CalculusDisplay (this);
            display_container.pack_start (display_unit);
            display_unit.button_release_event.connect (() => {
                this.editable_entry = display_unit.input_entry;
                display_unit.input_entry.grab_focus_without_selecting ();
                return false;
            });
            this.editable_entry = display_unit.input_entry;

            // Make Input section on the left
            button_container_left = new Gtk.Grid ();
            button_container_left.height_request = 250;
            button_container_left.width_request = 256;
            button_container_left.margin_start = 8;
            button_container_left.margin_end = 8;
            button_container_left.margin_bottom = 8;
            button_container_left.column_spacing = 8;
            button_container_left.row_spacing = 8;
            button_container_left.vexpand = true;

            // Make Input section on the right
            button_container_right = new Gtk.Grid ();
            button_container_right.height_request = 250;
            button_container_right.width_request = 256;
            button_container_right.margin_start = 8;
            button_container_right.margin_end = 8;
            button_container_right.margin_bottom = 8;
            button_container_right.column_spacing = 8;
            button_container_right.row_spacing = 8;
            button_container_right.vexpand = true;

            // Make buttons on the left
            all_clear_button = new StyledButton ("AC", _("All Clear"), {"Delete"});
            all_clear_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            del_button = new Gtk.Button.from_icon_name ("edit-clear-symbolic", Gtk.IconSize.BUTTON);
            del_button.set_tooltip_text (_("Backspace"));
            del_button.get_style_context ().remove_class ("image-button");
            if (display_unit.input_entry.get_text () =="0" || display_unit.input_entry.get_text () == "") {
                del_button.sensitive = false;
            } else {
                del_button.sensitive = true;
            }
            display_unit.input_entry.changed.connect (() => {
                if (display_unit.input_entry.get_text () == "0" || display_unit.input_entry.get_text () == "")
                    del_button.sensitive = false;
                else
                    del_button.sensitive = true;
            });
            variable_button = new StyledButton ("𝑥", _("Variable for linear expressions"), {"X"});
            divide_button = new StyledButton ("\xC3\xB7", _("Divide"));
            divide_button.get_style_context ().add_class ("h3");
            seven_button = new StyledButton ("7");
            eight_button = new StyledButton ("8");
            nine_button = new StyledButton ("9");
            multiply_button = new StyledButton ("\xC3\x97", _("Multiply"));
            multiply_button.get_style_context ().add_class ("h3");
            four_button = new StyledButton ("4");
            five_button = new StyledButton ("5");
            six_button = new StyledButton ("6");
            subtract_button = new StyledButton ("\xE2\x88\x92", _("Subtract"));
            subtract_button.get_style_context ().add_class ("h3");
            one_button = new StyledButton ("1");
            two_button = new StyledButton ("2");
            three_button = new StyledButton ("3");
            plus_button = new StyledButton ("+", _("Add"));
            plus_button.get_style_context ().add_class ("h3");
            zero_button = new StyledButton ("0");
            decimal_button = new StyledButton (Utils.get_local_radix_symbol ());
            left_parenthesis_button = new StyledButton ("(");
            right_parenthesis_button = new StyledButton (")");

            button_container_left.attach (all_clear_button, 0, 0, 1, 1);
            button_container_left.attach (del_button, 1, 0, 1, 1);
            button_container_left.attach (variable_button, 2, 0, 1, 1);
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
            pow_root_button = new StyledButton ("x<sup>y</sup>", _("x raised to the power y"), {"Z"});
            pow_root_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            memory_plus_button = new StyledButton ("M+", _("Add it to the value in Memory"), {"F3"});
            memory_plus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            sin_button = new StyledButton ("sin", _("Sine"), {"S"});
            sin_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            sinh_button = new StyledButton ("sinh", _("Hyperbolic Sine"), {"H"});
            sinh_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            memory_minus_button = new StyledButton ("M\xE2\x88\x92", _("Subtract it from the value in Memory"), {"F4"});
            memory_minus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            cos_button = new StyledButton ("cos", _("Cosine"), {"C"});
            cos_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            cosh_button = new StyledButton ("cosh", _("Hyperbolic Cosine"), {"O"});
            cosh_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            log_mod_button = new StyledButton ("Mod", _("Modulus"), {"M"});
            log_mod_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            memory_recall_button = new StyledButton ("MR", _("Recall value from Memory"), {"F5"});
            memory_recall_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            tan_button = new StyledButton ("tan", _("Tangent"), {"T"});
            tan_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            tanh_button = new StyledButton ("tanh", _("Hyperbolic Tangent"), {"A"});
            tanh_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            perm_comb_button = new StyledButton ("<sup>n</sup>P\xE1\xB5\xA3", _("Permutations"), {"P"});
            perm_comb_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            memory_clear_button = new StyledButton ("MC", _("Memory Clear"), {"F6"});
            memory_clear_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            fact_button = new StyledButton ("!", _("Factorial"), {"F"});
            fact_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            constant_button = new StyledButton (constant_label_1, constant_desc_1, {"R"});
            constant_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            last_answer_button = new StyledButton ("Ans", _("Last answer"), {"F7"});
            last_answer_button.sensitive = false;
            last_answer_button.get_style_context ().add_class ("Pebbles_Buttons_Function");

            // Make integration section
            var integration_grid = new Gtk.Grid ();
            integration_grid.get_style_context ().add_class ("calculus-button-grid");
            integration_grid.get_style_context ().add_class ("Pebbles_Buttons_Function");
            integration_grid.set_row_homogeneous (true);
            integration_button = new StyledButton ("\xE2\x88\xAB", _("Definite Integral (Upper limit 'u' and Lower limit 'l')"), {"I"});
            integration_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            integration_button.get_style_context ().add_class ("suggested-override");
            integration_button.margin_top = 5;
            integration_button.margin_start = 2;

            int_limit_a = new Gtk.Entry ();
            int_limit_a.button_release_event.connect (() => {
                this.editable_entry = int_limit_a;
                return false;
            });
            int_limit_a.get_style_context ().add_class ("Pebbles_Small_Entry");
            int_limit_a.max_width_chars = 4;
            int_limit_a.width_chars = 4;
            int_limit_a.margin_start = 5;
            int_limit_a.margin_top = 5;
            int_limit_a.set_hexpand (true);
            int_limit_a.placeholder_text = "u";
            int_limit_a.set_text (settings.cal_integration_upper_limit);
            int_limit_a.changed.connect (() => {
                settings.cal_integration_upper_limit = int_limit_a.get_text ();
            });

            int_limit_b = new Gtk.Entry ();
            int_limit_b.button_release_event.connect (() => {
                this.editable_entry = int_limit_b;
                return false;
            });
            int_limit_b.get_style_context ().add_class ("Pebbles_Small_Entry");
            int_limit_b.max_width_chars = 4;
            int_limit_b.width_chars = 4;
            int_limit_b.margin_start = 5;
            int_limit_b.margin_top = 5;
            int_limit_b.set_hexpand (true);
            int_limit_b.placeholder_text = "l";
            int_limit_b.set_text (settings.cal_integration_lower_limit);
            int_limit_b.changed.connect (() => {
                settings.cal_integration_lower_limit = int_limit_b.get_text ();
            });

            integration_grid.attach (integration_button,            0, 0, 1, 1);
            integration_grid.attach (int_limit_a,                   1, 0, 1, 1);
            integration_grid.attach (int_limit_b,                   2, 0, 1, 1);
            int_limit_a.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY,"view-more-symbolic");
            int_limit_b.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY,"view-more-symbolic");
            keypad_a = new CommonNumericKeypad (int_limit_a);
            keypad_b = new CommonNumericKeypad (int_limit_b);
            int_limit_a.icon_release.connect (() => {
                keypad_a.set_visible (true);
            });
            int_limit_b.icon_release.connect (() => {
                keypad_b.set_visible (true);
            });

            // Make derivation section
            var derivation_grid = new Gtk.Grid ();
            derivation_grid.get_style_context ().add_class ("calculus-button-grid");
            derivation_grid.get_style_context ().add_class ("Pebbles_Buttons_Function");
            derivation_grid.set_row_homogeneous (true);
            derivation_grid.set_column_homogeneous (true);
            derivation_grid.set_halign (Gtk.Align.FILL);
            derivation_button = new StyledButton ("dy/dx", _("Derivative (at a point x)"), {"D"});
            derivation_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            derivation_button.get_style_context ().add_class ("suggested-override");
            derivation_button.margin_top = 5;
            derivation_button.margin_start = 2;

            int_limit_x = new Gtk.Entry ();
            int_limit_x.button_release_event.connect (() => {
                this.editable_entry = int_limit_x;
                return false;
            });
            int_limit_x.get_style_context ().add_class ("Pebbles_Small_Entry");
            int_limit_x.max_width_chars = 6;
            int_limit_x.width_chars = 6;
            int_limit_x.margin_start = 7;
            int_limit_x.margin_top = 5;
            int_limit_x.placeholder_text = "at x";
            int_limit_x.set_text (settings.cal_derivation_limit);
            int_limit_x.changed.connect (() => {
                settings.cal_derivation_limit = int_limit_x.get_text ();
            });

            derivation_grid.attach (derivation_button,              0, 0, 1, 1);
            derivation_grid.attach (int_limit_x,                    1, 0, 1, 1);
            int_limit_x.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY,"view-more-symbolic");
            keypad_x = new CommonNumericKeypad (int_limit_x);
            int_limit_x.icon_release.connect (() => {
                keypad_x.set_visible (true);
            });

            button_container_right.attach (sin_button,              0, 0, 1, 1);
            button_container_right.attach (sinh_button,             1, 0, 1, 1);
            button_container_right.attach (pow_root_button,         2, 0, 1, 1);
            button_container_right.attach (memory_plus_button,      3, 0, 1, 1);
            button_container_right.attach (cos_button,              0, 1, 1, 1);
            button_container_right.attach (cosh_button,             1, 1, 1 ,1);
            button_container_right.attach (log_mod_button,          2, 1, 1, 1);
            button_container_right.attach (memory_minus_button,     3, 1, 1, 1);
            button_container_right.attach (tan_button,              0, 2, 1, 1);
            button_container_right.attach (tanh_button,             1, 2, 1, 1);
            button_container_right.attach (perm_comb_button,        2, 2, 1, 1);
            button_container_right.attach (memory_recall_button,    3, 2, 1, 1);
            button_container_right.attach (fact_button,             0, 3, 1, 1);
            button_container_right.attach (constant_button,         1, 3, 1, 1);
            button_container_right.attach (last_answer_button,      2, 3, 1, 1);
            button_container_right.attach (memory_clear_button,     3, 3, 1, 1);
            button_container_right.attach (integration_grid,        0, 4, 2, 1);
            button_container_right.attach (derivation_grid,         2, 4, 2, 1);

            button_container_right.set_column_homogeneous (true);
            button_container_right.set_row_homogeneous (true);

            button_leaflet = new Hdy.Leaflet ();
            button_leaflet.add (button_container_left);
            button_leaflet.add (button_container_right);
            button_leaflet.set_visible_child (button_container_left);
            button_leaflet.hhomogeneous_unfolded = true;
            button_leaflet.can_swipe_back = true;
            button_leaflet.can_swipe_forward = true;

            bottom_button_bar_revealer = new Gtk.Revealer ();
            var bottom_toolbar = new Gtk.ActionBar ();
            bottom_toolbar.height_request = 40;

            toolbar_int_der_func_button = new StyledButton ("d/dx \xE2\x88\xAB<i> ƒ(x) dx</i>", _("Other functions, integration and differentiation"));
            toolbar_int_der_func_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            toolbar_int_der_func_button.halign = Gtk.Align.CENTER;
            toolbar_int_der_func_button.hexpand = true;

            toolbar_shift_button = new StyledButton (_("Shift"), _("Access alternative functions"));
            toolbar_shift_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            toolbar_shift_button.halign = Gtk.Align.START;
            toolbar_shift_button.width_request = 46;

            toolbar_angle_mode_button = new StyledButton ("DEG", "<b>" + _("Degrees") + "</b> \xE2\x86\x92" + _("Radians"), {"F8"});
            toolbar_angle_mode_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            toolbar_angle_mode_button.halign = Gtk.Align.END;
            toolbar_angle_mode_button.width_request = 46;

            bottom_button_bar_revealer.add (bottom_toolbar);
            bottom_button_bar_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;

            var toolbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
            toolbox.set_homogeneous (true);
            toolbox.pack_start (toolbar_shift_button);
            toolbox.pack_start (toolbar_int_der_func_button);
            toolbox.pack_end (toolbar_angle_mode_button);
            toolbox.margin = 8;
            toolbox.margin_start = 4;
            toolbox.margin_end = 4;

            bottom_toolbar.pack_start (toolbox);

            // Put it together
            attach (display_container,          0, 0, 1, 1);
            attach (button_leaflet,             0, 1, 1, 1);
            attach (bottom_button_bar_revealer, 0, 2, 1, 1);
            set_column_homogeneous (true);
            display_unit.input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
        }
        public void hold_shift (bool hold) {
            shift_held = hold;
            display_unit.set_shift_enable (hold);
            set_alternative_button ();
        }
        public void set_alternative_button () {
            if (shift_held) {
                pow_root_button.update_label ("<sup>n</sup>\xE2\x88\x9A", _("nth root over number"), {"Z"});
                sin_button.update_label ("sin<sup>-1</sup>", _("Inverse Sine"), {"S"});
                sinh_button.update_label ("sinh<sup>-1</sup>", _("Inverse Hyperbolic Sine"), {"H"});
                cos_button.update_label ("cos<sup>-1</sup>", _("Inverse Cosine"), {"C"});
                cosh_button.update_label ("cosh<sup>-1</sup>", _("Inverse Hyperbolic Cosine"), {"O"});
                log_mod_button.update_label ("log\xE2\x82\x93y", _("Log base x"), {"M"});
                tan_button.update_label ("tan<sup>-1</sup>", _("Inverse Tangent"), {"T"});
                tanh_button.update_label ("tanh<sup>-1</sup>", _("Inverse Hyperbolic Tangent"), {"A"});
                perm_comb_button.update_label ("<sup>n</sup>C\xE1\xB5\xA3", _("Combinations"), {"P"});
                constant_button.update_label (constant_label_2, constant_desc_2, {"R"});
            }
            else {
                pow_root_button.update_label ("x<sup>y</sup>", _("x raised to the power y"), {"Z"});
                sin_button.update_label ("sin", _("Sine"), {"S"});
                sinh_button.update_label ("sinh", _("Hyperbolic Sine"), {"H"});
                cos_button.update_label ("cos", _("Cosine"), {"C"});
                cosh_button.update_label ("cosh", _("Hyperbolic Cosine"), {"O"});
                log_mod_button.update_label ("Mod", _("Modulus"), {"M"});
                tan_button.update_label ("tan", _("Tangent"), {"T"});
                tanh_button.update_label ("tanh", _("Hyperbolic Tangent"), {"A"});
                perm_comb_button.update_label ("<sup>n</sup>P\xE1\xB5\xA3", _("Permutations"), {"P"});
                constant_button.update_label (constant_label_1, constant_desc_1, {"R"});
            }
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
        public void load_constant_button_settings () {
            settings = Pebbles.Settings.get_default ();
            switch (settings.constant_key_value1) {
                case ConstantKeyIndex.ARCHIMEDES:
                    constant_label_1 = "\xCF\x80";
                    constant_desc_1 = _("Archimedes' constant (pi)");
                    break;
                case ConstantKeyIndex.PARABOLIC:
                    constant_label_1 = "\xF0\x9D\x91\x83";
                    constant_desc_1 = _("Parabolic constant (\xF0\x9D\x91\x83)");
                    break;
                case ConstantKeyIndex.GOLDEN_RATIO:
                    constant_label_1 = "\xCF\x86";
                    constant_desc_1 = _("Golden ratio (phi)");
                    break;
                case ConstantKeyIndex.EULER_MASCH:
                    constant_label_1 = "\xF0\x9D\x9B\xBE";
                    constant_desc_1 = _("Euler–Mascheroni constant (gamma)");
                    break;
                case ConstantKeyIndex.CONWAY:
                    constant_label_1 = "\xCE\xBB";
                    constant_desc_1 = _("Conway's constant (lambda)");
                    break;
                case ConstantKeyIndex.KHINCHIN:
                    constant_label_1 = "K";
                    constant_desc_1 = _("Khinchin's constant");
                    break;
                case ConstantKeyIndex.FEIGEN_ALPHA:
                    constant_label_1 = "\xCE\xB1";
                    constant_desc_1 = _("The Feigenbaum constant alpha");
                    break;
                case ConstantKeyIndex.FEIGEN_DELTA:
                    constant_label_1 = "\xCE\xB4";
                    constant_desc_1 = _("The Feigenbaum constant delta");
                    break;
                case ConstantKeyIndex.APERY:
                    constant_label_1 = "\xF0\x9D\x9B\x87(3)";
                    constant_desc_1 = _("Apery's constant");
                    break;
                default:
                    constant_label_1 = "e";
                    constant_desc_1 = _("Euler's constant (exponential)");
                    break;
            }
            switch (settings.constant_key_value2) {
                case ConstantKeyIndex.ARCHIMEDES:
                    constant_label_2 = "\xCF\x80";
                    constant_desc_2 = _("Archimedes' constant (pi)");
                    break;
                case ConstantKeyIndex.PARABOLIC:
                    constant_label_2 = "\xF0\x9D\x91\x83";
                    constant_desc_2 = _("Parabolic constant (\xF0\x9D\x91\x83)");
                    break;
                case ConstantKeyIndex.GOLDEN_RATIO:
                    constant_label_2 = "\xCF\x86";
                    constant_desc_2 = _("Golden ratio (phi)");
                    break;
                case ConstantKeyIndex.EULER_MASCH:
                    constant_label_2 = "\xF0\x9D\x9B\xBE";
                    constant_desc_2 = _("Euler–Mascheroni constant (gamma)");
                    break;
                case ConstantKeyIndex.CONWAY:
                    constant_label_2 = "\xCE\xBB";
                    constant_desc_2 = _("Conway's constant (lambda)");
                    break;
                case ConstantKeyIndex.KHINCHIN:
                    constant_label_2 = "K";
                    constant_desc_2 = _("Khinchin's constant");
                    break;
                case ConstantKeyIndex.FEIGEN_ALPHA:
                    constant_label_2 = "\xCE\xB1";
                    constant_desc_2 = _("The Feigenbaum constant alpha");
                    break;
                case ConstantKeyIndex.FEIGEN_DELTA:
                    constant_label_2 = "\xCE\xB4";
                    constant_desc_2 = _("The Feigenbaum constant delta");
                    break;
                case ConstantKeyIndex.APERY:
                    constant_label_2 = "\xF0\x9D\x9B\x87(3)";
                    constant_desc_2 = _("Apery's constant");
                    break;
                default:
                    constant_label_2 = "e";
                    constant_desc_2 = _("Euler's constant (exponential)");
                    break;
            }
            if (constant_button != null) {
                set_alternative_button ();
            }
        }
        private void cal_make_events () {
            this.size_allocate.connect ((event) => {
                if (button_leaflet.folded) {
                    bottom_button_bar_revealer.set_reveal_child (true);
                } else {
                    bottom_button_bar_revealer.set_reveal_child (false);
                }
            });
            toolbar_int_der_func_button.clicked.connect (() => {
                toggle_leaf ();
            });
            derivation_button.button_press_event.connect ((event) => {
                if (event.button == 1) {
                    display_unit.display_off ();
                    string? limit = int_limit_x.get_text();
                    if (limit == "") {
                        display_unit.get_answer_evaluate_derivative (0.0);
                    }
                    else {
                        display_unit.get_answer_evaluate_derivative (double.parse (limit));
                    }

                    if (display_unit.input_entry.get_text ().length == 0 && display_unit.input_entry.get_text () != "0") {
                        display_unit.input_entry.set_text ("0");
                    }
                    display_unit.input_entry.grab_focus_without_selecting ();
                    if (display_unit.input_entry.cursor_position < display_unit.input_entry.get_text ().length)
                        display_unit.input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                }
                return false;
            });
            derivation_button.button_release_event.connect (() => {
                display_unit.display_on ();
                return false;
            });
            integration_button.button_press_event.connect ((event) => {
                if (event.button == 1) {
                    display_unit.display_off ();
                    string? limit_u = int_limit_a.get_text ();
                    string? limit_l = int_limit_b.get_text ();
                    if (limit_u == "" && limit_l == "") {
                        display_unit.get_answer_evaluate_integral (0, 1);
                    }
                    else if (limit_u == "" && limit_l != "") {
                        display_unit.get_answer_evaluate_integral (double.parse (limit_l), 1);
                    }
                    else if (limit_u != "" && limit_l == "") {
                        display_unit.get_answer_evaluate_integral (0, double.parse (limit_u));
                    }
                    else {
                        display_unit.get_answer_evaluate_integral (double.parse (limit_l), double.parse (limit_u));
                    }

                    if (display_unit.input_entry.get_text ().length == 0 && display_unit.input_entry.get_text () != "0") {
                        display_unit.input_entry.set_text ("0");
                    }
                    display_unit.input_entry.grab_focus_without_selecting ();
                    if (display_unit.input_entry.cursor_position < display_unit.input_entry.get_text ().length)
                        display_unit.input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                }
                return false;
            });
            integration_button.button_release_event.connect (() => {
                display_unit.display_on ();
                return false;
            });

            all_clear_button.clicked.connect (() => {
                display_unit.input_entry.grab_focus_without_selecting ();
                display_unit.input_entry.set_text ("0");
                display_unit.input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
            });
            del_button.clicked.connect (() => {
                display_unit.input_entry.grab_focus_without_selecting ();
                display_unit.input_entry.backspace ();
            });
            variable_button.clicked.connect (() => {
                display_unit.insert_text ("x");
            });
            divide_button.clicked.connect (() => {
                display_unit.insert_text (" ÷ ");
            });
            seven_button.clicked.connect (() => {
                display_unit.insert_text ("7");
            });
            eight_button.clicked.connect (() => {;
                display_unit.insert_text ("8");
            });
            nine_button.clicked.connect (() => {;
                display_unit.insert_text ("9");
            });
            multiply_button.clicked.connect (() => {;
                display_unit.insert_text (" × ");
            });
            four_button.clicked.connect (() => {;
                display_unit.insert_text ("4");
            });
            five_button.clicked.connect (() => {;
                display_unit.insert_text ("5");
            });
            six_button.clicked.connect (() => {;
                display_unit.insert_text ("6");
            });
            subtract_button.clicked.connect (() => {;
                display_unit.insert_text (" - ");
            });
            one_button.clicked.connect (() => {;
                display_unit.insert_text ("1");
            });
            two_button.clicked.connect (() => {;
                display_unit.insert_text ("2");
            });
            three_button.clicked.connect (() => {;
                display_unit.insert_text ("3");
            });
            plus_button.clicked.connect (() => {;
                display_unit.insert_text (" + ");
            });
            zero_button.clicked.connect (() => {;
                display_unit.insert_text ("0");
            });
            decimal_button.clicked.connect (() => {;
                display_unit.insert_text (Utils.get_local_radix_symbol ());
            });
            left_parenthesis_button.clicked.connect (() => {;
                display_unit.insert_text ("( ");
            });
            right_parenthesis_button.clicked.connect (() => {;
                display_unit.insert_text (") ");
            });

            pow_root_button.clicked.connect (() => {
                if (shift_held)
                    display_unit.insert_text ("\xE2\x81\xBF√ ");
                else
                    display_unit.insert_text ("^ ");
            });
            sin_button.clicked.connect (() => {
                if (shift_held)
                    display_unit.insert_text ("isin ");
                else
                    display_unit.insert_text ("sin ");
            });
            sinh_button.clicked.connect (() => {
                if (shift_held)
                    display_unit.insert_text ("isinh ");
                else
                    display_unit.insert_text ("sinh ");
            });
            cos_button.clicked.connect (() => {
                if (shift_held)
                    display_unit.insert_text ("icos ");
                else
                    display_unit.insert_text ("cos ");
            });
            cosh_button.clicked.connect (() => {
                if (shift_held)
                    display_unit.insert_text ("icosh ");
                else
                    display_unit.insert_text ("cosh ");
            });
            tan_button.clicked.connect (() => {
                if (shift_held)
                    display_unit.insert_text ("itan ");
                else
                    display_unit.insert_text ("tan ");
            });
            tanh_button.clicked.connect (() => {
                if (shift_held)
                    display_unit.insert_text ("itanh ");
                else
                    display_unit.insert_text ("tanh ");
            });
            perm_comb_button.clicked.connect (() => {
                if (shift_held)
                    display_unit.insert_text ("C");
                else
                    display_unit.insert_text ("P");
            });
            fact_button.clicked.connect (() => {
                display_unit.insert_text ("!");
            });
            constant_button.clicked.connect (() => {
                if (shift_held)
                    display_unit.insert_text (constant_label_2);
                else
                    display_unit.insert_text (constant_label_1);
            });
            log_mod_button.clicked.connect (() => {
                if (shift_held)
                    display_unit.insert_text ("log ");
                else
                    display_unit.insert_text ("mod ");
            });

            memory_plus_button.button_press_event.connect ((event) => {
                if (event.button == 1) {
                    display_unit.display_off ();
                    if (display_unit.input_entry.get_text ().length == 0 && display_unit.input_entry.get_text () != "0") {
                        display_unit.input_entry.set_text ("0");
                    }
                    display_unit.input_entry.grab_focus_without_selecting ();
                    if (display_unit.input_entry.cursor_position < display_unit.input_entry.get_text ().length)
                        display_unit.input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                    if (display_unit.answer_label.get_text () != "E") {
                        var res = display_unit.answer_label.get_text ();
                        res = res.replace (Utils.get_local_separator_symbol (), "");
                        memory_reserve += double.parse (res);
                    }
                }
                return false;
            });
            memory_plus_button.button_release_event.connect (() => {
                display_unit.display_on ();
                return false;
            });

            memory_minus_button.button_press_event.connect ((event) => {
                if (event.button == 1) {
                    display_unit.display_off ();
                    if (display_unit.input_entry.get_text ().length == 0 && display_unit.input_entry.get_text () != "0") {
                        display_unit.input_entry.set_text ("0");
                    }
                    display_unit.input_entry.grab_focus_without_selecting ();
                    if (display_unit.input_entry.cursor_position < display_unit.input_entry.get_text ().length)
                        display_unit.input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                    if (display_unit.answer_label.get_text () != "E") {
                        var res = display_unit.answer_label.get_text ();
                        res = res.replace (Utils.get_local_separator_symbol (), "");
                        memory_reserve -= double.parse (res);
                    }
                }
                return false;
            });
            memory_minus_button.button_release_event.connect (() => {
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

            memory_recall_button.clicked.connect (() => {
                display_unit.insert_text (memory_reserve.to_string ());
            });

            last_answer_button.clicked.connect (() => {
                display_unit.insert_text ("ans ");
            });
            keypad_a.button_clicked.connect ((val) => {
                if (val == "C") {
                    int_limit_a.set_text ("");
                }
                else if (val == "del") {
                    int_limit_a.backspace ();
                }
                else if (val == "-") {
                    int_limit_a.grab_focus_without_selecting ();
                    string entry_text = int_limit_a.get_text ();
                    if (entry_text.contains ("-")) {
                        entry_text = entry_text.replace ("-", "");
                    } else {
                        entry_text = "-" + entry_text;
                    }
                    int_limit_a.set_text (entry_text);
                    int_limit_a.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                }
                else {
                    if (int_limit_a.get_text () == "0"){
                        int_limit_a.set_text("");
                    }
                    int_limit_a.insert_at_cursor (val);
                }
            });
            keypad_b.button_clicked.connect ((val) => {
                if (val == "C") {
                    int_limit_b.set_text ("");
                }
                else if (val == "del") {
                    int_limit_b.backspace ();
                }
                else if (val == "-") {
                    int_limit_b.grab_focus_without_selecting ();
                    string entry_text = int_limit_b.get_text ();
                    if (entry_text.contains ("-")) {
                        entry_text = entry_text.replace ("-", "");
                    } else {
                        entry_text = "-" + entry_text;
                    }
                    int_limit_b.set_text (entry_text);
                    int_limit_b.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                }
                else {
                    if (int_limit_b.get_text () == "0"){
                        int_limit_b.set_text("");
                    }
                    int_limit_b.insert_at_cursor (val);
                }
            });
            keypad_x.button_clicked.connect ((val) => {
                if (val == "C") {
                    int_limit_x.set_text ("");
                }
                else if (val == "del") {
                    int_limit_x.backspace ();
                }
                else if (val == "-") {
                    int_limit_x.grab_focus_without_selecting ();
                    string entry_text = int_limit_x.get_text ();
                    if (entry_text.contains ("-")) {
                        entry_text = entry_text.replace ("-", "");
                    } else {
                        entry_text = "-" + entry_text;
                    }
                    int_limit_x.set_text (entry_text);
                    int_limit_x.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                }
                else {
                    if (int_limit_x.get_text () == "0"){
                        int_limit_x.set_text("");
                    }
                    int_limit_x.insert_at_cursor (val);
                }
            });
            keypad_a.closed.connect (() => display_unit.input_entry.grab_focus_without_selecting ());
            keypad_b.closed.connect (() => display_unit.input_entry.grab_focus_without_selecting ());
            keypad_x.closed.connect (() => display_unit.input_entry.grab_focus_without_selecting ());
        }
        public void set_angle_mode_display (int state) {
            display_unit.set_angle_status (state);
        }

        public void send_backspace () {
            editable_entry.backspace ();
            if (editable_entry.get_text () == "") {
                editable_entry.set_text ("0");
                editable_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
            }
        }

        public void insert_text (string text) {
            if (editable_entry.get_text () == "0") {
                editable_entry.set_text ("");
            }
            if (text.contains ("-") && editable_entry != display_unit.input_entry) {
                editable_entry.grab_focus_without_selecting ();
                string entry_text = editable_entry.get_text ();
                if (entry_text.contains ("-")) {
                    entry_text = entry_text.replace ("-", "");
                } else {
                    entry_text = "-" + entry_text;
                }
                editable_entry.set_text (entry_text);
                editable_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
            } else {
                editable_entry.grab_focus_without_selecting ();
                editable_entry.insert_at_cursor (text);
            }
        }
        public void insert_text_to_main_entry (string text) {
            editable_entry = display_unit.input_entry;
            insert_text (text);
        }

        public void key_pressed (Gdk.EventKey event) {
            this.display_unit.input_entry.grab_focus_without_selecting ();
            if (event.keyval == KeyboardHandler.KeyMap.CTRL) {
                ctrl_held = true;
            }
            switch (event.keyval) {
                case KeyboardHandler.KeyMap.BACKSPACE:
                if (del_button.get_sensitive ()) {
                    this.send_backspace ();
                    del_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                }
                break;
                case KeyboardHandler.KeyMap.NUMPAD_7: // 7 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_7:
                this.insert_text ("7");
                seven_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_8: // 8 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_8:
                this.insert_text ("8");
                eight_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_9: // 9 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_9:
                this.insert_text ("9");
                nine_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_4: // 4 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_4:
                this.insert_text ("4");
                four_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_5: // 5 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_5:
                this.insert_text ("5");
                five_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_6: // 6 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_6:
                this.insert_text ("6");
                six_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_1: // 1 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_1:
                this.insert_text ("1");
                one_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_2: // 2 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_2:
                this.insert_text ("2");
                two_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_3: // 3 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_3:
                this.insert_text ("3");
                three_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_0: // 0 key numpad
                case KeyboardHandler.KeyMap.KEYPAD_0:
                this.insert_text ("0");
                zero_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.NUMPAD_RADIX:
                case KeyboardHandler.KeyMap.KEYPAD_RADIX:
                this.insert_text (Utils.get_local_radix_symbol ());
                decimal_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.X_LOWER:
                case KeyboardHandler.KeyMap.X_UPPER:
                display_unit.insert_text ("x");
                variable_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.DELETE:
                display_unit.input_entry.grab_focus_without_selecting ();
                display_unit.input_entry.set_text ("0");
                display_unit.input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                all_clear_button.get_style_context ().add_class ("Pebbles_Buttons_Destructive_Pressed");
                break;

                case KeyboardHandler.KeyMap.PLUS_NUMPAD:
                case KeyboardHandler.KeyMap.PLUS_KEYPAD:
                if (editable_entry == display_unit.input_entry)
                this.insert_text (" + ");
                plus_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.MINUS_NUMPAD:
                case KeyboardHandler.KeyMap.MINUS_KEYPAD:
                this.insert_text (" - ");
                subtract_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.SLASH_NUMPAD:
                case KeyboardHandler.KeyMap.SLASH_KEYPAD:
                if (editable_entry == display_unit.input_entry)
                this.insert_text (" ÷ ");
                divide_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.STAR_NUMPAD:
                case KeyboardHandler.KeyMap.STAR_KEYPAD:
                if (editable_entry == display_unit.input_entry)
                this.insert_text (" × ");
                multiply_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.PARENTHESIS_L:
                case KeyboardHandler.KeyMap.SQ_BRACKETS_L:
                case KeyboardHandler.KeyMap.FL_BRACKETS_L:
                left_parenthesis_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                display_unit.insert_text ("( ");
                break;
                case KeyboardHandler.KeyMap.PARENTHESIS_R:
                case KeyboardHandler.KeyMap.SQ_BRACKETS_R:
                case KeyboardHandler.KeyMap.FL_BRACKETS_R:
                right_parenthesis_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                display_unit.insert_text (" ) ");
                break;
                case KeyboardHandler.KeyMap.M_LOWER:
                display_unit.insert_text ("mod ");
                log_mod_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.M_UPPER:
                display_unit.insert_text ("log ");
                log_mod_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.PERCENTAGE:
                display_unit.insert_text ("%");
                break;

                // Function Buttons
                case KeyboardHandler.KeyMap.EXP_CAP:
                case KeyboardHandler.KeyMap.Z_LOWER:
                display_unit.insert_text ("^");
                pow_root_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.L_LOWER:
                display_unit.insert_text ("log\xE2\x82\x81\xE2\x82\x80 ");
                break;
                case KeyboardHandler.KeyMap.L_UPPER:
                display_unit.insert_text ("ln ");
                break;
                case KeyboardHandler.KeyMap.S_LOWER:
                display_unit.insert_text ("sin ");
                sin_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.C_LOWER:
                if (ctrl_held) {
                    display_unit.write_answer_to_clipboard ();
                } else {
                    display_unit.insert_text ("cos ");
                    cos_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                }
                break;
                case KeyboardHandler.KeyMap.T_LOWER:
                display_unit.insert_text ("tan ");
                tan_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.H_LOWER:
                display_unit.insert_text ("sinh ");
                sinh_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.O_LOWER:
                display_unit.insert_text ("cosh ");
                cosh_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.A_LOWER:
                display_unit.insert_text ("tanh ");
                tanh_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.S_UPPER:
                display_unit.insert_text ("isin ");
                sin_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.C_UPPER:
                display_unit.insert_text ("icos ");
                cos_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.T_UPPER:
                if (ctrl_held) {
                    display_unit.write_answer_to_clipboard ();
                } else {
                    display_unit.insert_text ("icos ");
                    cos_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                }
                break;
                case KeyboardHandler.KeyMap.H_UPPER:
                display_unit.insert_text ("isinh ");
                sinh_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.O_UPPER:
                display_unit.insert_text ("icosh ");
                cosh_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.A_UPPER:
                display_unit.insert_text ("itanh ");
                tanh_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.Q_LOWER:
                display_unit.insert_text ("^2 ");
                break;
                case KeyboardHandler.KeyMap.Q_UPPER:
                display_unit.insert_text ("√");
                break;
                case KeyboardHandler.KeyMap.P_LOWER:
                display_unit.insert_text ("P");
                perm_comb_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.P_UPPER:
                display_unit.insert_text ("C");
                perm_comb_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
                case KeyboardHandler.KeyMap.F_LOWER:
                case KeyboardHandler.KeyMap.F_UPPER:
                case KeyboardHandler.KeyMap.EXCLAMATION:
                display_unit.insert_text ("!");
                fact_button.get_style_context ().add_class ("Pebbles_Buttons_Pressed");
                break;
                case KeyboardHandler.KeyMap.R_LOWER:
                display_unit.insert_text (constant_label_1);
                break;
                case KeyboardHandler.KeyMap.R_UPPER:
                display_unit.insert_text (constant_label_2);
                break;
                case KeyboardHandler.KeyMap.Z_UPPER:
                display_unit.insert_text ("\xE2\x81\xBF√");
                break;
                case KeyboardHandler.KeyMap.W_LOWER:
                display_unit.insert_text ("10^");
                break;
                case KeyboardHandler.KeyMap.W_UPPER:
                display_unit.insert_text ("e^");
                break;

                case KeyboardHandler.KeyMap.I_UPPER:
                case KeyboardHandler.KeyMap.I_LOWER:
                {
                    display_unit.display_off ();
                    string? limit_u = int_limit_a.get_text ();
                    string? limit_l = int_limit_b.get_text ();
                    if (limit_u == "" && limit_l == "") {
                        display_unit.get_answer_evaluate_integral (0, 1);
                    }
                    else if (limit_u == "" && limit_l != "") {
                        display_unit.get_answer_evaluate_integral (double.parse (limit_l), 1);
                    }
                    else if (limit_u != "" && limit_l == "") {
                        display_unit.get_answer_evaluate_integral (0, double.parse (limit_u));
                    }
                    else {
                        display_unit.get_answer_evaluate_integral (double.parse (limit_l), double.parse (limit_u));
                    }

                    if (display_unit.input_entry.get_text ().length == 0 && display_unit.input_entry.get_text () != "0") {
                        display_unit.input_entry.set_text ("0");
                    }
                    display_unit.input_entry.grab_focus_without_selecting ();
                    if (display_unit.input_entry.cursor_position < display_unit.input_entry.get_text ().length)
                        display_unit.input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                }
                break;
                case KeyboardHandler.KeyMap.D_UPPER:
                case KeyboardHandler.KeyMap.D_LOWER:
                {
                    display_unit.display_off ();
                    string? limit = int_limit_x.get_text();
                    if (limit == "") {
                        display_unit.get_answer_evaluate_derivative (0.0);
                    }
                    else {
                        display_unit.get_answer_evaluate_derivative (double.parse (limit));
                    }

                    if (display_unit.input_entry.get_text ().length == 0 && display_unit.input_entry.get_text () != "0") {
                        display_unit.input_entry.set_text ("0");
                    }
                    display_unit.input_entry.grab_focus_without_selecting ();
                    if (display_unit.input_entry.cursor_position < display_unit.input_entry.get_text ().length)
                        display_unit.input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                }
                break;
                case KeyboardHandler.KeyMap.TAB:
                cycle_focus (false);
                break;
                case KeyboardHandler.KeyMap.SHIFT_TAB:
                cycle_focus (true);
                break;

                // Memory Buttons
                case KeyboardHandler.KeyMap.F3:
                display_unit.display_off ();
                display_unit.input_entry.grab_focus_without_selecting ();
                if (display_unit.answer_label.get_text () != "E" && display_unit.answer_label.get_text () != "0") {
                    var res = display_unit.answer_label.get_text ();
                    res = res.replace (Utils.get_local_separator_symbol (), "");
                    memory_reserve += double.parse (res);
                }
                memory_plus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory_Pressed");
                break;
                case KeyboardHandler.KeyMap.F4:
                display_unit.display_off ();
                display_unit.input_entry.grab_focus_without_selecting ();
                if (display_unit.answer_label.get_text () != "E" && display_unit.answer_label.get_text () != "0") {
                    var res = display_unit.answer_label.get_text ();
                    res = res.replace (Utils.get_local_separator_symbol (), "");
                    memory_reserve -= double.parse (res);
                }
                memory_minus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory_Pressed");
                break;
                case KeyboardHandler.KeyMap.F5:
                display_unit.insert_text (memory_reserve.to_string ());
                memory_recall_button.get_style_context ().add_class ("Pebbles_Buttons_Memory_Pressed");
                break;
                case KeyboardHandler.KeyMap.F6:
                display_unit.display_off ();
                memory_reserve = 0.0;
                memory_clear_button.get_style_context ().add_class ("Pebbles_Buttons_Memory_Pressed");
                break;
                case KeyboardHandler.KeyMap.F7:
                display_unit.insert_text ("ans ");
                last_answer_button.get_style_context ().add_class ("Pebbles_Buttons_Function_Pressed");
                break;
            }
        }

        public void key_released (Gdk.EventKey event) {
            display_unit.display_on ();
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
            variable_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");

            plus_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            subtract_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            divide_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            multiply_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");

            left_parenthesis_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            right_parenthesis_button.get_style_context ().remove_class ("Pebbles_Buttons_Pressed");
            fact_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");

            pow_root_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            log_mod_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            sin_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            cos_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            tan_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            sinh_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            cosh_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            tanh_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");
            perm_comb_button.get_style_context ().remove_class ("Pebbles_Buttons_Function_Pressed");

            memory_plus_button.get_style_context ().remove_class ("Pebbles_Buttons_Memory_Pressed");
            memory_minus_button.get_style_context ().remove_class ("Pebbles_Buttons_Memory_Pressed");
            memory_recall_button.get_style_context ().remove_class ("Pebbles_Buttons_Memory_Pressed");
            memory_clear_button.get_style_context ().remove_class ("Pebbles_Buttons_Memory_Pressed");
            if (event.keyval == KeyboardHandler.KeyMap.CTRL) {
                ctrl_held = false;
            }
        }

        private void cycle_focus (bool clockwise) {
            if (!clockwise) {
                if (display_unit.input_entry == editable_entry) {
                    editable_entry = int_limit_a;
                } else if (int_limit_a == editable_entry) {
                    editable_entry = int_limit_b;
                } else if (int_limit_b == editable_entry) {
                    editable_entry = int_limit_x;
                } else if (int_limit_x == editable_entry) {
                    editable_entry = display_unit.input_entry;
                }
            } else {
                if (display_unit.input_entry == editable_entry) {
                    editable_entry = int_limit_x;
                } else if (int_limit_x == editable_entry) {
                    editable_entry = int_limit_b;
                } else if (int_limit_b == editable_entry) {
                    editable_entry = int_limit_a;
                } else if (int_limit_a == editable_entry) {
                    editable_entry = display_unit.input_entry;
                }
            }
            editable_entry.grab_focus_without_selecting ();
        }

        public void set_evaluation (EvaluationResult result) {
            this.display_unit.set_evaluation (result);

            int_limit_a.set_text (result.int_limit_a.to_string ());
            int_limit_b.set_text (result.int_limit_b.to_string ());
            int_limit_x.set_text (result.derivative_point.to_string ());
        }

        public void insert_evaluation_result (EvaluationResult result) {
            ProgrammerCalculator prog_module = new ProgrammerCalculator ();
            string output = "";
            if (result.result_source == EvaluationResult.ResultSource.PROG) {
                switch (result.number_system) {
                    case NumberSystem.BINARY:
                    output = prog_module.convert_binary_to_decimal (result.result, result.word_length);
                    break;
                    case NumberSystem.OCTAL:
                    output = prog_module.convert_octal_to_decimal (result.result, result.word_length);
                    break;
                    case NumberSystem.HEXADECIMAL:
                    output = prog_module.convert_hexadecimal_to_decimal (result.result, result.word_length);
                    break;
                    default:
                    output = result.result;
                    break;
                }
            } else {
                output = result.result;
            }
            display_unit.insert_text (" " + output);
        }
    }
}
