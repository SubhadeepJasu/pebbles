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
    public class Utils {
        public static bool check_parenthesis (string exp) {
            int bracket_balance = 0;
            for (int i = 0; i < exp.length; i++) {
                if (exp.get_char (i) == '(') {
                    bracket_balance++;
                }
                else if (exp.get_char (i) == ')'){
                    bracket_balance--;
                }
            }
            return (bracket_balance >= 0);
        }
        
        public static string preformat (string exp) {
            string formatted_str;
            formatted_str = exp.replace ("/", "\xC3\xB7");
            formatted_str = formatted_str.replace ("*", "\xC3\x97");
            return formatted_str;
        }

        public static string st_tokenize (string input) {
            if (check_parenthesis (input)) {
                var exp = input;

               /* 
                * Certain UTF-8 escape characters require a space
                * after it to seperate it from the next character.
                * This is only during testing. This is however not
                * an issue when fetching input from the text entry
                * in ScientificDisplay.
                */

                // Detect constants
                exp = exp.replace ("\xCF\x80", " ( 3.141592654 ) ");
                exp = exp.replace ("\xCF\x86", " ( 1.618033989 ) ");
                exp = exp.replace ("\xF0\x9D\x9B\xBE", " ( 0.5772156649 ) ");
                exp = exp.replace ("\xCE\xBB", " ( 1.30357 ) ");
                exp = exp.replace ("K", " ( 2.685452001 ) ");
                exp = exp.replace ("\xCE\xB1", " ( 2.5029 ) ");
                exp = exp.replace ("\xCE\xB4", " ( 4.6692 ) ");
                exp = exp.replace ("\xF0\x9D\x9B\x87(3)", " ( 1.2020569 ) ");
                
                exp = exp.down ();
                
                // Convert to lexemes
                exp = exp.replace ("isinh", " [0] ");
                exp = exp.replace ("icosh", " [1] ");
                exp = exp.replace ("itanh", " [2] ");
                exp = exp.replace ("isin", " [3] ");
                exp = exp.replace ("icos", " [4] ");
                exp = exp.replace ("itan", " [5] ");
                exp = exp.replace ("sinh", " [6] ");
                exp = exp.replace ("cosh", " [7] ");
                exp = exp.replace ("tanh", " [8] ");
                exp = exp.replace ("sin", " [9] ");
                exp = exp.replace ("cos", " [10] ");
                exp = exp.replace ("tan", " [11] ");
                exp = exp.replace ("log", " log ");
                exp = exp.replace ("ln", " ln ");
                exp = exp.replace ("m", " m ");
                exp = exp.replace ("p", " p ");
                exp = exp.replace ("c", " c ");

                // Convert to symbolic terms and introduce additional spaces
                exp = exp.replace ("i", " ( 0 - 1 ^ ( 0.5 ) ) ");
                exp = exp.replace ("e", " ( 2.718281828 ) ");
                exp = exp.replace ("[0]", " r ");
                exp = exp.replace ("[1]", " z ");
                exp = exp.replace ("[2]", " k ");
                exp = exp.replace ("[3]", " i ");
                exp = exp.replace ("[4]", " o ");
                exp = exp.replace ("[5]", " a ");
                exp = exp.replace ("[6]", " h ");
                exp = exp.replace ("[7]", " y ");
                exp = exp.replace ("[8]", " e ");
                exp = exp.replace ("[9]", " s ");
                exp = exp.replace ("[10]", " c ");
                exp = exp.replace ("[11]", " t ");
                exp = exp.replace ("log", " l ");
                exp = exp.replace ("ln" , " n ");
                exp = exp.replace ("(", " ( ");
                exp = exp.replace (")", " ) ");
                exp = exp.replace ("\xC3\x97", " * ");
                exp = exp.replace ("\xC3\xB7", " / ");
                exp = exp.replace ("+", " + ");
                exp = exp.replace ("-", " - ");
                exp = exp.replace ("^", " ^ ");
                exp = exp.replace ("!", " ! ");

                return exp;
            }
            else {
                return "E";
            }
        }
    }
}
