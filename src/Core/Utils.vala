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
 *              Saunak Biswas  <saunakbis97@gmail.com>
 */

namespace Pebbles {
    public class Utils {
        public static string get_local_radix_symbol () {
            return Posix.nl_langinfo (Posix.NLItem.RADIXCHAR);
        }

        public static string get_local_separator_symbol () {
            return Posix.nl_langinfo (Posix.NLItem.THOUSEP);
        }

        public static string format_result (string result) {
            string output = result.replace (".", Utils.get_local_radix_symbol ());
            if (!result.contains(Utils.get_local_radix_symbol ())) {
                output += Utils.get_local_radix_symbol () + "0";
            }

            // Remove trailing 0s and decimals
            while (output.has_suffix ("0")) {
                output = output.slice (0, -1);
            }
            if (output.has_suffix (Utils.get_local_radix_symbol ())) {
                output = output.slice (0, -1);
            }

            // Insert separator symbol in large numbers
            StringBuilder output_builder = new StringBuilder (output);
            var decimalPos = output.last_index_of (Utils.get_local_radix_symbol ());
            if (decimalPos == -1) {
                decimalPos = output.length;
            }
            int end_position = 0;

            // Take care of minus sign at the beginning of string, if any
            if (output.has_prefix ("-")) {
                end_position = 1;
            }
            for (int i = decimalPos - 3; i > end_position; i -= 3) {
                output_builder.insert (i, Utils.get_local_separator_symbol ());
            }

            if (output_builder.str == "-0") {
                return "0";
            }
            if (output_builder.str == "nan")
                output_builder.str = "E";
            if (output_builder.str == "inf")
                output_builder.str = "∞";
            return output_builder.str;
        }
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
                exp = exp.replace ("\xF0\x9D\x91\x83", " ( 2.29558714939 ) ");
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
                exp = exp.replace ("i", " ( ( 0 - 1 ) ^ ( 0.5 ) ) ");
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
                exp = exp.replace ("%", " % ");
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
                exp = exp.replace ("∞", "inf");

                exp = exp.strip ();
                exp = space_removal (exp);

                // Intelligently convert expressions based on common rules
                exp = algebraic_parenthesis_product_convert (exp);
                exp = unary_minus_convert (exp);
                var regex = new Regex (".+ [+|-] .+%");
                bool percent_pattern_matched = regex.match (exp, 0);
                while (percent_pattern_matched) {
                    exp = relative_percentage_convert(exp);
                    percent_pattern_matched = regex.match (exp, 0);
                }
                if (!percent_pattern_matched) {
                    exp = exp.replace ("%", "/ 100");
                }

                exp = space_removal (exp.strip ());
                debug ("Final inferred expression: >>>>" + exp + "<<<<\n");
                return exp;
            }
            else {
                return "E";
            }
        }

        public string pg_tokenize (string input) {
            if (check_parenthesis (input)) {
                var exp = input;
                exp = exp.replace ("lsh", " [0] ");
                exp = exp.replace ("rsh", " [1] ");
                exp = exp.replace ("lr", " [2] ");
                exp = exp.replace ("rr", " [3] ");
                exp = exp.replace ("not", " [4] ");
                exp = exp.replace ("nand", " [5] ");
                exp = exp.replace ("xnor", " [6]] ");
                exp = exp.replace ("xor", " [7] ");
                exp = exp.replace ("nor", " [8] ");
                exp = exp.replace ("and", " [9] ");
                exp = exp.replace ("or", " [10] ");
                exp = exp.replace ("mod", " [11] ");

                exp = exp.replace ("[0]", " 0 < ");
                exp = exp.replace ("[1]", " 0 > ");
                exp = exp.replace ("[2]", " 0 k ");
                exp = exp.replace ("[3]", " 0 q ");
                exp = exp.replace ("[4]", " n ");
                exp = exp.replace ("[5]", " r ");
                exp = exp.replace ("[6]", " 0 t ");
                exp = exp.replace ("[7]", " y ");
                exp = exp.replace ("[8]", " w ");
                exp = exp.replace ("[9]", " x ");
                exp = exp.replace ("[10]", " z ");
                exp = exp.replace ("[11]", " m ");
                exp = exp.replace ("(", " ( ");
                exp = exp.replace (")", " ) ");
                exp = exp.replace ("+", " + ");
                exp = exp.replace ("-", " - ");
                exp = exp.replace ("−", " - ");
                exp = exp.replace ("\xC3\x97", " * ");
                exp = exp.replace ("\xC3\xB7", " / ");
                exp = exp.replace ("*", " * ");
                exp = exp.replace ("/", " / ");
                exp = exp.strip ();
                exp = space_removal (exp);

                // Intelligently convert expressions based on common rules
                exp = algebraic_parenthesis_product_convert (exp);
                exp = unary_minus_convert (exp);

                debug ("Final inferred expression: " + exp);
                return exp;
            }

            return "E";
        }
        public static ProgrammerCalculator.Token[] get_token_array (string input_exp) {
            var settings = Pebbles.Settings.get_default ();

            var exp = input_exp.replace ("lsh", " < ");
            exp = exp.replace ("rsh", " > ");
            exp = exp.replace ("lr", " lr ");
            exp = exp.replace ("rr", " rr ");
            exp = exp.replace ("not", " ! ");
            exp = exp.replace ("nand", " [5] ");
            exp = exp.replace ("xnor", " [6] ");
            exp = exp.replace ("xor", " [7] ");
            exp = exp.replace ("nor", " [8] ");
            exp = exp.replace ("and", " & ");
            exp = exp.replace ("or", " | ");
            exp = exp.replace ("mod", " m ");
            exp = exp.replace ("[5]", " _ ");
            exp = exp.replace ("[6]", " n ");
            exp = exp.replace ("[7]", " x ");
            exp = exp.replace ("[8]", " o ");
            exp = exp.replace ("(", " ( ");
            exp = exp.replace (")", " ) ");
            exp = exp.replace ("+", " + ");
            exp = exp.replace ("-", " - ");
            exp = exp.replace ("−", " - ");
            exp = exp.replace ("\xC3\x97", " * ");
            exp = exp.replace ("\xC3\xB7", " / ");
            exp = exp.replace ("*", " * ");
            exp = exp.replace ("/", " / ");
            exp = exp.strip ();
            exp = space_removal (exp);

            string str_with_unform_spaces = space_removal (exp);
            string[] str_tokens = str_with_unform_spaces.split (" ");
            ProgrammerCalculator.Token[] tokens = new ProgrammerCalculator.Token[str_tokens.length];
            for (int i = 0; i < str_tokens.length; i++) {
                switch (str_tokens[i]) {
                    case "<":
                    case ">":
                    case "lr":
                    case "rr":
                    case "!":
                    case "_":
                    case "n":
                    case "x":
                    case "o":
                    case "&":
                    case "|":
                    case "m":
                    case "+":
                    case "-":
                    case "/":
                    case "*":
                    tokens[i].type = ProgrammerCalculator.TokenType.OPERATOR;
                    break;
                    case "(":
                    case ")":
                    tokens[i].type = ProgrammerCalculator.TokenType.PARENTHESIS;
                    break;
                    default:
                    tokens[i].type = ProgrammerCalculator.TokenType.OPERAND;
                    break;
                }
                tokens[i].token = remove_leading_zeroes(str_tokens[i]);
                tokens[i].number_system = settings.number_system;
            }

            return tokens;
        }

        public static string get_natural_expression (string str) {
            string ret_val = str;
            ret_val = ret_val.replace ("<", "lsh");
            ret_val = ret_val.replace (">", "rsh");
            ret_val = ret_val.replace ("!", "[0]");
            ret_val = ret_val.replace ("&", "[1]");
            ret_val = ret_val.replace ("|", "[2]");
            ret_val = ret_val.replace ("m", "[3]");
            ret_val = ret_val.replace ("_", "[4]");
            ret_val = ret_val.replace ("o", "[5]");
            ret_val = ret_val.replace ("x", "[6]");
            ret_val = ret_val.replace ("n", "[7]");
            ret_val = ret_val.replace ("[0]", "not");
            ret_val = ret_val.replace ("[1]", "and");
            ret_val = ret_val.replace ("[2]", "or");
            ret_val = ret_val.replace ("[3]", "mod");
            ret_val = ret_val.replace ("[4]", "nand");
            ret_val = ret_val.replace ("[5]", "nor");
            ret_val = ret_val.replace ("[6]", "xor");
            ret_val = ret_val.replace ("[7]", "xnor");
            ret_val = ret_val.replace ("*", "\xC3\x97");
            ret_val = ret_val.replace ("/", "\xC3\xB7");
            ret_val = ret_val.replace ("-", "−");
            return ret_val;
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
        private static string unary_minus_convert (string exp) {
            string uniminus_converted = "";
            string[] tokens = exp.split (" ");
            for (int i = 0; i < tokens.length; i++) {
                if (tokens[i] == "-") {
                    if (i == 0) {
                        if (i < tokens.length) {
                            tokens [i] = "( 0 u";
                            tokens [i + 1] = tokens [i + 1] + " )";
                        }
                    } else if (tokens [i - 1] == ")" || tokens [i - 1] == "x" || is_number (tokens [i - 1]) ) {
                        tokens [i] = "-";
                    } else {
                        if (i < tokens.length) {
                            tokens [i] = "( 0 u";
                            tokens [i + 1] = tokens [i + 1] + " )";
                        }
                    }
                }
            }
            uniminus_converted = string.joinv (" ", tokens);
            //uniminus_converted = uniminus_converted.replace ("u", "0 u");
            return uniminus_converted;
        }

        public static string algebraic_variable_product_convert (string exp) {
            string converted_exp = "";
            string[] tokens = exp.replace("x", " x ").split (" ");
            for (int i = 1; i < tokens.length; i++) {
                if (tokens[i] == "x" && is_number(tokens[i - 1]) && tokens[i - 1] != "(") {
                    tokens[i] = "* x";
                }
            }
            converted_exp = space_removal(string.joinv (" ", tokens));
            return converted_exp;
        }

        public static string algebraic_parenthesis_product_convert (string exp) {
            string[] tokens = exp.split (" ");
            for (int i = 1; i < tokens.length - 1; i++) {
                if (tokens[i] == "(") {
                    if (is_number (tokens[i - 1])) {
                        tokens[i] = "* (";
                    }
                }
                if (tokens[i] == ")") {
                    if (is_number (tokens[i + 1]) || tokens[i + 1] == "(") {
                        tokens[i] = ") *";
                    }
                }
            }
            string converted_exp = space_removal(string.joinv (" ", tokens));
            return converted_exp;
        }

        public static string relative_percentage_convert (string exp) {
            if (exp.contains ("%")) {
                // Expression is of the form `a +/- b  %`
                debug ("Percentage////////////////////\n");
                debug ("Exp: %s\n", exp);
                string exp_a = "";
                string exp_b = "";
                string[] tokens = exp.split (" ");
                int percentage_index = -1;
                for (int i = tokens.length - 1; i > 0; i--) {
                    if (tokens[i] == "%") {
                        percentage_index = i;
                        tokens[i] = "[%]";
                        break;
                    }
                }
                if (is_number (tokens[percentage_index - 1])) {
                    exp_b = tokens[percentage_index - 1];
                    if (tokens[percentage_index - 2] != null &&
                        (tokens[percentage_index - 2] == "+" ||
                        tokens[percentage_index - 2] == "-")) {
                        if (tokens[percentage_index - 3] != null) {
                            if (tokens[percentage_index - 3] == ")") {
                                int paren_balance = -1;
                                int paren_start_index = -1;
                                for (int i = percentage_index - 4; i >= 0; i--) {
                                    if (tokens[i] == "(") {
                                        paren_balance++;
                                    } else if (tokens[i] == ")") {
                                        paren_balance--;
                                    }
                                    if (paren_balance == 0) {
                                        paren_start_index = i;
                                        break;
                                    }
                                }
                                if (paren_start_index >= 0) {
                                    string[] tokens_in_range = tokens[paren_start_index:percentage_index - 2];
                                    for (int i = 0; i < tokens_in_range.length; i++) {
                                        exp_a += " " + tokens_in_range[i] + " ";
                                    }
                                    exp_a = space_removal (exp_a);
                                    string result = string.joinv (" ", tokens);
                                    result = space_removal(result);
                                    return result.replace("[%]", " * " + exp_a + " / 100 ");
                                }
                            } else if (is_number (tokens[percentage_index - 3])) {
                                exp_a = tokens[percentage_index - 3];
                                string result = string.joinv (" ", tokens);
                                result = space_removal(result);
                                return result.replace("[%]", " * " + exp_a + " / 100 ");
                            }
                        }
                    }
                } else if (tokens[percentage_index - 1] == ")") {
                    int paren_balance_b = -1;
                    int paren_start_index_b = -1;
                    for (int i = percentage_index - 2; i >= 0; i--) {
                        if (tokens[i] == "(") {
                            paren_balance_b++;
                        } else if (tokens[i] == ")") {
                            paren_balance_b--;
                        }
                        if (paren_balance_b == 0) {
                            paren_start_index_b = i;
                            break;
                        }
                    }
                    if (paren_start_index_b >= 0) {
                        string[] tokens_in_range = tokens[paren_start_index_b:percentage_index - 2];
                        for (int i = 0; i < tokens_in_range.length; i++) {
                            exp_b += " " + tokens_in_range[i] + " ";
                        }
                        exp_b = space_removal (exp_b);
                    }
                    if (tokens[paren_start_index_b - 1] != null &&
                        (tokens[paren_start_index_b - 1] == "+" ||
                        tokens[paren_start_index_b - 1] == "-")) {
                        if (tokens[paren_start_index_b - 2] != null) {
                            if (tokens[paren_start_index_b - 2] == ")") {
                                int paren_balance = -1;
                                int paren_start_index = -1;
                                for (int i = paren_start_index_b - 3; i >= 0; i--) {
                                    if (tokens[i] == "(") {
                                        paren_balance++;
                                    } else if (tokens[i] == ")") {
                                        paren_balance--;
                                    }
                                    if (paren_balance == 0) {
                                        paren_start_index = i;
                                        break;
                                    }
                                }
                                if (paren_start_index >= 0) {
                                    string[] tokens_in_range = tokens[paren_start_index:paren_start_index_b - 1];
                                    for (int i = 0; i < tokens_in_range.length; i++) {
                                        exp_a += " " + tokens_in_range[i] + " ";
                                    }
                                    exp_a = space_removal (exp_a);
                                    string result = string.joinv (" ", tokens);
                                    result = space_removal(result);
                                    return result.replace("[%]", " * " + exp_a + " / 100 ");
                                }
                            } else if (is_number (tokens[paren_start_index_b - 2])) {
                                exp_a = tokens[paren_start_index_b - 2];
                                string result = string.joinv (" ", tokens);
                                result = space_removal(result);
                                return result.replace("[%]", " * " + exp_a + " / 100 ");
                            }
                        }
                    }
                }
                string result = string.joinv (" ", tokens);
                result = space_removal(result);
                return result.replace("[%]", " / 100 ");
            }
            return exp;
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
                exp.has_suffix (".") ||
                exp.has_suffix ("x")
                ) {
                    return true;
                }
                return false;
        }
        public static string manage_decimal_places (double result, int accuracy) {
            string output = "";
            switch (accuracy) {
                case 10:
                    output = ("%.10lf".printf (result));
                    break;
                case 9:
                    output = ("%.9lf".printf (result));
                    break;
                case 8:
                    output = ("%.8lf".printf (result));
                    break;
                case 7:
                    output = ("%.7lf".printf (result));
                    break;
                case 6:
                    output = ("%.6lf".printf (result));
                    break;
                case 5:
                    output = ("%.5lf".printf (result));
                    break;
                case 4:
                    output = ("%.4lf".printf (result));
                    break;
                case 3:
                    output = ("%.3lf".printf (result));
                    break;
                case 2:
                    output = ("%.2lf".printf (result));
                    break;
                case 1:
                    output = ("%.1lf".printf (result));
                    break;
                case 0:
                    output = ((int) result).to_string();
                    break;
                default:
                    output = result.to_string ();
                    break;
            }
            return output;
        }

        public static string remove_leading_zeroes (string text) {
            if (text == "0") {
                return "0";
            }
            int n = -1;
            for (int i = 0; i < text.length; i++) {
                if (text.get_char(i) != '0') {
                    n = i;
                    break;
                }
            }
            return text.substring(n);
        }
    }
}
