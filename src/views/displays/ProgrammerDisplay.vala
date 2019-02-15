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
        
        // Number System label
        public Gtk.Label hex_label;
        public Gtk.Label dec_label;
        public Gtk.Label oct_label;
        public Gtk.Label bin_label;
        
        Gtk.Label hex_number_label;
        Gtk.Label dec_number_label;
        Gtk.Label oct_number_label;
        Gtk.Label bin_number_label1;
        Gtk.Label bin_number_label2;
        
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
            
            // Make number system view
            Gtk.Grid number_system_grid = new Gtk.Grid ();
            hex_label = new Gtk.Label ("HEX");
            dec_label = new Gtk.Label ("DEC");
            oct_label = new Gtk.Label ("OCT");
            bin_label = new Gtk.Label ("BIN");
            
            hex_label.get_style_context ().add_class ("PebblesLCDSwitch");
            dec_label.get_style_context ().add_class ("PebblesLCDSwitch");
            oct_label.get_style_context ().add_class ("PebblesLCDSwitch");
            bin_label.get_style_context ().add_class ("PebblesLCDSwitch");
            bin_label.set_yalign (0);
            bin_label.set_margin_bottom (12);
            
            hex_number_label  = new Gtk.Label ("FFFF FFFF FFFF FFFF");
            dec_number_label  = new Gtk.Label ("18446744073709552000");
            oct_number_label  = new Gtk.Label ("2000000000000000000000");
            //bin_number_label1 = new Gtk.Label ("11111111111111111111111111111111");
            //bin_number_label2 = new Gtk.Label ("11111111111111111111111111111111");
            bin_number_label1 = new Gtk.Label ("1111111111111111111111111111111111111111111111111111111111111111");
            bin_number_label1.set_line_wrap_mode (Pango.WrapMode.CHAR);
            bin_number_label1.set_line_wrap (true);
            bin_number_label1.lines = 2;
            bin_number_label1.set_width_chars (32);
            bin_number_label1.set_max_width_chars (32);
            bin_number_label1.single_line_mode =    false;
            bin_number_label1.set_xalign (0);
            bin_number_label2 = new Gtk.Label ("");
            bin_number_label2.set_width_chars (32);
            
            hex_number_label.halign = Gtk.Align.START;
            dec_number_label.halign = Gtk.Align.START;
            oct_number_label.halign = Gtk.Align.START;
            bin_number_label1.halign = Gtk.Align.START;
            
            hex_number_label.get_style_context ().add_class ("PebblesLCDLabelSmall");
            dec_number_label.get_style_context ().add_class ("PebblesLCDLabelSmall");
            oct_number_label.get_style_context ().add_class ("PebblesLCDLabelSmall");
            bin_number_label1.get_style_context ().add_class ("PebblesLCDLabelSmall");
            bin_number_label2.get_style_context ().add_class ("PebblesLCDLabelSmall");
            
            
            number_system_grid.attach (hex_label,      0, 0, 1, 1);
            number_system_grid.attach (hex_number_label, 1, 0, 1, 1);
            number_system_grid.attach (dec_label,      0, 1, 1, 1);
            number_system_grid.attach (dec_number_label, 1, 1, 1, 1);
            number_system_grid.attach (oct_label,      0, 2, 1, 1);
            number_system_grid.attach (oct_number_label, 1, 2, 1, 1);
            number_system_grid.attach (bin_label,      0, 3, 1, 1);
            number_system_grid.attach (bin_number_label1, 1, 3, 1, 1);
            //number_system_grid.attach (bin_number_label2, 1, 4, 1, 1);
            number_system_grid.column_spacing = 8;
            number_system_grid.row_spacing    = 4;
            number_system_grid.margin_top     = 8;
            
            
            // Make LCD Answer label
            answer_label = new Gtk.Label ("0");
            answer_label.set_halign (Gtk.Align.END);
            answer_label.get_style_context ().add_class ("pebbles_h1");
            var scrollable = new Gtk.ScrolledWindow (null, null);
            scrollable.add (answer_label);
            scrollable.propagate_natural_height = true;
            scrollable.shadow_type = Gtk.ShadowType.NONE;
            scrollable.get_style_context ().add_class ("pebbles_h1");
            
            // Make Input Entry
            input_entry = new Gtk.Entry ();
            input_entry.set_has_frame (false);
            input_entry.set_text ("0");
            input_entry.get_style_context ().add_class ("pebbles_h2");
            input_entry.set_halign (Gtk.Align.START);
            input_entry.width_request = 265;
            input_entry.max_width_chars = 20;
            
            
            // Make seperator
            Gtk.Separator lcd_separator_h = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            lcd_separator_h.set_opacity (0.6);
            Gtk.Separator lcd_separator_v = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            lcd_separator_v.set_opacity (0.6);
            lcd_separator_v.margin_bottom = 8;
            
            // Put it together
            attach (lcd_status_bar,     0, 0, 3, 1);
            attach (number_system_grid, 0, 1, 1, 3);
            attach (lcd_separator_v,    1, 1, 1, 3);
            attach (scrollable,         2, 1, 1, 1);
            attach (lcd_separator_h,    2, 2, 1, 1);
            attach (input_entry,        2, 3, 1, 1);

            width_request = 530;
        }
    }
}
