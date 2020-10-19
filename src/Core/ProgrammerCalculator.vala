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
        private const char[] HEXADECIMAL_DIGITS = { 'a', 'b', 'c', 'd', 'e', 'f'};
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
            stored_tokens[0] = Token();
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
        public string set_number_system (string exp, GlobalWordLength? wrd_length = GlobalWordLength.BYT) {
            var token_structure = Utils.get_token_array (exp);
            if (compare_token_set (token_structure, stored_tokens)) {
                for (int i = 0; i < token_structure.length; i++) {
                    if (token_structure[i].type == TokenType.OPERAND) {
                        if (token_structure[i].number_system != stored_tokens[i].number_system) {
                            stored_tokens[i].token = convert_number_system (stored_tokens[i].token, stored_tokens[i].number_system, token_structure[i].number_system, wrd_length);
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
        private string convert_number_system (string exp, NumberSystem number_system_a, NumberSystem number_system_b, GlobalWordLength? wrd_length = GlobalWordLength.WRD) {
            print ("Number system change\n");
            print (">" + exp + "\n");
            print (" %d -> %d\n", number_system_a, number_system_b);

            if (number_system_a == NumberSystem.DECIMAL) {
                if (number_system_b == NumberSystem.BINARY) {
                    return convert_decimal_to_binary (exp, wrd_length);
                }
                if (number_system_b == NumberSystem.HEXADECIMAL) {
                    return convert_decimal_to_hexadecimal (exp, wrd_length);
                }
                if (number_system_b == NumberSystem.OCTAL) {
                    return convert_decimal_to_octal (exp, wrd_length);
                }
            }
            if (number_system_a == NumberSystem.BINARY) {
                if (number_system_b == NumberSystem.DECIMAL) {
                    return convert_binary_to_decimal (exp, wrd_length);
                }
                if (number_system_b == NumberSystem.HEXADECIMAL) {
                    return convert_binary_to_hexadecimal (exp, wrd_length);
                }
                if (number_system_b == NumberSystem.OCTAL) {
                    return convert_binary_to_octal (exp, wrd_length);
                }
            }
            if (number_system_a == NumberSystem.HEXADECIMAL) {
                if (number_system_b == NumberSystem.DECIMAL) {
                    return convert_hexadecimal_to_decimal (exp, wrd_length);
                }
                if (number_system_b == NumberSystem.BINARY) {
                    return convert_hexadecimal_to_binary (exp, wrd_length);
                }
                if (number_system_b == NumberSystem.OCTAL) {
                    return convert_hexadecimal_to_octal (exp, wrd_length);
                }
            }
            if (number_system_a == NumberSystem.OCTAL) {
                if (number_system_b == NumberSystem.DECIMAL) {
                    return convert_octal_to_decimal (exp, wrd_length);
                }
                if (number_system_b == NumberSystem.BINARY) {
                    return convert_octal_to_binary (exp, wrd_length);
                }
                if (number_system_b == NumberSystem.HEXADECIMAL) {
                    return convert_octal_to_hexadecimal (exp, wrd_length);
                }
            }
            return "";
        }

        public string convert_decimal_to_binary (string number, GlobalWordLength? wrd_length = GlobalWordLength.WRD, bool? format = false) {
            int[] temp = new int[64];
            int64 decimal = int64.parse (number);
            int i = 0;
            for (; decimal > 0; i++) {
                temp[i] = (int)Math.fabs(decimal%2);
                decimal/=2;
            }
            string binary = "";
            for (i = i - 1; i >= 0; i--) {
                binary += temp[i].to_string ();
            }
            return represent_binary_by_word_length (binary, wrd_length, format);
        } 
        public string convert_binary_to_decimal (string number, GlobalWordLength? wrd_length = GlobalWordLength.WRD) {
            string formatted_binary = represent_binary_by_word_length (number, wrd_length);
            int64 decimal = 0; 
            int64.from_string (formatted_binary, out decimal, 2);
            return decimal.to_string ();
        }
        public string represent_binary_by_word_length (string binary_value, GlobalWordLength wrd_length = GlobalWordLength.BYT, bool? format = false) {
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
                    if (format)
                        new_binary = pre_zeros + binary_value;
                }
                break;
                case GlobalWordLength.WRD:
                if (binary_value.length > 16) {
                    print ("bigger_value: " + binary_value + "\n");
                    new_binary = binary_value.slice (binary_value.length - 17, -1);
                } else {
                    print ("smaller_value\n");
                    string pre_zeros = "";
                    for (int i = 0; i < 16 - binary_value.length; i++) {
                        pre_zeros += "0";
                    }
                    new_binary = pre_zeros + binary_value;
                }
                break;
                case GlobalWordLength.DWD:
                if (binary_value.length > 32) {
                    print ("bigger_value: " + binary_value + "\n");
                    new_binary = binary_value.slice (binary_value.length - 33, -1);
                } else {
                    print ("smaller_value\n");
                    string pre_zeros = "";
                    for (int i = 0; i < 32 - binary_value.length; i++) {
                        pre_zeros += "0";
                    }
                    new_binary = pre_zeros + binary_value;
                }
                break;
                case GlobalWordLength.QWD:
                if (binary_value.length > 64) {
                    print ("bigger_value: " + binary_value + "\n");
                    new_binary = binary_value.slice (binary_value.length - 65, -1);
                } else {
                    print ("smaller_value\n");
                    string pre_zeros = "";
                    for (int i = 0; i < 64 - binary_value.length; i++) {
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
                    if ((i + 1)%8 == 0) {
                        formatted_binary += " ";
                    }
                }
                return formatted_binary;
            }
            return new_binary;
        }

        public string convert_decimal_to_hexadecimal (string number, GlobalWordLength? wrd_length = GlobalWordLength.WRD) {
            int n = int.parse (number);
            string hexa = "";

            int i = 0;
            while (n != 0) {
                int temp = 0;
                temp = n % 16;
                if (temp < 10) {
                    hexa += temp.to_string ();
                } else {
                    hexa += HEXADECIMAL_DIGITS [temp - 10].to_string ();
                } 
                i++;
                n /= 16;
            }

            string hex_value = "";
            for (int j = i - 1; j >= 0; j--) {
                hex_value += hexa[j].to_string ();
            }
            return hex_value;
        }

        public string convert_hexadecimal_to_decimal (string number, GlobalWordLength? wrd_length = GlobalWordLength.WRD) {
            string binary_value = convert_hexadecimal_to_binary (number, wrd_length, false);
            string decimal = convert_binary_to_decimal (binary_value, wrd_length);
            print(number + ", " + binary_value + ", " + decimal);
            return decimal.to_string ();
        }

        public string convert_hexadecimal_to_binary(string hex_value, GlobalWordLength? wrd_length = GlobalWordLength.WRD, bool? format = false) 
        { 
            long i = 0; 
            string binary_value = "";
            while (i < hex_value.length) { 
        
                switch (hex_value.get_char (i)) { 
                case '0': 
                    binary_value += "0000"; 
                    break; 
                case '1': 
                    binary_value += "0001"; 
                    break; 
                case '2': 
                    binary_value += "0010"; 
                    break; 
                case '3': 
                    binary_value += "0011"; 
                    break; 
                case '4': 
                    binary_value += "0100"; 
                    break; 
                case '5': 
                    binary_value += "0101"; 
                    break; 
                case '6': 
                    binary_value += "0110"; 
                    break; 
                case '7': 
                    binary_value += "0111"; 
                    break; 
                case '8': 
                    binary_value += "1000"; 
                    break; 
                case '9': 
                    binary_value += "1001"; 
                    break; 
                case 'A': 
                case 'a': 
                    binary_value += "1010"; 
                    break; 
                case 'B': 
                case 'b': 
                    binary_value += "1011"; 
                    break; 
                case 'C': 
                case 'c': 
                    binary_value += "1100"; 
                    break; 
                case 'D': 
                case 'd': 
                    binary_value += "1101"; 
                    break; 
                case 'E': 
                case 'e': 
                    binary_value += "1110"; 
                    break; 
                case 'F': 
                case 'f': 
                    binary_value += "1111"; 
                    break; 
                default: 
                    break;
                } 
                i++; 
            } 
            
            string formatted_binary = represent_binary_by_word_length (binary_value, wrd_length, format);
            print(">>>>>>" + binary_value+"<<<"+formatted_binary+">>>\n");
            return formatted_binary;
        } 
        public static string map_bin_to_hex (string bin) {
            switch (bin) {
                case "0000":
                return "0";
                case "0001":
                return "1";
                case "0010":
                return "2"; 
                case "0011":
                return "3"; 
                case "0100":
                return "4"; 
                case "0101":
                return "5"; 
                case "0110":
                return "6"; 
                case "0111":
                return "7"; 
                case "1000":
                return "8"; 
                case "1001":
                return "9"; 
                case "1010":
                return "a"; 
                case "1011":
                return "b"; 
                case "1100":
                return "b"; 
                case "1101":
                return "d"; 
                case "1110":
                return "e"; 
                case "1111":
                return "f"; 
            }
            return "";
        }

        public string convert_binary_to_hexadecimal (string bin_value, GlobalWordLength? wrd_length = GlobalWordLength.BYT) {
            string bin = represent_binary_by_word_length (bin_value, wrd_length, false);
            int l = bin.length;
            int t = bin.index_of_char ('.', 0);
            int len_left = t != -1 ? t : l; 
            for (int i = 1; i <= (4 - len_left % 4) % 4; i++) 
                bin = "0" + bin; 
            
            // if decimal point exists     
            if (t != -1)     
            { 
                // length of string after '.' 
                int len_right = l - len_left - 1; 
                
                // add min 0's in the end to make right 
                // substring length divisible by 4  
                for (int i = 1; i <= (4 - len_right % 4) % 4; i++) 
                    bin = bin + "0"; 
            } 

            int i = 0;
            string hex_value = "";

            while (true) {
                // one by one extract from left, substring 
                // of size 4 and add its hex code 
                hex_value += map_bin_to_hex(bin.substring(i, 4)); 
                i += 4; 
                if (i == bin.length) 
                    break; 
                    
                // if '.' is encountered add it 
                // to result 
                if (bin.get_char(i) == '.')     
                { 
                    hex_value += "."; 
                    i++; 
                } 
            }
            while (hex_value.has_prefix ("0")) {
                hex_value = hex_value.splice (0, 1, "");
            }
            return (hex_value == "") ? "0" : hex_value;
        }

        public string convert_binary_to_octal (string bin_value, GlobalWordLength? wrd_length = GlobalWordLength.BYT) {

            string binary_string = represent_binary_by_word_length (bin_value, wrd_length);
            uint64 octalNum = 0, decimalNum = 0, count = 1;
            decimalNum = uint64.parse(convert_binary_to_decimal(binary_string, wrd_length));
            while (decimalNum != 0) {
               octalNum += (uint64)Math.fabs(decimalNum % 8) * count;
               decimalNum = (uint64)(decimalNum / 8);
               count *= 10;
            }
            return octalNum.to_string();
        }

        public string convert_decimal_to_octal (string dec_value, GlobalWordLength? wrd_length = GlobalWordLength.BYT) {
            string bin_value = convert_decimal_to_binary (dec_value, wrd_length);
            return convert_binary_to_octal (bin_value, wrd_length);
        }

        public string convert_hexadecimal_to_octal (string hex_value, GlobalWordLength? wrd_length = GlobalWordLength.BYT) {
            string bin_value = convert_hexadecimal_to_binary (hex_value, wrd_length);
            return convert_binary_to_octal (bin_value, wrd_length);
        }

        public string convert_octal_to_binary (string oct_value, GlobalWordLength? wrd_length = GlobalWordLength.BYT, bool? format = false) {
            int64 octalNum = int64.parse (oct_value);
            int64 decimalNum = 0, binaryNum = 0, count = 0;

            while(octalNum != 0) {
                decimalNum += (int64)((octalNum%10) * pow64(8,count));
                ++count;
                octalNum/=10;
            }
            string bin_value = convert_decimal_to_binary (decimalNum.to_string (), wrd_length);
            bin_value = represent_binary_by_word_length (bin_value, wrd_length, format);
            return bin_value;
        }
        public string convert_octal_to_decimal (string oct_value, GlobalWordLength? wrd_length = GlobalWordLength.BYT) {
            string bin_value = convert_octal_to_binary (oct_value, wrd_length);
            return convert_binary_to_decimal (bin_value, wrd_length);
        }
        public string convert_octal_to_hexadecimal (string oct_value, GlobalWordLength? wrd_length = GlobalWordLength.BYT) {
            string bin_value = convert_octal_to_binary (oct_value, wrd_length);
            return convert_binary_to_hexadecimal (bin_value, wrd_length);
        }
        private uint64 pow64 (uint64 a, uint64 b) {
            uint64 c = 1;
            for (uint64 i = 0; i < b; i++) {
                c *= a;
            }
            return c;
        }
    }
}
