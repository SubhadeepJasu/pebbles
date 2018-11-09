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
        }
    }
}
