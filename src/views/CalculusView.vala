/*-
 * Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>
`*
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
`* Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 *              Saunak Biswas  <saunakbis97@gmail.com>
 */
 
namespace Pebbles {
    public class CalculusView : Gtk.Grid {
        Gtk.Label cal_placeholder;
        construct {
            cal_placeholder = new Gtk.Label ("-- Calculus View --");
            halign = Gtk.Align.CENTER;
            valign = Gtk.Align.CENTER;
            attach (cal_placeholder, 0, 0, 1, 1);
        }
    }
}
