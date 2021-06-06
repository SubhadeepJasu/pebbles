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
    public class CommonNumericKeypad : Gtk.Popover {
        Gtk.Grid main_grid;
        
        public string val {
            get {return val;}
            set {send_button_press (val);}
        }
        
        StyledButton del_button;
        StyledButton all_clear_button;
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
        Gtk.Button done_button;
        
        Gtk.Entry entry;
        
        public signal void button_clicked (string input_text);
        
        construct {
            main_grid = new Gtk.Grid ();
            // Make the buttons
            del_button = new StyledButton ("Del", (_("Backspace")));
            all_clear_button = new StyledButton ("AC", (_("All Clear")));
            all_clear_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
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
            negative_button = new StyledButton ("+/\xE2\x88\x92");
            done_button = new Gtk.Button.from_icon_name ("pan-down-symbolic", Gtk.IconSize.BUTTON);

            // Arange the buttons
            main_grid.attach (all_clear_button, 0, 0, 1, 1);
            main_grid.attach (del_button, 1, 0, 1, 1);
            main_grid.attach (done_button, 2, 0, 1, 1);
            main_grid.attach (seven_button, 0, 1, 1, 1);
            main_grid.attach (eight_button, 1, 1, 1, 1);
            main_grid.attach (nine_button, 2, 1, 1, 1);
            main_grid.attach (four_button, 0, 2, 1, 1);
            main_grid.attach (five_button, 1, 2, 1, 1);
            main_grid.attach (six_button, 2, 2, 1, 1);
            main_grid.attach (one_button, 0, 3, 1, 1);
            main_grid.attach (two_button, 1, 3, 1, 1);
            main_grid.attach (three_button, 2, 3, 1, 1);
            main_grid.attach (zero_button, 0, 4, 1, 1);
            main_grid.attach (decimal_button, 1, 4, 1, 1);
            main_grid.attach (negative_button, 2, 4, 1, 1);
            main_grid.set_column_homogeneous (true);
            main_grid.set_row_homogeneous (true);
            
            main_grid.column_spacing = 8;
            main_grid.row_spacing = 8;
            main_grid.margin = 8;
            
            // Handle events
            del_button.clicked.connect (() => send_button_press ("del"));
            all_clear_button.clicked.connect (() => send_button_press ("C"));
            seven_button.clicked.connect (() => send_button_press ("7"));
            eight_button.clicked.connect (() => send_button_press ("8"));
            nine_button.clicked.connect (() => send_button_press ("9"));
            four_button.clicked.connect (() => send_button_press ("4"));
            five_button.clicked.connect (() => send_button_press ("5"));
            six_button.clicked.connect (() => send_button_press ("6"));
            one_button.clicked.connect (() => send_button_press ("1"));
            two_button.clicked.connect (() => send_button_press ("2"));
            three_button.clicked.connect (() => send_button_press ("3"));
            zero_button.clicked.connect (() => send_button_press ("0"));
            decimal_button.clicked.connect (() => send_button_press ("."));
            negative_button.clicked.connect (() => send_button_press ("-"));
            done_button.clicked.connect (() => {
                this.popdown ();
            });

            this.add (main_grid);
        }
        public CommonNumericKeypad (Gtk.Entry entry) {
            this.entry = entry;
            this.set_relative_to (entry);
            this.show_all ();
            this.set_visible (false);
            this.position = Gtk.PositionType.TOP;
            this.set_default_widget (this.entry);
        }
        private void send_button_press (string label) {
            button_clicked (label);
        }
    }
}
