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
    public class ProgrammerCalculator {
        public enum TokenType {
            OPERATOR,
            OPERAND,
            PARENTHESIS
        }
        public struct Token {
            string token;
            TokenType type;
            NumberSystem number_system;
            public string to_string () {
                string str = "{\n\t\"token\": \"" + token + "\",\n\t";
                switch (type) {
                    case TokenType.OPERAND:
                    str += "\"type\": \"operand\"";
                    break;
                    case TokenType.OPERATOR:
                    str += "\"type\": \"operator\"";
                    break;
                    default:
                    str += "\"type\": \"parenthesis\"";
                    break;
                }
                
                str += ",\n\t";
                switch (number_system) {
                    case NumberSystem.BINARY:
                    str += "\"number_system\": \"binary\"";
                    break;
                    case NumberSystem.OCTAL:
                    str += "\"number_system\": \"octal\"";
                    break;
                    case NumberSystem.DECIMAL:
                    str += "\"number_system\": \"decimal\"";
                    break;
                    case NumberSystem.HEXADECIMAL:
                    str += "\"number_system\": \"hexadecimal\"";
                    break;
                }
                str += "\n}";
                
                return str;
            }
        }
        private Token[] stored_tokens;

        public void populate_token_array (string exp) {
            stored_tokens = Utils.get_token_array (exp);
            for (int i = 0; i < stored_tokens.length; i++) {
                print ("%s\n", stored_tokens[i].to_string ());
            }
            print("\n");
        }
        public string set_number_system (string exp) {
            var token_structure = Utils.get_token_array (exp);
            if (compare_token_set (token_structure, stored_tokens)) {
                for (int i = 0; i < token_structure.length; i++) {
                    if (token_structure[i].type == TokenType.OPERAND) {
                        if (token_structure[i].number_system != stored_tokens[i].number_system) {
                            stored_tokens[i].token = convert_number_system (stored_tokens[i].token, stored_tokens[i].number_system, token_structure[i].number_system);
                        }
                    }
                }
            }
            string[] token_list = new string[stored_tokens.length];
            for (int i = 0; i < stored_tokens.length; i++) {
                token_list[i] = stored_tokens[i].token;
            }
            return string.joinv (" ", token_list);
        }
        private bool compare_token_set (Token[] a, Token[] b) {
            if (a.length != b.length) {
                return false;
            }
            for (int i = 0; i < a.length; i++) {
                if (a[i].token != b[i].token) {
                    return false;
                }
            }
            return true;
        }
        private string convert_number_system (string exp, NumberSystem number_system_a, NumberSystem number_system_b) {
            print ("Number system change\n");
            print (">" + exp + "\n");
            print (" %d -> %d\n", number_system_a, number_system_b);

            if (number_system_a == NumberSystem.DECIMAL) {
                if (number_system_b == NumberSystem.BINARY) {
                    return convert_decimal_to_boolean (exp);
                }
            }
            return "";
        }

        private string convert_decimal_to_boolean (string number) {
            int[] temp = new int[number.length];
            int decimal = int.parse (number);
            int i = 0;
            for (; decimal > 0; i++) {
                temp[i] = decimal%2;
                decimal/=2;
            }
            string binary = "";
            for (i = i - 1; i >= 0; i--) {
                binary += temp[i].to_string ();
            }
            return binary;
        } 
    }
}
