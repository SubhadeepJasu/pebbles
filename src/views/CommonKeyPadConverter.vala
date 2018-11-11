/*-
 * Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>
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
 *              Saunak Biswas  <saunakbis97@gmail.com>
 */

namespace Pebbles {
    public class CommonKeyPadConverter : Gtk.Grid {
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
        
        construct {
            // Make the buttons
            del_button = new StyledButton ("Del", "Backspace");
            all_clear_button = new StyledButton ("C", "Clear Entry");
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

            // Arange the buttons
            attach (all_clear_button, 0, 0, 1, 1);
            attach (del_button, 1, 0, 1, 1);
            attach (seven_button, 0, 1, 1, 1);
            attach (eight_button, 1, 1, 1, 1);
            attach (nine_button, 2, 1, 1, 1);
            attach (four_button, 0, 2, 1, 1);
            attach (five_button, 1, 2, 1, 1);
            attach (six_button, 2, 2, 1, 1);
            attach (one_button, 0, 3, 1, 1);
            attach (two_button, 1, 3, 1, 1);
            attach (three_button, 2, 3, 1, 1);
            attach (zero_button, 0, 4, 1, 1);
            attach (decimal_button, 1, 4, 1, 1);
            set_column_homogeneous (true);
            set_row_homogeneous (true);
            
            width_request = 240;
            height_request = 200;
            margin_start = 8;
            margin_end = 8;
            column_spacing = 8;
            row_spacing = 8;
        }
    }
}
