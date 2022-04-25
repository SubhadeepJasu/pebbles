/*-
 * Copyright (c) 2017-2022 Subhadeep Jasu <subhajasu@gmail.com>
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
    public class Graph {
        Settings settings;
        ScientificCalculator sci_calc;

        public Graph () {
            settings = Settings.get_default ();
            sci_calc = new ScientificCalculator ();
        }

        public long plot_y (long x, double zoom_factor, string expression) {
            string res = sci_calc.get_result (expression.replace ("x", x.to_string ()), settings.global_angle_unit, -1, false).replace (",", "");
            long _x;
            if (long.try_parse (res, out _x)) {
                return _x;
            }
            return long.MIN;
        }
    }
}
