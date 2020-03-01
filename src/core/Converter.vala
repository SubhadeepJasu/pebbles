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
    public class Converter {
        private double[] unit_multipliers_list;
        public bool precision_override { get; set; }
        public int[] precision_structure;

        public Converter (double[] multipliers, bool? _precision_override = false, int[]? _precision_structure = null) {
            unit_multipliers_list = multipliers;
            this.precision_override = _precision_override;
            if (precision_override) {
                precision_structure = _precision_structure;
            }
        }
        Settings settings;
        public string convert (double input, int unit_a, int unit_b) {
            settings = Settings.get_default ();
            double result = input * (unit_multipliers_list [unit_b] / unit_multipliers_list [unit_a]);
            string output = "";

            if (precision_override && precision_structure != null) {
                output = Utils.manage_decimal_places (result, get_min(precision_structure[unit_b], settings.decimal_places));
            } else {
                output = Utils.manage_decimal_places (result, settings.decimal_places);
            }
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

        private int get_min (int a, int b) {
            if (a > b) {
                return b;
            } else {
                return a;
            }
        }
    }
}
