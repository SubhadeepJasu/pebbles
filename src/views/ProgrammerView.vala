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
    public class ProgrammerView : Gtk.Overlay {
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
        StyledButton qword_button;
        StyledButton dword_button;
        StyledButton word_button;
        StyledButton byte_button;
        StyledButton seven_button;
        StyledButton eight_button;
        StyledButton nine_button;
        StyledButton a_button;
        StyledButton d_button;
        StyledButton or_button;
        StyledButton four_button;
        StyledButton five_button;
        StyledButton six_button;
        StyledButton b_button;
        StyledButton e_button;
        StyledButton and_button;
        StyledButton one_button;
        StyledButton two_button;
        StyledButton three_button;
        StyledButton c_button;
        StyledButton f_button;
        StyledButton xor_button;
        StyledButton zero_button;
        StyledButton left_parenthesis_button;
        StyledButton right_parenthesis_button;
        StyledButton lsh_button;
        StyledButton rsh_button;
        StyledButton not_button;

        // Input section right buttons
        StyledButton divide_button;
        StyledButton memory_plus_button;
        StyledButton multiply_button;
        StyledButton memory_minus_button;
        StyledButton subtract_button;
        StyledButton memory_recall_button;
        StyledButton addition_button;
        StyledButton memory_clear_button;
        StyledButton ans_button;
        StyledButton result_button;

        // App Settings
        Pebbles.Settings settings;

        private bool shift_held = false;

        public ProgrammerView (MainWindow window) {
            this.window = window;

            // Make UI
            prog_make_ui ();
            //prog_make_events ();
        }

        public void prog_make_ui () {

            var main_grid = new Gtk.Grid ();

            // Make fake LCD display
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
            qword_button = new StyledButton ("QWD", "64 bit value");
            dword_button = new StyledButton ("DWD", "32 bit value");
            word_button  = new StyledButton ("WRD", "16 bit value");
            byte_button  = new StyledButton ("BYT", "8 bit value");
            seven_button = new StyledButton ("7");
            eight_button = new StyledButton ("8");
            nine_button  = new StyledButton ("9");
            a_button     = new StyledButton ("A");
            d_button     = new StyledButton ("D");
            or_button    = new StyledButton ("OR", "Logical OR");
            or_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            four_button  = new StyledButton ("4");
            five_button  = new StyledButton ("5");
            six_button   = new StyledButton ("6");
            b_button     = new StyledButton ("B");
            e_button     = new StyledButton ("E");
            and_button   = new StyledButton ("AND", "Logical AND");
            and_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            one_button   = new StyledButton ("1");
            two_button   = new StyledButton ("2");
            three_button = new StyledButton ("3");
            c_button     = new StyledButton ("C");
            f_button     = new StyledButton ("F");
            xor_button   = new StyledButton ("XOR", "Logical Exclusive OR");
            xor_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            zero_button  = new StyledButton ("0");
            left_parenthesis_button = new StyledButton ("(");
            right_parenthesis_button = new StyledButton (")");
            lsh_button   = new StyledButton ("Lsh", "Left Shift");
            lsh_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            rsh_button   = new StyledButton ("Rsh", "Right Shift");
            rsh_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            not_button   = new StyledButton ("NOT", "Logical Inverse");
            not_button.get_style_context ().add_class ("Pebbles_Buttons_Function");

            button_container_left.attach (all_clear_button, 0, 0, 1, 1);
            button_container_left.attach (del_button, 1, 0, 1, 1);
            button_container_left.attach (qword_button, 2, 0, 1, 1);
            button_container_left.attach (dword_button, 3, 0, 1, 1);
            button_container_left.attach (word_button, 4, 0, 1, 1);
            button_container_left.attach (byte_button, 5, 0, 1, 1);
            button_container_left.attach (seven_button, 0, 1, 1, 1);
            button_container_left.attach (eight_button, 1, 1, 1, 1);
            button_container_left.attach (nine_button, 2, 1, 1, 1);
            button_container_left.attach (a_button, 3, 1, 1, 1);
            button_container_left.attach (d_button, 4, 1, 1, 1);
            button_container_left.attach (or_button, 5, 1, 1, 1);
            button_container_left.attach (four_button, 0, 2, 1, 1);
            button_container_left.attach (five_button, 1, 2, 1, 1);
            button_container_left.attach (six_button, 2, 2, 1, 1);
            button_container_left.attach (b_button, 3, 2, 1, 1);
            button_container_left.attach (e_button, 4, 2, 1, 1);
            button_container_left.attach (and_button, 5, 2, 1, 1);
            button_container_left.attach (one_button, 0, 3, 1, 1);
            button_container_left.attach (two_button, 1, 3, 1, 1);
            button_container_left.attach (three_button, 2, 3, 1, 1);
            button_container_left.attach (c_button, 3, 3, 1, 1);
            button_container_left.attach (f_button,4 ,3, 1, 1);
            button_container_left.attach (xor_button,5, 3, 1, 1);
            button_container_left.attach (zero_button,0, 4, 1, 1);
            button_container_left.attach (left_parenthesis_button, 1, 4, 1, 1);
            button_container_left.attach (right_parenthesis_button, 2, 4, 1, 1);
            button_container_left.attach (lsh_button, 3, 4, 1 ,1);
            button_container_left.attach (rsh_button, 4, 4, 1, 1);
            button_container_left.attach (not_button, 5, 4, 1, 1);
            
            button_container_left.set_column_homogeneous (true);
            button_container_left.set_row_homogeneous (true);
            
            // Make buttons on the right
            divide_button = new StyledButton ("\xC3\xB7");
            memory_plus_button = new StyledButton ("M+", "Add it to the value in Memory");
            memory_plus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            multiply_button = new StyledButton ("\xC3\x97");
            memory_minus_button = new StyledButton ("M-", "Subtract it from the value in Memory");
            memory_minus_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            subtract_button = new StyledButton ("-");
            memory_recall_button = new StyledButton ("MR", "Recall value from Memory");
            memory_recall_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            addition_button = new StyledButton ("+");
            memory_clear_button = new StyledButton ("MC", "Memory Clear");
            memory_clear_button.get_style_context ().add_class ("Pebbles_Buttons_Memory");
            ans_button = new StyledButton ("Ans", "Last answer");
            result_button = new StyledButton ("=", "Result");
            result_button.get_style_context ().add_class ("h2");
            result_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

            button_container_right.attach (divide_button,       0, 0, 1, 1);
            button_container_right.attach (memory_plus_button,  1, 0, 1, 1);
            button_container_right.attach (multiply_button,     0, 1, 1, 1);
            button_container_right.attach (memory_minus_button, 1, 1, 1, 1);
            button_container_right.attach (subtract_button,     0, 2, 1, 1);
            button_container_right.attach (memory_recall_button,1, 2, 1, 1);
            button_container_right.attach (addition_button,     0, 3, 1, 1);
            button_container_right.attach (memory_clear_button, 1, 3, 1, 1);
            button_container_right.attach (ans_button,          0, 4, 1, 1);
            button_container_right.attach (result_button,       1, 4, 1, 1);
            
            button_container_right.set_column_homogeneous (true);
            button_container_right.set_row_homogeneous (true);
            
            main_grid.attach (display_container, 0, 0, 2, 1);
            main_grid.attach (button_container_left, 0, 1, 1, 1);
            main_grid.attach (button_container_right, 1, 1, 1, 1);
            main_grid.width_request = 500;
            //main_grid.set_column_homogeneous (true);
            
            add_overlay (main_grid);
        }
    }
}
