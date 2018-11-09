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
    public class TestUtil {
        public static void show_greeter () {
            stdout.printf ("                             
 _____     _   _   _         
|  _  |___| |_| |_| |___ ___ 
|   __| -_| . | . | | -_|_ -|
|__|  |___|___|___|_|___|___|
                             \n");
            stdout.printf ("=============================================================\n\n");
            stdout.printf ("Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>\n");
            stdout.printf ("\n=============================================================\n\n");
            stdout.printf ("Running Automatic Tests...\n");
        }
        private static void test_tokenize (string exp) {
            stdout.printf ("\n'%s'", exp);
            stdout.printf ("\n -> ");
            var result = Utils.st_tokenize (exp);
            stdout.printf ("'%s'\n", result);
        }
        private static void test_scientific (string exp, string what_i_should_get, GlobalAngleUnit? angle_type = GlobalAngleUnit.DEG, int? number = 0) {
            ScientificCalculator sci_calc = new ScientificCalculator ();
            var what_i_got = sci_calc.get_result (exp, angle_type);
            try {
                if (what_i_got != what_i_should_get) {
                    stdout.printf ("[ERROR] Given '%s' in test case number %d:,\n", exp, number);
                    stdout.printf ("        I should get '%s', but I got '%s'!\n", what_i_should_get, what_i_got);
                }
            } catch (Error e) {
                stdout.printf ("[WARNING] Input error: Test Cade number: %d\n", number);
            }
        }
        public static void run_test () {
            show_greeter ();
            stdout.printf ("\nTesting Tokenization...\n");
            stdout.printf ("-------------------------------------------------------------\n");

           /* 
            * Certain UTF-8 escape characters require a space
            * after it to seperate it from the next character.
            * This is only during testing. This is however not
            * an issue when fetching input from the text entry
            * in ScientificDisplay.
            */

            test_tokenize ("sin60 + (tan 30)");
            test_tokenize ("4\xC3\xB7 2");
            test_tokenize ("sin60 + (tan 30)\xC3\x97 cos\xCF\x80 \xC3\xB7 2 + (isin 0.5 - itan 0.35 ^ icos0.854)");
            test_tokenize ("sin 45+5 \xC3\x97 isin 80 + 9 sinh \xF0\x9D\x9B\xBE + \xCF\x86 - isinh \xF0\x9D\x9B\x87(3)");
            test_tokenize ("log e\xC3\xB7 (ln K - 8P2 - 10C7)");
            stdout.printf ("\nTesting Bracket Balance Check...\n");
            stdout.printf ("-------------------------------------------------------------");
            test_tokenize ("2 + (9 - 5)\xC3\x97 5  - (8-7))");
            
            stdout.printf ("\nTesting Scientific Calculator\n");
            stdout.printf ("-------------------------------------------------------------\n");
            
            test_scientific ("2+2", "4");
            test_scientific ("4.23+    1.11", "5.34");
            test_scientific (".13+.51", "0.64");
            test_scientific ("25.123 - 234.2", "-209.077");
            test_scientific ("1*1", "1");
            test_scientific ("11 *1.1", "12.1");
            test_scientific ("5*-1", "-5");
            test_scientific ("5* - 3.000", "-15");
            test_scientific ("-1/-1", "1");
            test_scientific ("4\xC3\xB7 2", "2");
            test_scientific ("44÷2", "22");
            test_scientific ("4/2", "2");
            test_scientific ("89×5", "445");
            test_scientific ("69×52", "3,588");
            test_scientific ("-1 / (−1)", "1");
            test_scientific ("144 / 15", "9.6");
            test_scientific ("14400 / 12", "1,200");
            test_scientific ("144000 / 12", "12,000");
            test_scientific ("3456^0.5 - sqrt(3456)", "0");
            test_scientific ("3456^-0.5 * sqrt(3456)", "1");
            test_scientific ("723 mod 5", "3");
            test_scientific ("2%", "0.02");
            test_scientific ("(2 + 2)% - 0.04", "0");
            test_scientific ("14E-2", "0.14");
            test_scientific ("1.1E2 - 1E1", "100");

            test_scientific ("2 * pi", "6.283185307");
            test_scientific ("pi - 2", "1.141592654");
            test_scientific ("(π)", "3.141592654");
            test_scientific ("e", "2.718281828");

            test_scientific ("sqrt (144)", "12");
            test_scientific ("sqr 2", "4");
            test_scientific ("√423", "20.566963801");
            test_scientific ("sin(pi ÷ 2)", "1", GlobalAngleUnit.RAD);
            test_scientific ("sin(-pi)", "0", GlobalAngleUnit.RAD);
            test_scientific ("cos(90)", "0", GlobalAngleUnit.DEG);
            test_scientific ("sinh(2)", "3.626860408", GlobalAngleUnit.RAD);
            test_scientific ("cosh2", "3.762195691", GlobalAngleUnit.RAD);
            test_scientific ("sin(0.123)^2 + cos(0.123)^2", "4", GlobalAngleUnit.RAD);
            test_scientific ("tan(0.245) - sin(0.245) / cos(0.245)", "4", GlobalAngleUnit.RAD);

            test_scientific ("sqrt(5^2 - 4^2)", "3");
            test_scientific ("sqrt(423) + (3.23 * 8.56) - 1E2", "-51.784236199");
            test_scientific ("sqrt(-1 + 423 + 1) + (3.23 * 8.56) - sin(90 + 0.2)", "47.428606036");
            test_scientific ("e^5.25 / exp(5.25)", "1");
            test_scientific ("pi * pi", "9.869604404");
            test_scientific ("10 + 5 - 10%", "14.9");
        }
    }
}
