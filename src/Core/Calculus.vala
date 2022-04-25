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

using Gsl;
namespace Pebbles {

/////// DERIVATION ///////////////////////////////////////////////////////////////////////////////////////////////////////

    public class Calculus : GLib.Object {

        private static double derivable_function (double x, char* params) {
            string exp = (string) params;
            Settings settings = Settings.get_default ();
            ScientificCalculator sci_calc = new ScientificCalculator ();
            string res = sci_calc.get_result (exp.replace ("x", x.to_string ()), settings.global_angle_unit, -1, false).replace (",", "");
            return double.parse (res);
        }

        public static string get_derivative (string exp, GlobalAngleUnit angle_mode_in, double val) {
            double result, error;

            string revised_exp = Utils.st_tokenize (exp);
            revised_exp = Utils.algebraic_variable_product_convert (revised_exp);
            char* user_func = new char [revised_exp.length];
            for (int i = 0; i < revised_exp.length; i++) {
                user_func [i] = (char)revised_exp.get_char (i);
            }

            Function scientific_function = Function () { function = derivable_function, params = user_func };
            if (val != 0) {
                Deriv.central (&scientific_function, val, 1e-8, out result, out error);
            }
            else {
                Deriv.forward (&scientific_function, val, 1e-8, out result, out error);
            }

            Settings accuracy_settings = Settings.get_default ();
            return Utils.manage_decimal_places (result, accuracy_settings.decimal_places);
        }


/////// INTEGRATION ///////////////////////////////////////////////////////////////////////////////////////////////////////

        public static string get_definite_integral (string exp, GlobalAngleUnit angle_mode_in, double lower_limit, double upper_limit) {
            // Using Simpson's 3/8 method

            string revised_exp = Utils.st_tokenize (exp);
            revised_exp = Utils.algebraic_variable_product_convert (revised_exp);
            ScientificCalculator sci_calc = new ScientificCalculator (true);
            Settings accuracy_settings = Settings.get_default ();
            int accuracy = accuracy_settings.integration_accuracy;
            double interval_size = (upper_limit - lower_limit) / accuracy;
            string exp1 = sci_calc.get_result (revised_exp.replace ("x", lower_limit.to_string()), angle_mode_in);
            string exp2 = sci_calc.get_result (revised_exp.replace ("x", upper_limit.to_string()), angle_mode_in);

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
                        sum = sum + 2 * double.parse (sci_calc.get_result (revised_exp.replace ("x", (lower_limit + i * interval_size).to_string()), angle_mode_in));
                    }
                    else {
                        sum = sum + 3 * double.parse (sci_calc.get_result (revised_exp.replace ("x", (lower_limit + i * interval_size).to_string()), angle_mode_in));
                    }
                }
                return Utils.manage_decimal_places ((3 * interval_size / 8) * sum, accuracy_settings.decimal_places);
            }
            else {
                return "E";
            }
        }
    }
}
