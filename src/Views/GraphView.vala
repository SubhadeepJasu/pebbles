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
        StyledButton[] numpad_buttons;
        StyledButton all_clear_button;
        Gtk.Button del_button;
        StyledButton radix_button;
        StyledButton variable_x_button;
        StyledButton divide_button;
        StyledButton multiply_button;
        StyledButton subtract_button;
        StyledButton add_button;
        Gtk.ListBox function_list;
        Gtk.MenuBar graph_controls;

        public GraphView () {
            var numpad_grid = new Gtk.Grid ();
            int x = 2, y = 1;
            numpad_buttons = new StyledButton[10];
            for (int i = 9; i >= 0; i--) {
                numpad_buttons[i] = new StyledButton (i.to_string ());
                numpad_buttons[i].get_style_context ().add_class ("pebbles_button_font_size");
                if (i > 0) {
                    numpad_grid.attach (numpad_buttons[i], x--, y);
                    if (x < 0) {
                        x = 2;
                        y++;
                    }
                } else {
                    numpad_grid.attach (numpad_buttons[0], 0, 4);
                }
            }

            all_clear_button = new StyledButton ("AC", _("All Clear"), {"Delete"});
            all_clear_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            all_clear_button.get_style_context ().add_class ("pebbles_button_font_size");
            numpad_grid.attach (all_clear_button, 0, 0);

            del_button = new Gtk.Button.from_icon_name ("edit-clear-symbolic", Gtk.IconSize.BUTTON);
            del_button.set_tooltip_text (_("Backspace"));
            del_button.get_style_context ().remove_class ("image-button");
            del_button.get_style_context ().add_class ("pebbles_button_font_size");
            numpad_grid.attach (del_button, 1, 0);

            variable_x_button = new StyledButton ("𝑥", _("Variable for linear expressions"), {"X"});
            numpad_grid.attach (variable_x_button, 2, 0);

            divide_button = new StyledButton ("\xC3\xB7", _("Divide"));
            divide_button.get_style_context ().add_class ("pebbles_button_font_size_h3");
            numpad_grid.attach (divide_button, 3, 0);

            multiply_button = new StyledButton ("\xC3\x97", _("Multiply"));
            multiply_button.get_style_context ().add_class ("pebbles_button_font_size_h3");
            numpad_grid.attach (multiply_button, 3, 1);

            subtract_button = new StyledButton ("\xE2\x88\x92", _("Subtract"));
            subtract_button.get_style_context ().add_class ("pebbles_button_font_size_h3");
            numpad_grid.attach (subtract_button, 3, 2);

            add_button = new StyledButton ("+", _("Add"));
            add_button.get_style_context ().add_class ("pebbles_button_font_size_h3");
            numpad_grid.attach (add_button, 3, 3);

            attach (numpad_grid, 0, 0);
        }
    }
}
