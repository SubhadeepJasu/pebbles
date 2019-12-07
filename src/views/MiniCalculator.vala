/*-
 * Copyright (c) 2018-2019 Subhadeep Jasu <subhajasu@gmail.com>
 *               2018-2019 Saunak Biswas  <saunakbis97@gmail.com>
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
    public class MiniCalculator : Gtk.Window {
        public signal void mini_window_restore ();
        Pebbles.Settings settings;
        
        Gtk.Button close_button;
        Gtk.Entry  main_entry;
        Gtk.Button clear_button;
        Gtk.Button restore_button;
        StyledButton all_clear_button;
        StyledButton seven_button;
        StyledButton eigth_button;
        StyledButton nine_button;
        StyledButton four_button;
        StyledButton five_button;
        StyledButton six_button;
        StyledButton one_button;
        StyledButton two_button;
        StyledButton three_button;
        StyledButton zero_button;
        StyledButton radix_button;
        StyledButton add_button;
        StyledButton subtract_button;
        StyledButton divide_button;
        StyledButton multiply_button;
        StyledButton result_button;
        StyledButton answer_button;

        construct {
            settings = Pebbles.Settings.get_default ();
            settings.notify["use-dark-theme"].connect (() => {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.use_dark_theme;
            });
        }

        public MiniCalculator () {
            close_button = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.BUTTON);
            close_button.get_style_context ().add_class ("titlebutton");
            close_button.get_style_context ().add_class ("close");
            close_button.get_style_context ().remove_class ("image-button");
            close_button.margin = 3;
            close_button.margin_left = 0;

            main_entry = new Gtk.Entry ();
            main_entry.margin = 3;
            main_entry.placeholder_text = "0";
            main_entry.xalign = (float)1.0;
            clear_button = new Gtk.Button.from_icon_name ("edit-clear-symbolic", Gtk.IconSize.BUTTON);
            clear_button.get_style_context ().add_class ("titlebutton");
            clear_button.get_style_context ().add_class ("close");
            clear_button.get_style_context ().remove_class ("image-button");
            clear_button.margin = 3;
            clear_button.margin_right = 0;

            all_clear_button = new StyledButton ("C", "All Clear");
            all_clear_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            seven_button = new StyledButton ("7");
            eigth_button = new StyledButton ("8");
            nine_button = new StyledButton ("9");
            four_button = new StyledButton ("4");
            five_button = new StyledButton ("5");
            six_button = new StyledButton ("6");
            one_button = new StyledButton ("1");
            two_button = new StyledButton ("2");
            three_button = new StyledButton ("3");
            zero_button = new StyledButton ("4");
            radix_button = new StyledButton (".");
            add_button = new StyledButton ("+", "Add");
            add_button.get_style_context ().add_class ("h3");
            subtract_button = new StyledButton ("\xE2\x88\x92", "Subtract");
            subtract_button.get_style_context ().add_class ("h3");
            divide_button = new StyledButton ("\xC3\xB7", "Divide");
            divide_button.get_style_context ().add_class ("h3");
            multiply_button = new StyledButton ("\xC3\x97", "Multiply");
            multiply_button.get_style_context ().add_class ("h3");
            result_button = new StyledButton ("=", "Result");
            result_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            result_button.get_style_context ().add_class ("h2");
            answer_button = new StyledButton ("Ans", "Last Result");

            var header_box = new Gtk.HBox (false, 2);
            header_box.pack_start (close_button);
            header_box.pack_end (clear_button);
            header_box.pack_end (main_entry);
            
            var button_grid = new Gtk.Grid ();
            button_grid.attach (all_clear_button, 0, 0, 1, 1);
            button_grid.attach (divide_button, 1, 0, 1, 1);
            button_grid.attach (multiply_button, 2, 0, 1, 1);
            button_grid.attach (subtract_button, 3, 0, 1, 1);
            button_grid.attach (seven_button, 0, 1, 1, 1);
            button_grid.attach (eigth_button, 1, 1, 1, 1);
            button_grid.attach (nine_button, 2, 1, 1, 1);
            button_grid.attach (add_button, 3, 1, 1, 3);
            button_grid.attach (four_button, 0, 2, 1, 1);
            button_grid.attach (five_button, 1, 2, 1, 1);
            button_grid.attach (six_button, 2, 2, 1, 1);
            button_grid.attach (one_button, 0, 3, 1, 1);
            button_grid.attach (two_button, 1, 3, 1, 1);
            button_grid.attach (three_button, 2, 3, 1, 1);
            button_grid.attach (zero_button, 0, 4, 1, 1);
            button_grid.attach (radix_button, 1, 4, 1, 1);
            button_grid.attach (answer_button, 2, 4, 1, 1);
            button_grid.attach (result_button, 3, 4, 1, 1);
            button_grid.column_homogeneous = true;
            button_grid.row_homogeneous = true;
            button_grid.margin = 4;
            button_grid.column_spacing = 4;
            button_grid.row_spacing = 4;

            this.resizable = false;
            this.set_titlebar (header_box);
            this.title = "Pebbles Mini Mode";

            // Set up window attributes
            this.set_default_size (300, 200);
            this.set_size_request (300, 200);

            this.add (button_grid);
            this.set_keep_above (true);
            load_settings ();
            make_events ();
        }

        private void load_settings () {
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.use_dark_theme;
        }

        void make_events () {
            close_button.clicked.connect (() => {
                this.close ();
            });
        }
    }
}