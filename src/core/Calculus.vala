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
    public class Calculus {
        private static Pebbles.ScientificCalculator sci_calc;
        public static string get_derivative (string exp, GlobalAngleUnit angle_mode_in, double val) {
            sci_calc = new ScientificCalculator ();
            double dx = 0.00000000000000001; // Tends to zero but not zero.
            
            string exp1 = sci_calc.get_result (exp.replace ("x", (val + dx).to_string()), angle_mode_in);
            string exp2 = sci_calc.get_result (exp.replace ("x", (val).to_string()), angle_mode_in);
            
            if (exp1 != "E" && exp2 != "E") {
                if (exp1 == "∞" && exp2 == "∞") {
                    return ((double.INFINITY - double.INFINITY) / dx).to_string();
                }
                else if (exp1 == "∞") {
                    return ((double.INFINITY - double.parse(exp2)) / dx).to_string();
                }
                else if (exp2 == "∞") {
                    return ((double.parse (exp1) - double.INFINITY) / dx).to_string();
                }
                else
                    return ((double.parse (exp1) - double.parse(exp2)) / dx).to_string();
            }
            else {
                return "E";
            }
        }
        public static string get_definite_integral (string exp, GlobalAngleUnit angle_mode_in, double lower_limit, double upper_limit, int accuracy) {
            // Simpson's 3/8 method
            
            sci_calc = new ScientificCalculator ();
            double interval_size = (upper_limit - lower_limit) / accuracy;
            
            string exp1 = sci_calc.get_result (exp.replace ("x", lower_limit.to_string()), angle_mode_in);
            string exp2 = sci_calc.get_result (exp.replace ("x", upper_limit.to_string()), angle_mode_in);
            
            if (exp1 != "E" && exp2 != "E") {
                double sum = 0.0;
                if (exp1 == "∞" && exp2 == "∞") {
                    sum = double.INFINITY - double.INFINITY;
                }
                else if (exp1 == "∞") {
                    sum = double.INFINITY - double.parse (exp2);
                }
                else if (exp2 == "∞") {
                    sum = double.parse (exp1) - double.INFINITY;
                }
                else {
                    sum = double.parse (exp1) - double.parse (exp2);
                }
                
                // Calculate value till integral limit is reached
                for (int i = 1; i < accuracy; i++) {
                    if (i % 3 == 0) {
                        sum = sum + 2 * double.parse (sci_calc.get_result (exp.replace ("x", (lower_limit + i * interval_size).to_string()), angle_mode_in));
                    }
                    else {
                        sum = sum + 3 * double.parse (sci_calc.get_result (exp.replace ("x", (lower_limit + i * interval_size).to_string()), angle_mode_in));
                    }
                }
                return ((3 * interval_size / 8) * sum).to_string();
            }
            else {
                return "E";
            }
        }
    }
}
