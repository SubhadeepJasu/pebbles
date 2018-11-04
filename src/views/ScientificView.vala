/*-
 * Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 *              Saunak Biswas  <saunakbis97@gmail.com>
 */
 
namespace Pebbles {
    public class ScientificView : Gtk.Grid {
        List<string> input_expression;
        Gtk.Label sci_placeholder;
        construct {
            sci_placeholder = new Gtk.Label ("-- Scientific View --");
            halign = Gtk.Align.CENTER;
            valign = Gtk.Align.CENTER;
            attach (sci_placeholder, 0, 0, 1, 1);
            
            // Handle inputs
            input_expression = new List <string> ();
        }
        public void handle_inputs (string in_exp) {
            sci_placeholder.label = in_exp;
        }
    }
}
