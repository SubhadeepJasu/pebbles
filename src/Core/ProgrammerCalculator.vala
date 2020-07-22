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

        public ProgrammerCalculator () {
            stored_tokens = new Token[1];
            stored_tokens[0] = new Token();
            stored_tokens[0].token = "0";
            stored_tokens[0].number_system = NumberSystem.DECIMAL;
            stored_tokens[0].type = TokenType.OPERAND;
        }

        public Token get_last_token () {
            print ("%d\n", stored_tokens.length);
            return stored_tokens[stored_tokens.length - 1];
        }

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
                    return convert_decimal_to_binary (exp);
                }
            }
            if (number_system_a == NumberSystem.BINARY) {
                if (number_system_b == NumberSystem.DECIMAL) {
                    return convert_binary_to_decimal (exp);
                }
            }
            return "";
        }

        public string convert_decimal_to_binary (string number) {
            int[] temp = new int[64];
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
        public string convert_binary_to_decimal (string number) {
            int binary = int.parse (number);
            int decimal = 0;
            int nbase = 1; 
  
            int temp = binary; 
            while (temp > 0) { 
                int last_digit = temp % 10; 
                temp = temp / 10; 
        
                decimal += last_digit * nbase; 
        
                nbase = nbase * 2; 
            } 
            return decimal.to_string ();
        }
        public string represent_binary_by_word_length (string binary_value, GlobalWordLength wrd_length, bool? format = false) {
            string new_binary = "";
            switch (wrd_length) {
                case GlobalWordLength.BYT:
                if (binary_value.length > 8) {
                    print ("bigger_value: " + binary_value + "\n");
                    new_binary = binary_value.slice (binary_value.length - 9, -1);
                } else {
                    print ("smaller_value\n");
                    string pre_zeros = "";
                    for (int i = 0; i < 8 - binary_value.length; i++) {
                        pre_zeros += "0";
                    }
                    new_binary = pre_zeros + binary_value;
                }
                break;
            }

            if (format) {
                string formatted_binary = "";
                for (int i = 0; i < new_binary.length; i++) {
                    formatted_binary += new_binary.get_char (i).to_string ();
                    if ((i + 1)%4 == 0) {
                        formatted_binary += " ";
                    }
                }
                return formatted_binary;
            }
            return new_binary;
        }
    }
}
