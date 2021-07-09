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

        public signal void bit_changed (bool[] bool_array);
        
        private bool[] bool_array;
        private Gtk.Label first_button;
        public ButtonSubGrid (int num){
            bool_array = new bool[4];
            first_button = new Gtk.Label (num.to_string ());
            first_button.halign = Gtk.Align.END;
            first_button.margin_end = 6;
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
            attach (first_button, 0, 1, 4, 1);
            
            create_events ();
        }
        private void create_events () {
            button1.clicked.connect (() => {
                if (button1.get_label () == "0") {
                    button1.set_label ("1");
                    bool_array[0] = true;
                    button1.get_style_context ().add_class ("Pebbles_Bit_Activated");
                }
                else {
                    button1.set_label ("0");
                    bool_array[0] = false;
                    button1.get_style_context ().remove_class ("Pebbles_Bit_Activated");
                }
                bit_changed (bool_array);
            });
            button2.clicked.connect (() => {
                if (button2.get_label () == "0") {
                    button2.set_label ("1");
                    bool_array[1] = true;
                    button2.get_style_context ().add_class ("Pebbles_Bit_Activated");
                }
                else {
                    button2.set_label ("0");
                    bool_array[1] = false;
                    button2.get_style_context ().remove_class ("Pebbles_Bit_Activated");
                }
                bit_changed (bool_array);
            });
            button3.clicked.connect (() => {
                if (button3.get_label () == "0") {
                    button3.set_label ("1");
                    bool_array[2] = true;
                    button3.get_style_context ().add_class ("Pebbles_Bit_Activated");
                }
                else {
                    button3.set_label ("0");
                    bool_array[2] = false;
                    button3.get_style_context ().remove_class ("Pebbles_Bit_Activated");
                }
                bit_changed (bool_array);
            });
            button4.clicked.connect (() => {
                if (button4.get_label () == "0") {
                    button4.set_label ("1");
                    bool_array[3] = true;
                    button4.get_style_context ().add_class ("Pebbles_Bit_Activated");
                }
                else {
                    button4.set_label ("0");
                    bool_array[3] = false;
                    button4.get_style_context ().remove_class ("Pebbles_Bit_Activated");
                }
                bit_changed (bool_array);
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

        public void set_bits (bool[] arr) {
            bool_array = arr;
            button1.set_label ((arr[0]) ? "1" : "0");
            if (arr[0]) {
                button1.get_style_context ().add_class ("Pebbles_Bit_Activated");
            } else {
                button1.get_style_context ().remove_class ("Pebbles_Bit_Activated");
            }

            button2.set_label ((arr[1]) ? "1" : "0");
            if (arr[1]) {
                button2.get_style_context ().add_class ("Pebbles_Bit_Activated");
            } else {
                button2.get_style_context ().remove_class ("Pebbles_Bit_Activated");
            }

            button3.set_label ((arr[2]) ? "1" : "0");
            if (arr[2]) {
                button3.get_style_context ().add_class ("Pebbles_Bit_Activated");
            } else {
                button3.get_style_context ().remove_class ("Pebbles_Bit_Activated");
            }

            button4.set_label ((arr[3]) ? "1" : "0");
            if (arr[3]) {
                button4.get_style_context ().add_class ("Pebbles_Bit_Activated");
            } else {
                button4.get_style_context ().remove_class ("Pebbles_Bit_Activated");
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
        
        private bool[] bool_array;

        public signal void changed (bool[] bool_array);

        public BitToggleGrid () {
            bool_array = new bool[64];
            hide_grid = new Gtk.Button.from_icon_name ("pan-down-symbolic", Gtk.IconSize.BUTTON);
            hide_grid.get_style_context ().add_class ("circular_button");
            hide_grid.get_style_context ().remove_class ("image-button");
            hide_grid.valign = Gtk.Align.START;
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
            
            attach (hide_grid,       0, 0, 4, 1);
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
            row_homogeneous = true;
            column_homogeneous = true;

            make_events ();
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

        public void make_events () {
            button_grid_1.bit_changed.connect ((arr) => {
                this.bool_array[63] = arr[3];
                this.bool_array[62] = arr[2];
                this.bool_array[61] = arr[1];
                this.bool_array[60] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_2.bit_changed.connect ((arr) => {
                this.bool_array[59] = arr[3];
                this.bool_array[58] = arr[2];
                this.bool_array[57] = arr[1];
                this.bool_array[56] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_3.bit_changed.connect ((arr) => {
                this.bool_array[55] = arr[3];
                this.bool_array[54] = arr[2];
                this.bool_array[53] = arr[1];
                this.bool_array[52] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_4.bit_changed.connect ((arr) => {
                this.bool_array[51] = arr[3];
                this.bool_array[50] = arr[2];
                this.bool_array[49] = arr[1];
                this.bool_array[48] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_5.bit_changed.connect ((arr) => {
                this.bool_array[47] = arr[3];
                this.bool_array[46] = arr[2];
                this.bool_array[45] = arr[1];
                this.bool_array[44] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_6.bit_changed.connect ((arr) => {
                this.bool_array[43] = arr[3];
                this.bool_array[42] = arr[2];
                this.bool_array[40] = arr[1];
                this.bool_array[40] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_7.bit_changed.connect ((arr) => {
                this.bool_array[39] = arr[3];
                this.bool_array[38] = arr[2];
                this.bool_array[37] = arr[1];
                this.bool_array[36] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_8.bit_changed.connect ((arr) => {
                this.bool_array[35] = arr[3];
                this.bool_array[34] = arr[2];
                this.bool_array[33] = arr[1];
                this.bool_array[32] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_9.bit_changed.connect ((arr) => {
                this.bool_array[31] = arr[3];
                this.bool_array[30] = arr[2];
                this.bool_array[29] = arr[1];
                this.bool_array[28] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_10.bit_changed.connect ((arr) => {
                this.bool_array[27] = arr[3];
                this.bool_array[26] = arr[2];
                this.bool_array[25] = arr[1];
                this.bool_array[24] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_11.bit_changed.connect ((arr) => {
                this.bool_array[23] = arr[3];
                this.bool_array[22] = arr[2];
                this.bool_array[21] = arr[1];
                this.bool_array[20] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_12.bit_changed.connect ((arr) => {
                this.bool_array[19] = arr[3];
                this.bool_array[18] = arr[2];
                this.bool_array[17] = arr[1];
                this.bool_array[16] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_13.bit_changed.connect ((arr) => {
                this.bool_array[15] = arr[3];
                this.bool_array[14] = arr[2];
                this.bool_array[13] = arr[1];
                this.bool_array[12] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_14.bit_changed.connect ((arr) => {
                this.bool_array[11] = arr[3];
                this.bool_array[10] = arr[2];
                this.bool_array[9] = arr[1];
                this.bool_array[8] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_15.bit_changed.connect ((arr) => {
                this.bool_array[7] = arr[3];
                this.bool_array[6] = arr[2];
                this.bool_array[5] = arr[1];
                this.bool_array[4] = arr[0];
                this.changed (this.bool_array);
            });
            button_grid_16.bit_changed.connect ((arr) => {
                this.bool_array[3] = arr[3];
                this.bool_array[2] = arr[2];
                this.bool_array[1] = arr[1];
                this.bool_array[0] = arr[0];
                this.changed (this.bool_array);
            });
        }

        public void set_bits (bool[] arr) {
            button_grid_16.set_bits (arr[0:4]);
            button_grid_15.set_bits (arr[4:8]);
            button_grid_14.set_bits (arr[8:12]);
            button_grid_13.set_bits (arr[12:16]);
            button_grid_12.set_bits (arr[16:20]);
            button_grid_11.set_bits (arr[20:24]);
            button_grid_10.set_bits (arr[24:28]);
            button_grid_9.set_bits (arr[28:32]);
            button_grid_8.set_bits (arr[32:36]);
            button_grid_7.set_bits (arr[36:40]);
            button_grid_6.set_bits (arr[40:44]);
            button_grid_5.set_bits (arr[44:48]);
            button_grid_4.set_bits (arr[48:52]);
            button_grid_3.set_bits (arr[52:56]);
            button_grid_2.set_bits (arr[56:60]);
            button_grid_1.set_bits (arr[60:64]);
            bool_array = arr;
        }
    }
}
