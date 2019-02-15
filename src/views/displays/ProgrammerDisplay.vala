/*-
 * Copyright (c) 2018-2019 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright (c) 2018-2019 Saunak Biswas  <saunakbis97@gmail.com>
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
    public class ProgrammerDisplay : Gtk.Grid {
        // Status Bar
        Gtk.Grid  lcd_status_bar;
        Gtk.Label qwd_label;
        Gtk.Label dwd_label;
        Gtk.Label wrd_label;
        Gtk.Label byt_label;
        Gtk.Label memory_label;
        Gtk.Label shift_label;
        
        // Answer label
        public Gtk.Label answer_label;
        
        // Input entry
        public Gtk.Entry input_entry;
        
        // Word length mode
        GlobalWordLength word_mode;

        construct {
            prog_display_make_ui ();
        }
        ProgrammerView prog_view;

        public ProgrammerDisplay (ProgrammerView view) {
            this.prog_view = view;
        }

        private void prog_display_make_ui () {
            // Stylize background;
            get_style_context ().add_class ("Pebbles_Display_Unit_Bg");
            
            // Make status bar
            lcd_status_bar = new Gtk.Grid ();
            qwd_label      = new Gtk.Label ("QWD");
            qwd_label.get_style_context ().add_class ("pebbles_h4");
            dwd_label      = new Gtk.Label ("DWD");
            dwd_label.get_style_context ().add_class ("pebbles_h4");
            wrd_label      = new Gtk.Label ("WRD");
            wrd_label.get_style_context ().add_class ("pebbles_h4");
            byt_label      = new Gtk.Label ("BYT");
            byt_label.get_style_context ().add_class ("pebbles_h4");
            memory_label   = new Gtk.Label ("M");
            memory_label.get_style_context ().add_class ("pebbles_h4");
            memory_label.set_opacity (0.2);
            shift_label    = new Gtk.Label ("SHIFT");
            shift_label.get_style_context ().add_class ("pebbles_h4");
            shift_label.set_opacity (0.2);
            
            var word_mode_display = new Gtk.Grid ();
            word_mode_display.attach (qwd_label, 0, 0, 1, 1);
            word_mode_display.attach (dwd_label, 1, 0, 1, 1);
            word_mode_display.attach (wrd_label, 2, 0, 1, 1);
            word_mode_display.attach (byt_label, 3, 0, 1, 1);
            word_mode_display.column_spacing = 10;
            
            lcd_status_bar.attach (word_mode_display, 0, 0, 1, 1);
            lcd_status_bar.attach (memory_label, 1, 0, 1, 1);
            lcd_status_bar.attach (shift_label, 2, 0, 1, 1);
            lcd_status_bar.column_spacing = 187;
            lcd_status_bar.width_request  = 530;
            lcd_status_bar.set_halign (Gtk.Align.END);
            
            
            
            // Put it together
            attach (lcd_status_bar, 0, 0, 1, 1);

            width_request = 530;
        }
    }
}
