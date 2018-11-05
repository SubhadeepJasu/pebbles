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
        Gtk.Label sci_placeholder;

        // Fake LCD display
        Gtk.Box display_container;

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
        StyledButton log_ten_button;
        StyledButton log_e_button;
        StyledButton memory_plus_button;
        StyledButton sin_button;
        StyledButton sinh_button;
        StyledButton mod_button;
        StyledButton memory_minus_button;
        StyledButton cos_button;
        StyledButton cosh_button;
        StyledButton log_power_button;
        StyledButton memory_recall_button;
        StyledButton tan_button;
        StyledButton tanh_button;
        StyledButton perm_comb_button;
        StyledButton memory_clear_button;
        StyledButton fact_button;
        StyledButton constant_button;
        StyledButton last_answer_button;
        StyledButton result_button;

        public ScientificView () {
            // Make UI
            sci_make_ui();
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
            display_container = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            display_container.height_request = 120;
            display_container.width_request = 560;
            display_container.margin_start = 8;
            display_container.margin_end = 8;
            display_container.margin_top = 8;
            display_container.margin_bottom = 8;
            display_container.pack_start (new Gtk.Button.with_label ("1"));
            
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
            all_clear_button = new StyledButton ("C");
            all_clear_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            del_button = new StyledButton ("Del");
            del_button.sensitive = false;
            percent_button = new StyledButton ("%");
            percent_button.get_style_context ().add_class ("h3");
            divide_button = new StyledButton ("\xC3\xB7");
            divide_button.get_style_context ().add_class ("h3");
            seven_button = new StyledButton ("7");
            eight_button = new StyledButton ("8");
            nine_button = new StyledButton ("9");
            multiply_button = new StyledButton ("\xC3\x97");
            multiply_button.get_style_context ().add_class ("h3");
            four_button = new StyledButton ("4");
            five_button = new StyledButton ("5");
            six_button = new StyledButton ("6");
            subtract_button = new StyledButton ("\xE2\x88\x92");
            subtract_button.get_style_context ().add_class ("h3");
            one_button = new StyledButton ("1");
            two_button = new StyledButton ("2");
            three_button = new StyledButton ("3");
            plus_button = new StyledButton ("+");
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
            sqr_button = new StyledButton ("x<sup>2</sup>");
            log_ten_button = new StyledButton ("10<sup>x</sup>");
            log_e_button = new StyledButton ("e<sup>x</sup>");
            memory_plus_button = new StyledButton ("<b>M+</b>");
            memory_plus_button.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
            sin_button = new StyledButton ("sin");
            sinh_button = new StyledButton ("sinh");
            mod_button = new StyledButton ("Mod");
            memory_minus_button = new StyledButton ("<b>M\xE2\x88\x92</b>");
            memory_minus_button.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
            cos_button = new StyledButton ("cos");
            cosh_button = new StyledButton ("cosh");
            log_power_button = new StyledButton ("x<sup>y</sup>");
            memory_recall_button = new StyledButton ("<b>MR</b>");
            memory_recall_button.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
            tan_button = new StyledButton ("tan");
            tanh_button = new StyledButton ("tanh");
            perm_comb_button = new StyledButton ("\xE2\x81\xBFP\xE1\xB5\xA3");
            memory_clear_button = new StyledButton ("<b>MC</b>");
            memory_clear_button.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
            fact_button = new StyledButton ("!");
            constant_button = new StyledButton ("\xCF\x80");
            last_answer_button = new StyledButton ("Ans");
            last_answer_button.sensitive = false;
            result_button = new StyledButton ("=");
            result_button.get_style_context ().add_class ("h2");
            result_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            
            button_container_right.attach (sqr_button, 0, 0, 1, 1);
            button_container_right.attach (log_ten_button, 1, 0, 1, 1);
            button_container_right.attach (log_e_button, 2, 0, 1, 1);
            button_container_right.attach (memory_plus_button, 3, 0, 1, 1); 
            button_container_right.attach (sin_button, 0, 1, 1, 1);
            button_container_right.attach (sinh_button, 1, 1, 1, 1);
            button_container_right.attach (mod_button, 2, 1, 1, 1);
            button_container_right.attach (memory_minus_button, 3, 1, 1, 1);
            button_container_right.attach (cos_button, 0, 2, 1, 1);
            button_container_right.attach (cosh_button, 1, 2, 1, 1);
            button_container_right.attach (log_power_button, 2, 2, 1, 1);
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

        public void handle_inputs (string in_exp) {
            //sci_placeholder.label = in_exp;
        }
    }
}
