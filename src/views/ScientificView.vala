/*-
 * Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
        Gtk.Button all_clear_button;
        Gtk.Button del_button;
        Gtk.Button percent_button;
        Gtk.Button divide_button;
        Gtk.Button seven_button;
        Gtk.Button eight_button;
        Gtk.Button nine_button;
        Gtk.Button multiply_button;
        Gtk.Button four_button;
        Gtk.Button five_button;
        Gtk.Button six_button;
        Gtk.Button subtract_button;
        Gtk.Button one_button;
        Gtk.Button two_button;
        Gtk.Button three_button;
        Gtk.Button plus_button;
        Gtk.Button zero_button;
        Gtk.Button decimal_button;
        Gtk.Button left_parenthesis_button;
        Gtk.Button right_parenthesis_button;

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
            button_container_right.attach (new Gtk.Button.with_label ("3"), 0, 0, 1, 1);
            
            // Make buttons on the left
            all_clear_button = new Gtk.Button.with_label ("C");
            del_button = new Gtk.Button.with_label ("Del");
            percent_button = new Gtk.Button.with_label ("%");
            divide_button = new Gtk.Button.with_label ("\xC3\xB7");
            seven_button = new Gtk.Button.with_label ("7");
            eight_button = new Gtk.Button.with_label ("8");
            nine_button = new Gtk.Button.with_label ("9");
            multiply_button = new Gtk.Button.with_label ("\xC3\x97");
            four_button = new Gtk.Button.with_label ("4");
            five_button = new Gtk.Button.with_label ("5");
            six_button = new Gtk.Button.with_label ("6");
            subtract_button = new Gtk.Button.with_label ("\xE2\x88\x92");
            one_button = new Gtk.Button.with_label ("1");
            two_button = new Gtk.Button.with_label ("2");
            three_button = new Gtk.Button.with_label ("3");
            plus_button = new Gtk.Button.with_label ("+");
            zero_button = new Gtk.Button.with_label ("0");
            decimal_button = new Gtk.Button.with_label (".");
            left_parenthesis_button = new Gtk.Button.with_label ("(");
            right_parenthesis_button = new Gtk.Button.with_label (")");
            
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
