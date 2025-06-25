namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/bit_grid.ui")]
    public class BitGrid : Gtk.Grid {
        private BitSubGrid button_grid_1;
        private BitSubGrid button_grid_2;
        private BitSubGrid button_grid_3;
        private BitSubGrid button_grid_4;
        private BitSubGrid button_grid_5;
        private BitSubGrid button_grid_6;
        private BitSubGrid button_grid_7;
        private BitSubGrid button_grid_8;
        private BitSubGrid button_grid_9;
        private BitSubGrid button_grid_10;
        private BitSubGrid button_grid_11;
        private BitSubGrid button_grid_12;
        private BitSubGrid button_grid_13;
        private BitSubGrid button_grid_14;
        private BitSubGrid button_grid_15;
        private BitSubGrid button_grid_16;

        [GtkChild]
        private unowned Gtk.Button hide_grid_button;
        private bool[] bool_array;

        public signal void changed (bool[] bool_array);
        public signal void hide_grid ();

        construct {
            hide_grid_button.remove_css_class ("image-button");
            bool_array = new bool[64];

            button_grid_1 = new BitSubGrid (0);
            button_grid_2 = new BitSubGrid (4);
            button_grid_3 = new BitSubGrid (8);
            button_grid_4 = new BitSubGrid (12);
            button_grid_5 = new BitSubGrid (16);
            button_grid_6 = new BitSubGrid (20);
            button_grid_7 = new BitSubGrid (24);
            button_grid_8 = new BitSubGrid (28);
            button_grid_9 = new BitSubGrid (32);
            button_grid_10 = new BitSubGrid (36);
            button_grid_11 = new BitSubGrid (40);
            button_grid_12 = new BitSubGrid (44);
            button_grid_13 = new BitSubGrid (48);
            button_grid_14 = new BitSubGrid (52);
            button_grid_15 = new BitSubGrid (56);
            button_grid_16 = new BitSubGrid (60);

            attach (button_grid_16, 0, 1);
            attach (button_grid_15, 1, 1);
            attach (button_grid_14, 2, 1);
            attach (button_grid_13, 3, 1);
            attach (button_grid_12, 0, 2);
            attach (button_grid_11, 1, 2);
            attach (button_grid_10, 2, 2);
            attach (button_grid_9, 3, 2);
            attach (button_grid_8, 0, 3);
            attach (button_grid_7, 1, 3);
            attach (button_grid_6, 2, 3);
            attach (button_grid_5, 3, 3);
            attach (button_grid_4, 0, 4);
            attach (button_grid_3, 1, 4);
            attach (button_grid_2, 2, 4);
            attach (button_grid_1, 3, 4);

            make_events ();
        }

        [GtkCallback]
        protected void hide_this () {
            hide_grid ();
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
                button_grid_9.group_set_active (false);
                button_grid_8.group_set_active (false);
                button_grid_7.group_set_active (false);
                button_grid_6.group_set_active (false);
                button_grid_5.group_set_active (false);
                button_grid_4.group_set_active (false);
                button_grid_3.group_set_active (false);
                button_grid_2.group_set_active (true);
                button_grid_1.group_set_active (true);
            } else if (mode == 1) {
                button_grid_16.group_set_active (false);
                button_grid_15.group_set_active (false);
                button_grid_14.group_set_active (false);
                button_grid_13.group_set_active (false);
                button_grid_12.group_set_active (false);
                button_grid_11.group_set_active (false);
                button_grid_10.group_set_active (false);
                button_grid_9.group_set_active (false);
                button_grid_8.group_set_active (false);
                button_grid_7.group_set_active (false);
                button_grid_6.group_set_active (false);
                button_grid_5.group_set_active (false);
                button_grid_4.group_set_active (true);
                button_grid_3.group_set_active (true);
                button_grid_2.group_set_active (true);
                button_grid_1.group_set_active (true);
            } else if (mode == 2) {
                button_grid_16.group_set_active (false);
                button_grid_15.group_set_active (false);
                button_grid_14.group_set_active (false);
                button_grid_13.group_set_active (false);
                button_grid_12.group_set_active (false);
                button_grid_11.group_set_active (false);
                button_grid_10.group_set_active (false);
                button_grid_9.group_set_active (false);
                button_grid_8.group_set_active (true);
                button_grid_7.group_set_active (true);
                button_grid_6.group_set_active (true);
                button_grid_5.group_set_active (true);
                button_grid_4.group_set_active (true);
                button_grid_3.group_set_active (true);
                button_grid_2.group_set_active (true);
                button_grid_1.group_set_active (true);
            } else if (mode == 3) {
                button_grid_16.group_set_active (true);
                button_grid_15.group_set_active (true);
                button_grid_14.group_set_active (true);
                button_grid_13.group_set_active (true);
                button_grid_12.group_set_active (true);
                button_grid_11.group_set_active (true);
                button_grid_10.group_set_active (true);
                button_grid_9.group_set_active (true);
                button_grid_8.group_set_active (true);
                button_grid_7.group_set_active (true);
                button_grid_6.group_set_active (true);
                button_grid_5.group_set_active (true);
                button_grid_4.group_set_active (true);
                button_grid_3.group_set_active (true);
                button_grid_2.group_set_active (true);
                button_grid_1.group_set_active (true);
            }
        }

        private void make_events () {
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

    private class BitSubGrid : Gtk.Grid {
        private Gtk.ToggleButton button1;
        private Gtk.ToggleButton button2;
        private Gtk.ToggleButton button3;
        private Gtk.ToggleButton button4;

        private bool[] bool_array;
        private Gtk.Label first_button_label;

        public signal void bit_changed (bool[] bool_array);

        public BitSubGrid (int num) {
            Object (
                column_homogeneous: true,
                margin_top: 2,
                margin_bottom: 2,
                margin_start: 2,
                margin_end: 2,
                column_spacing: 0
            );

            bool_array = new bool[4];
            first_button_label = new Gtk.Label (num.to_string ()) {
                halign = Gtk.Align.CENTER,
                opacity = 0.5
            };

            button1 = new Gtk.ToggleButton.with_label ("0") {
                can_focus = false,
                focus_on_click = false
            };
            button2 = new Gtk.ToggleButton.with_label ("0") {
                can_focus = false,
                focus_on_click = false
            };
            button3 = new Gtk.ToggleButton.with_label ("0") {
                can_focus = false,
                focus_on_click = false
            };
            button4 = new Gtk.ToggleButton.with_label ("0") {
                can_focus = false,
                focus_on_click = false
            };

            button1.add_css_class ("h4");
            button2.add_css_class ("h4");
            button3.add_css_class ("h4");
            button4.add_css_class ("h4");
            button1.add_css_class ("flat");
            button2.add_css_class ("flat");
            button3.add_css_class ("flat");
            button4.add_css_class ("flat");
            button1.add_css_class ("bit-toggle-button");
            button2.add_css_class ("bit-toggle-button");
            button3.add_css_class ("bit-toggle-button");
            button4.add_css_class ("bit-toggle-button");

            attach (button1, 0, 0);
            attach (button2, 1, 0);
            attach (button3, 2, 0);
            attach (button4, 3, 0);
            attach (first_button_label, 3, 1);

            create_events ();
        }

        private void create_events () {
            button1.toggled.connect (() => {
                button1.set_label (button1.active ? "1" : "0");
                bool_array[0] = button1.active;
                bit_changed (bool_array);
            });
            button2.toggled.connect (() => {
                button2.set_label (button2.active ? "1" : "0");
                bool_array[1] = button2.active;
                bit_changed (bool_array);
            });
            button3.toggled.connect (() => {
                button3.set_label (button3.active ? "1" : "0");
                bool_array[2] = button3.active;
                bit_changed (bool_array);
            });
            button4.toggled.connect (() => {
                button4.set_label (button4.active ? "1" : "0");
                bool_array[3] = button4.active;
                bit_changed (bool_array);
            });
        }

        public void group_set_active (bool active) {
            if (active) {
                button1.set_sensitive (true);
                button2.set_sensitive (true);
                button3.set_sensitive (true);
                button4.set_sensitive (true);
                first_button_label.set_opacity (0.5);
            }
            else {
                button1.set_sensitive (false);
                button2.set_sensitive (false);
                button3.set_sensitive (false);
                button4.set_sensitive (false);
                first_button_label.set_opacity (0.2);
            }
        }

        public void set_bits (bool[] arr) {
            bool_array = arr;
            button1.active = arr[0];
            button2.active = arr[0];
            button3.active = arr[0];
            button4.active = arr[0];
        }
    }
}
