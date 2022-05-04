/*-
 * Copyright (c) 2017-2022 Subhadeep Jasu <subhajasu@gmail.com>
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
    public class GraphView: Gtk.Grid {
        // Input section left buttons
        StyledButton[] numpad_buttons;
        Gtk.Button del_button;
        StyledButton radix_button;
        StyledButton variable_x_button;
        StyledButton divide_button;
        StyledButton multiply_button;
        StyledButton subtract_button;
        StyledButton add_button;

        // Input section right buttons
        StyledButton sqr_button;
        StyledButton pow_root_button;
        StyledButton expo_power_button;
        StyledButton sin_button;
        StyledButton sinh_button;
        StyledButton log_cont_base_button;
        StyledButton cos_button;
        StyledButton cosh_button;
        StyledButton log_mod_button;
        StyledButton tan_button;
        StyledButton tanh_button;
        StyledButton perm_comb_button;
        StyledButton fact_button;
        StyledButton constant_button;
        StyledButton left_parenthesis_button;
        StyledButton right_parenthesis_button;

        Gtk.ListBox function_list;
        Gtk.MenuBar graph_controls;

        // Button Leaflet
        public Hdy.Leaflet button_leaflet;
        public Hdy.Leaflet function_graph_leaflet;

        // Display Unit
        GraphDisplay graph_display_unit;


        string constant_label_1 = "";
        string constant_desc_1 = "";
        string constant_label_2 = "";
        string constant_desc_2 = "";

        construct {
            halign = Gtk.Align.FILL;
            valign = Gtk.Align.FILL;
            column_spacing = 1;
            height_request = 400;
            column_homogeneous = true;
        }

        public GraphView () {
            var display_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                height_request = 300,
                margin_start = 8,
                margin_end = 8,
                margin_top = 8,
                margin_bottom = 8,
                vexpand = true
            };
            graph_display_unit = new GraphDisplay ();
            display_container.pack_start (graph_display_unit);

            function_list = new Gtk.ListBox () {
                width_request = 248,
                height_request = 300
            };

            var button_container_left = new Gtk.Grid () {
                column_homogeneous = true,
                row_homogeneous = true,
                height_request = 200,
                width_request = 256,
                margin_start = 8,
                margin_end = 8,
                column_spacing = 8,
                row_spacing = 8,
                vexpand = true
            };
            int x = 2, y = 0;
            numpad_buttons = new StyledButton[10];
            for (int i = 9; i >= 0; i--) {
                numpad_buttons[i] = new StyledButton (i.to_string ());
                numpad_buttons[i].get_style_context ().add_class ("pebbles_button_font_size");
                if (i > 0) {
                    button_container_left.attach (numpad_buttons[i], x--, y);
                    if (x < 0) {
                        x = 2;
                        y++;
                    }
                } else {
                    button_container_left.attach (numpad_buttons[0], 0, 3);
                }
            }

            del_button = new Gtk.Button.from_icon_name ("edit-clear-symbolic", Gtk.IconSize.BUTTON);
            del_button.set_tooltip_text (_("Backspace"));
            del_button.get_style_context ().remove_class ("image-button");
            del_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_left.attach (del_button, 3, 0);

            divide_button = new StyledButton ("\xC3\xB7", _("Divide"));
            divide_button.get_style_context ().add_class ("pebbles_button_font_size_h3");
            button_container_left.attach (divide_button, 3, 1);

            multiply_button = new StyledButton ("\xC3\x97", _("Multiply"));
            multiply_button.get_style_context ().add_class ("pebbles_button_font_size_h3");
            button_container_left.attach (multiply_button, 3, 2);

            subtract_button = new StyledButton ("\xE2\x88\x92", _("Subtract"));
            subtract_button.get_style_context ().add_class ("pebbles_button_font_size_h3");
            button_container_left.attach (subtract_button, 3, 3);

            add_button = new StyledButton ("+", _("Add"));
            add_button.get_style_context ().add_class ("pebbles_button_font_size_h3");
            button_container_left.attach (add_button, 2, 3);

            radix_button = new StyledButton (Utils.get_local_radix_symbol ());
            radix_button.get_style_context ().add_class ("pebbles_button_font_size_h3");
            button_container_left.attach (radix_button, 1, 3);

            var button_container_right = new Gtk.Grid () {
                column_homogeneous = true,
                row_homogeneous = true,
                height_request = 200,
                width_request = 256,
                margin_start = 8,
                margin_end = 8,
                column_spacing = 8,
                row_spacing = 8,
                vexpand = true
            };

            sqr_button = new StyledButton ("x<sup>2</sup>", _("Square a number"), {"Q"});
            sqr_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            sqr_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_right.attach (sqr_button, 0, 0);

            pow_root_button = new StyledButton ("x<sup>y</sup>", _("x raised to the power y"), {"Z"});
            pow_root_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            pow_root_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_right.attach (pow_root_button, 1, 0);

            expo_power_button = new StyledButton ("10<sup>x</sup>", _("10 raised to the power x"), {"W"});
            expo_power_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            expo_power_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_right.attach (expo_power_button, 2, 0);

            sin_button = new StyledButton ("sin", _("Sine"), {"S"});
            sin_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            sin_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_right.attach (sin_button, 0, 1);

            sinh_button = new StyledButton ("sinh", _("Hyperbolic Sine"), {"H"});
            sinh_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            sinh_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_right.attach (sinh_button, 1, 1);

            log_cont_base_button = new StyledButton ("log x", _("Log base 10"), {"L"});
            log_cont_base_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            log_cont_base_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_right.attach (log_cont_base_button, 2, 1);

            cos_button = new StyledButton ("cos", _("Cosine"), {"C"});
            cos_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            cos_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_right.attach (cos_button, 0, 2);

            cosh_button = new StyledButton ("cosh", _("Hyperbolic Cosine"), {"O"});
            cosh_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            cosh_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_right.attach (cosh_button, 1, 2);

            log_mod_button = new StyledButton ("Mod", _("Modulus"), {"M"});
            log_mod_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            log_mod_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_right.attach (log_mod_button, 2, 2);

            tan_button = new StyledButton ("tan", _("Tangent"), {"T"});
            tan_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            tan_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_right.attach (tan_button, 0, 3);

            tanh_button = new StyledButton ("tanh", _("Hyperbolic Tangent"), {"A"});
            tanh_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            tanh_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_right.attach (tanh_button, 1, 3);

            perm_comb_button = new StyledButton ("<sup>n</sup>P\xE1\xB5\xA3", _("Permutations"), {"P"});
            perm_comb_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            perm_comb_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_right.attach (perm_comb_button, 2, 3);

            fact_button = new StyledButton ("!", _("Factorial"), {"F"});
            fact_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            fact_button.get_style_context ().add_class ("pebbles_button_font_size");
            constant_button = new StyledButton (constant_label_1, constant_desc_1, {"R"});
            constant_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            constant_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_right.attach (fact_button, 3, 2);
            button_container_right.attach (constant_button, 3, 3);

            left_parenthesis_button = new StyledButton ("(");
            left_parenthesis_button.get_style_context ().add_class ("pebbles_button_font_size");
            right_parenthesis_button = new StyledButton (")");
            right_parenthesis_button.get_style_context ().add_class ("pebbles_button_font_size");
            button_container_right.attach (left_parenthesis_button, 3, 0);
            button_container_right.attach (right_parenthesis_button, 3, 1);

            button_leaflet = new Hdy.Leaflet () {
                hhomogeneous_unfolded = true,
                can_swipe_back = true,
                can_swipe_forward = true,
            };
            button_leaflet.add (button_container_left);
            button_leaflet.add (button_container_right);

            function_graph_leaflet = new Hdy.Leaflet () {
                can_swipe_back = true,
                can_swipe_forward = true,
            };
            function_graph_leaflet.add (display_container);
            function_graph_leaflet.add (function_list);

            // Put it together
            attach (function_graph_leaflet, 0, 0);
            attach (button_leaflet, 0, 1);
        }
    }
}
