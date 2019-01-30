/*-
 * Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright (c) 2017-2018 Saunak Biswas <saunakbis97@gmail.com>
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
                exp = exp.replace ("\xCF\x80", " ( 3.1415926535897932 ) ");
                exp = exp.replace ("\xCF\x86", " ( 1.618033989 ) ");
                exp = exp.replace ("\xF0\x9D\x9B\xBE", " ( 0.5772156649 ) ");
                exp = exp.replace ("\xCE\xBB", " ( 1.30357 ) ");
                exp = exp.replace ("K", " ( 2.685452001 ) ");
                exp = exp.replace ("\xCE\xB1", " ( 2.5029 ) ");
                exp = exp.replace ("\xCE\xB4", " ( 4.6692 ) ");
                exp = exp.replace ("\xF0\x9D\x9B\x87(3)", " ( 1.2020569 ) ");
                exp = exp.replace ("E", " * 10 ^ ");
                exp = exp.replace ("pi", " ( 3.1415926535897932 ) ");
                
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
                exp = exp.replace ("log\xE2\x82\x81\xE2\x82\x80", " 10 log ");
                exp = exp.replace ("log", " log ");
                exp = exp.replace ("ln", " e log ");
                exp = exp.replace ("mod", " m ");
                exp = exp.replace ("p", " p ");
                exp = exp.replace ("P", " p ");
                exp = exp.replace ("C", " b ");
                exp = exp.replace ("c", " b ");

                // Convert to symbolic terms and introduce additional spaces
                exp = exp.replace ("i", " ( 0 - 1 ^ ( 0.5 ) ) ");
                exp = exp.replace ("e", " ( 2.718281828 ) ");
                exp = exp.replace ("[0]", " 0 r ");
                exp = exp.replace ("[1]", " 0 z ");
                exp = exp.replace ("[2]", " 0 k ");
                exp = exp.replace ("[3]", " 0 i ");
                exp = exp.replace ("[4]", " 0 o ");
                exp = exp.replace ("[5]", " 0 a ");
                exp = exp.replace ("[6]", " 0 h ");
                exp = exp.replace ("[7]", " 0 y ");
                exp = exp.replace ("[8]", " 0 e ");
                exp = exp.replace ("[9]", " 0 s ");
                exp = exp.replace ("[10]", " 0 c ");
                exp = exp.replace ("[11]", " 0 t ");
                exp = exp.replace ("log", " l ");
                exp = exp.replace ("(", " ( ");
                exp = exp.replace (")", " ) ");
                exp = exp.replace ("\xC3\x97", " * ");
                exp = exp.replace ("\xC3\xB7", " / ");
                exp = exp.replace ("%", " / 100 ");
                exp = exp.replace ("+", " + ");
                exp = exp.replace ("-", " - ");
                exp = exp.replace ("−", " - ");
                exp = exp.replace ("*", " * ");
                exp = exp.replace ("/", " / ");
                exp = exp.replace ("^", " ^ ");
                exp = exp.replace ("\xE2\x81\xBF√", " q ");
                exp = exp.replace ("sqrt", " 2 q ");
                exp = exp.replace ("√", " 2 q ");
                exp = exp.replace ("sqr", " ^ 2 ");
                exp = exp.replace ("rt", " q ");
                exp = exp.replace ("!", " ! ");

                exp = exp.strip ();
                exp = space_removal (exp);
                
                // Take care of unary subtraction
                exp = uniminus_convert (exp);
                //stdout.printf ("'%s'\n", exp);
                return exp;
            }
            else {
                return "E";
            }
        }
        private static string space_removal(string original) {
            int i = 0,j = 0;
            string result = "";
            while(i < original.length) {
                j = i + 1;
                if(original.get_char(i).to_string() == " ") {
                    while(original.get_char(j).to_string() == " ") {
                        j++;
                    }
                    result = result + " ";
                    i = j;
                }
                else {
                    result = result + original.get_char(i).to_string();
                    i++;
                }
            }
            return result;
        }
        private static string uniminus_convert (string exp) {
            string uniminus_converted = "";
            string[] tokens = exp.split (" ");
            for (int i = 1; i < tokens.length; i++) {
                if (tokens[i] == "-") {
                    if (tokens [i - 1] == ")" || tokens [i - 1] == "x" || is_number (tokens [i - 1]) ) {
                        tokens [i] = "-";
                    }
                    else {
                        tokens [i] = "u";
                    }
                }
            }
            uniminus_converted = string.joinv (" ", tokens);
            uniminus_converted = uniminus_converted.replace ("u", "0 u");
            return uniminus_converted;
        }
        
        private static bool is_number (string exp) {
            if (exp.has_suffix ("0") ||
                exp.has_suffix ("1") ||
                exp.has_suffix ("2") ||
                exp.has_suffix ("3") ||
                exp.has_suffix ("4") ||
                exp.has_suffix ("5") ||
                exp.has_suffix ("6") ||
                exp.has_suffix ("7") ||
                exp.has_suffix ("8") ||
                exp.has_suffix ("9") ||
                exp.has_suffix (".")
                ) {
                    return true;
                }
                return false;
        } 
    }
}
