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
    public class CalculusView : Gtk.Grid {
        Gtk.Label cal_placeholder;
        // Reference of main window
        public MainWindow window;

        // Fake LCD display
        Gtk.Box display_container;
        public Gtk.Entry display_unit;

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
        
        Gtk.Entry differential_value;
        
        // App Settings
        Pebbles.Settings settings;
        string constant_label_1 = "";
        string constant_desc_1 = "";
        string constant_label_2 = "";
        string constant_desc_2 = "";

        public CalculusView (MainWindow window) {
            this.window = window;
            
            // Make UI
            cal_make_ui ();
        }
        construct {
            halign = Gtk.Align.CENTER;
            valign = Gtk.Align.CENTER;
        }
        private void cal_make_ui () {
            // Make Fake LCD display
            display_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            display_container.height_request = 120;
            display_container.width_request = 560;
            display_container.margin_start = 8;
            display_container.margin_end = 8;
            display_container.margin_top = 8;
            display_container.margin_bottom = 8;
            display_unit = new Gtk.Entry ();
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
            /*display_unit.input_entry.changed.connect (() => {
                if (display_unit.input_entry.get_text () == "0" || display_unit.input_entry.get_text () == "")
                    del_button.sensitive = false;
                else
                    del_button.sensitive = true;
            });*/
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
            pow_root_button = new StyledButton ("x<sup>y</sup>", "x raised to the power y");
            pow_root_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            memory_plus_button = new StyledButton ("M+", "Add it to the value in Memory");
            memory_plus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            sin_button = new StyledButton ("sin", "Sine");
            sin_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            sinh_button = new StyledButton ("sinh", "Hyperbolic Sine");
            sinh_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
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
            
            // Make integration section
            var integration_grid = new Gtk.Grid ();
            integration_grid.get_style_context ().add_class ("button");
            integration_grid.get_style_context ().add_class ("Pebbles_Buttons_Function");
            integration_button = new StyledButton ("\xE2\x88\xAB", "Definite Integral (Upper limit 'u' and Lower limit 'l')");
            integration_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            integration_button.get_style_context ().add_class ("suggested-override");
            integration_button.margin_top = 5;
            integration_button.margin_start = 2;
            
            int_limit_a = new Gtk.Entry ();
            int_limit_a.get_style_context ().add_class ("Pebbles_Small_Entry");
            int_limit_a.max_width_chars = 4;
            int_limit_a.width_chars = 4;
            int_limit_a.margin_start = 5;
            int_limit_a.margin_top = 5;
            int_limit_a.placeholder_text = "u =";
            int_limit_b = new Gtk.Entry ();
            int_limit_b.get_style_context ().add_class ("Pebbles_Small_Entry");
            int_limit_b.max_width_chars = 4;
            int_limit_b.width_chars = 4;
            int_limit_b.margin_start = 5;
            int_limit_b.margin_top = 5;
            int_limit_b.placeholder_text = "l =";
            integration_grid.attach (integration_button,            0, 0, 1, 1);
            integration_grid.attach (int_limit_a,                   1, 0, 1, 1);
            integration_grid.attach (int_limit_b,                   2, 0, 1, 1);
            
            // Make derivation section
            var derivation_grid = new Gtk.Grid ();
            derivation_grid.get_style_context ().add_class ("button");
            derivation_grid.get_style_context ().add_class ("Pebbles_Buttons_Function");
            derivation_button = new StyledButton ("dy/dx", "Derivative");
            derivation_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            derivation_button.get_style_context ().add_class ("suggested-override");
            derivation_button.margin_top = 5;
            derivation_button.margin_start = 2;
            
            int_limit_x = new Gtk.Entry ();
            int_limit_x.get_style_context ().add_class ("Pebbles_Small_Entry");
            int_limit_x.max_width_chars = 6;
            int_limit_x.width_chars = 6;
            int_limit_x.margin_start = 7;
            int_limit_x.margin_top = 5;
            int_limit_x.placeholder_text = "at x =";
            derivation_grid.attach (derivation_button,              0, 0, 1, 1);
            derivation_grid.attach (int_limit_x,                    1, 0, 1, 1);
            
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
            
            // Put it together
            attach (display_container, 0, 0, 2, 1);
            attach (button_container_left, 0, 1, 1, 1);
            attach (button_container_right, 1, 1, 1, 1);
            set_column_homogeneous (true);
        }
    }
}
