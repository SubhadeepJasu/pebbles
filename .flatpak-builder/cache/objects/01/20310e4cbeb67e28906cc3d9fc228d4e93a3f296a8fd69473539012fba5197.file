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
    public class BottomPopper : Gtk.Popover {
        Gtk.Grid main_grid;
        Gtk.Button plus_button;
        Gtk.Button plus_10_button;
        Gtk.Button minus_button;
        Gtk.Button minus_10_button;
        Gtk.Button reset;
        Gtk.Entry entry;
        construct {
            main_grid = new Gtk.Grid ();
            plus_button  = new Gtk.Button.with_label (" + ");
            minus_button = new Gtk.Button.with_label (" − ");
            plus_10_button  = new Gtk.Button.with_label ("+10");
            plus_10_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            minus_10_button = new Gtk.Button.with_label ("−10");
            minus_10_button.get_style_context ().add_class ("Pebbles_Buttons_Function");
            
            reset = new Gtk.Button.with_label (_("Reset"));
            reset.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            
            reset.clicked.connect (() => {
                entry.set_text ("");
            });
            
            plus_button.clicked.connect (() => {
                int i = int.parse (entry.get_text ());
                i++;
                entry.set_text (i.to_string ());
            });
            
            minus_button.clicked.connect (() => {
                int i = int.parse (entry.get_text ());
                if (i > 0)
                    i--;
                else if (i <= 0) {
                    i = 0;
                }
                if (i == 0) 
                    entry.set_text ("");
                else 
                    entry.set_text (i.to_string ());
            });
            
            plus_10_button.clicked.connect (() => {
                int i = int.parse (entry.get_text ());
                i+=10;
                entry.set_text (i.to_string ());
            });
            
            minus_10_button.clicked.connect (() => {
                int i = int.parse (entry.get_text ());
                if (i > 10)
                    i-=10;
                else if (i <= 10) {
                    i = 0;
                }
                if (i == 0) 
                    entry.set_text ("");
                else 
                    entry.set_text (i.to_string ());
            });
            var seperator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            main_grid.attach (plus_10_button,  0, 0, 1, 1);
            main_grid.attach (plus_button,     1, 0, 1, 1);
            main_grid.attach (minus_button,    2, 0, 1, 1);
            main_grid.attach (minus_10_button, 3, 0, 1, 1);
            main_grid.attach (seperator,       4, 0, 1, 1);
            main_grid.attach (reset,           5, 0, 1, 1);
            main_grid.column_spacing = 4;
            main_grid.margin = 4;

            this.add (main_grid);
        }
        public BottomPopper (Gtk.Entry entry) {
            this.entry = entry;
            this.set_relative_to (entry);
            this.show_all ();
            this.set_visible (false);
            this.position = Gtk.PositionType.BOTTOM;
        }
    }
}