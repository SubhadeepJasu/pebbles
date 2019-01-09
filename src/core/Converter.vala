/*-
 * Copyright (c) 2018-2019 Subhadeep Jasu <subhajasu@gmail.com>
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
    public class Converter {
        private double[] unit_multipliers_list;

        public Converter (double[] multipliers) {
            unit_multipliers_list = multipliers;
        }
        public string convert (double input, int unit_a, int unit_b) {
            double result = input * (unit_multipliers_list [unit_b] / unit_multipliers_list [unit_a]);
            string output = ("%.9f".printf (result));

            // Remove trailing 0s and decimals
            while (output.has_suffix ("0")) {
                output = output.slice (0, -1);
            }
            if (output.has_suffix (".")) {
                output = output.slice (0, -1);
            }

            return output;
        }
        public void update_multipliers (double[] multipliers) {
            unit_multipliers_list = multipliers;
        }
    }
}
