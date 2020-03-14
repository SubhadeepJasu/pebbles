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
    protected class ButtonSubGrid : Gtk.Grid {
        private Gtk.Button button1;
        private Gtk.Button button2;
        private Gtk.Button button3;
        private Gtk.Button button4;
        
        private Gtk.Label first_button;
        public ButtonSubGrid (int num){
            first_button = new Gtk.Label (num.to_string ());
            first_button.set_opacity (0.5);
            
            button1 = new Gtk.Button.with_label ("0");
            button2 = new Gtk.Button.with_label ("0");
            button3 = new Gtk.Button.with_label ("0");
            button4 = new Gtk.Button.with_label ("0");
            
            button1.get_style_context ().add_class ("h4");
            button2.get_style_context ().add_class ("h4");
            button3.get_style_context ().add_class ("h4");
            button4.get_style_context ().add_class ("h4");
            button1.get_style_context ().add_class ("flat");
            button2.get_style_context ().add_class ("flat");
            button3.get_style_context ().add_class ("flat");
            button4.get_style_context ().add_class ("flat");
            button1.get_style_context ().add_class ("PebblesFlat");
            button2.get_style_context ().add_class ("PebblesFlat");
            button3.get_style_context ().add_class ("PebblesFlat");
            button4.get_style_context ().add_class ("PebblesFlat");
            
            
            this.set_column_homogeneous (true);
            
            attach (button1,      0, 0, 1, 1);
            attach (button2,      1, 0, 1, 1);
            attach (button3,      2, 0, 1, 1);
            attach (button4,      3, 0, 1, 1);
            attach (first_button, 3, 1, 1, 1);
            
            create_events ();
        }
        private void create_events () {
            button1.clicked.connect (() => {
                if (button1.get_label () == "0") {
                    button1.set_label ("1");
                    button1.get_style_context ().add_class ("Pebbles_Bit_Activated");
                }
                else {
                    button1.set_label ("0");
                    button1.get_style_context ().remove_class ("Pebbles_Bit_Activated");
                }
            });
            button2.clicked.connect (() => {
                if (button2.get_label () == "0") {
                    button2.set_label ("1");
                    button2.get_style_context ().add_class ("Pebbles_Bit_Activated");
                }
                else {
                    button2.set_label ("0");
                    button2.get_style_context ().remove_class ("Pebbles_Bit_Activated");
                }
            });
            button3.clicked.connect (() => {
                if (button3.get_label () == "0") {
                    button3.set_label ("1");
                    button3.get_style_context ().add_class ("Pebbles_Bit_Activated");
                }
                else {
                    button3.set_label ("0");
                    button3.get_style_context ().remove_class ("Pebbles_Bit_Activated");
                }
            });
            button4.clicked.connect (() => {
                if (button4.get_label () == "0") {
                    button4.set_label ("1");
                    button4.get_style_context ().add_class ("Pebbles_Bit_Activated");
                }
                else {
                    button4.set_label ("0");
                    button4.get_style_context ().remove_class ("Pebbles_Bit_Activated");
                }
            });
        }

        public void group_set_active (bool active) {
            if (active) {
                button1.set_sensitive (true);
                button2.set_sensitive (true);
                button3.set_sensitive (true);
                button4.set_sensitive (true);
                first_button.set_opacity (0.5);
            }
            else {
                button1.set_sensitive (false);
                button2.set_sensitive (false);
                button3.set_sensitive (false);
                button4.set_sensitive (false);
                first_button.set_opacity (0.2);
            }
        }
    }

    public class BitToggleGrid : Gtk.Grid {
        private ButtonSubGrid button_grid_1;
        private ButtonSubGrid button_grid_2;
        private ButtonSubGrid button_grid_3;
        private ButtonSubGrid button_grid_4;
        private ButtonSubGrid button_grid_5;
        private ButtonSubGrid button_grid_6;
        private ButtonSubGrid button_grid_7;
        private ButtonSubGrid button_grid_8;
        private ButtonSubGrid button_grid_9;
        private ButtonSubGrid button_grid_10;
        private ButtonSubGrid button_grid_11;
        private ButtonSubGrid button_grid_12;
        private ButtonSubGrid button_grid_13;
        private ButtonSubGrid button_grid_14;
        private ButtonSubGrid button_grid_15;
        private ButtonSubGrid button_grid_16;
        
        public  Gtk.Button    hide_grid;
        
        public BitToggleGrid () {
            hide_grid = new Gtk.Button.from_icon_name ("pan-down-symbolic", Gtk.IconSize.BUTTON);
            //hide_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            hide_grid.get_style_context ().add_class ("circular_button");
            button_grid_1  = new ButtonSubGrid (0);
            button_grid_2  = new ButtonSubGrid (4);
            button_grid_3  = new ButtonSubGrid (8);
            button_grid_4  = new ButtonSubGrid (12);
            button_grid_5  = new ButtonSubGrid (16);
            button_grid_6  = new ButtonSubGrid (20);
            button_grid_7  = new ButtonSubGrid (24);
            button_grid_8  = new ButtonSubGrid (28);
            button_grid_9  = new ButtonSubGrid (32);
            button_grid_10 = new ButtonSubGrid (36);
            button_grid_11 = new ButtonSubGrid (40);
            button_grid_12 = new ButtonSubGrid (44);
            button_grid_13 = new ButtonSubGrid (48);
            button_grid_14 = new ButtonSubGrid (52);
            button_grid_15 = new ButtonSubGrid (56);
            button_grid_16 = new ButtonSubGrid (60);
            
            hide_grid.margin_top  = 4;
            hide_grid.margin_bottom = 4;
            hide_grid.margin_start = 100;
            hide_grid.margin_end  = 100;
            //hide_grid.width_request = 545;
            button_grid_1.margin  = 2;
            button_grid_2.margin  = 2;
            button_grid_3.margin  = 2;
            button_grid_4.margin  = 2;
            button_grid_5.margin  = 2;
            button_grid_6.margin  = 2;
            button_grid_7.margin  = 2;
            button_grid_8.margin  = 2;
            button_grid_9.margin  = 2;
            button_grid_10.margin = 2;
            button_grid_11.margin = 2;
            button_grid_12.margin = 2;
            button_grid_13.margin = 2;
            button_grid_14.margin = 2;
            button_grid_15.margin = 2;
            button_grid_16.margin = 2;
            
            attach (hide_grid,       1, 0, 2, 1);
            attach (button_grid_16,  0, 1, 1, 1);
            attach (button_grid_15,  1, 1, 1, 1);
            attach (button_grid_14,  2, 1, 1, 1);
            attach (button_grid_13,  3, 1, 1, 1);
            attach (button_grid_12,  0, 2, 1, 1);
            attach (button_grid_11,  1, 2, 1, 1);
            attach (button_grid_10,  2, 2, 1, 1);
            attach (button_grid_9,   3, 2, 1, 1);
            attach (button_grid_8,   0, 3, 1, 1);
            attach (button_grid_7,   1, 3, 1, 1);
            attach (button_grid_6,   2, 3, 1, 1);
            attach (button_grid_5,   3, 3, 1, 1);
            attach (button_grid_4,   0, 4, 1, 1);
            attach (button_grid_3,   1, 4, 1, 1);
            attach (button_grid_2,   2, 4, 1, 1);
            attach (button_grid_1,   3, 4, 1, 1);
            
            get_style_context ().add_class ("card");
            get_style_context ().add_class ("Pebbles_Card");
            margin_end    = 8;
            margin_bottom = 8;
        }
        public void set_bit_length_mode (int mode) {
            if (mode == 0) {
                button_grid_16.group_set_active (false);
                button_grid_15.group_set_active (false);
                button_grid_14.group_set_active (false);
                button_grid_13.group_set_active (false);
                button_grid_12.group_set_active (false);
                button_grid_11.group_set_active (false);
                button_grid_10.group_set_active (false);
                button_grid_9.group_set_active  (false);
                button_grid_8.group_set_active  (false);
                button_grid_7.group_set_active  (false);
                button_grid_6.group_set_active  (false);
                button_grid_5.group_set_active  (false);
                button_grid_4.group_set_active  (false);
                button_grid_3.group_set_active  (false);
                button_grid_2.group_set_active  (true);
                button_grid_1.group_set_active  (true);
            }
            else if (mode == 1) {
                button_grid_16.group_set_active (false);
                button_grid_15.group_set_active (false);
                button_grid_14.group_set_active (false);
                button_grid_13.group_set_active (false);
                button_grid_12.group_set_active (false);
                button_grid_11.group_set_active (false);
                button_grid_10.group_set_active (false);
                button_grid_9.group_set_active  (false);
                button_grid_8.group_set_active  (false);
                button_grid_7.group_set_active  (false);
                button_grid_6.group_set_active  (false);
                button_grid_5.group_set_active  (false);
                button_grid_4.group_set_active  (true);
                button_grid_3.group_set_active  (true);
                button_grid_2.group_set_active  (true);
                button_grid_1.group_set_active  (true);
            }
            else if (mode == 2) {
                button_grid_16.group_set_active (false);
                button_grid_15.group_set_active (false);
                button_grid_14.group_set_active (false);
                button_grid_13.group_set_active (false);
                button_grid_12.group_set_active (false);
                button_grid_11.group_set_active (false);
                button_grid_10.group_set_active (false);
                button_grid_9.group_set_active  (false);
                button_grid_8.group_set_active  (true);
                button_grid_7.group_set_active  (true);
                button_grid_6.group_set_active  (true);
                button_grid_5.group_set_active  (true);
                button_grid_4.group_set_active  (true);
                button_grid_3.group_set_active  (true);
                button_grid_2.group_set_active  (true);
                button_grid_1.group_set_active  (true);
            }
            else if (mode == 3) {
                button_grid_16.group_set_active (true);
                button_grid_15.group_set_active (true);
                button_grid_14.group_set_active (true);
                button_grid_13.group_set_active (true);
                button_grid_12.group_set_active (true);
                button_grid_11.group_set_active (true);
                button_grid_10.group_set_active (true);
                button_grid_9.group_set_active  (true);
                button_grid_8.group_set_active  (true);
                button_grid_7.group_set_active  (true);
                button_grid_6.group_set_active  (true);
                button_grid_5.group_set_active  (true);
                button_grid_4.group_set_active  (true);
                button_grid_3.group_set_active  (true);
                button_grid_2.group_set_active  (true);
                button_grid_1.group_set_active  (true);
            }
        }
    }
}
