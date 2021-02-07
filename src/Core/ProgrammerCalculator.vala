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
        public string convert_binary_to_decimal (string number, GlobalWordLength? wrd_length = GlobalWordLength.WRD, bool? negative = false) {
            string formatted_binary = represent_binary_by_word_length (number, wrd_length);
            int64 decimal = 0;
            string converted_binary = formatted_binary;
            if (negative) {
                converted_binary = "";
                for (int i = 0; i < formatted_binary.length; i++) {
                    converted_binary += (formatted_binary.get(i) == '1') ? "0" : "1";
                }
                int64.from_string (converted_binary, out decimal, 2);
                return "-" + (decimal + 1).to_string ();
            }
            int64.from_string (converted_binary, out decimal, 2);
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

        public string convert_binary_to_hexadecimal (string bin_value, GlobalWordLength? wrd_length = GlobalWordLength.BYT, bool? negative = false) {
            string bin = represent_binary_by_word_length (bin_value, wrd_length, false);
            int i = 0;
            string hex_value = "";
            string converted_binary = bin;
            if (negative) {
                converted_binary = "";
                for (i = 0; i < bin.length; i++) {
                    converted_binary += (bin.get(i) == '1') ? "0" : "1";
                }
            }
            i = 0;
            while (true) {
                // one by one extract from left, substring 
                // of size 4 and add its hex code 
                hex_value += map_bin_to_hex(converted_binary.substring(i, 4)); 
                i += 4; 
                if (i == converted_binary.length || converted_binary == "") 
                    break; 
                // if '.' is encountered add it 
                // to result 
                if (converted_binary.get_char(i) == '.')     
                { 
                    hex_value += "."; 
                    i++; 
                } 
            }
            while (hex_value.has_prefix ("0")) {
                hex_value = hex_value.splice (0, 1, "");
            }
            if (negative) {
                int hex_num = 0x0;
                hex_value.scanf("%x", &hex_num);
                hex_num++;
                hex_value = "%x".printf(hex_num);
                hex_value = "-" + hex_value;
            }
            return (hex_value == "") ? "0" : hex_value;
        }

        public string convert_binary_to_octal (string bin_value, GlobalWordLength? wrd_length = GlobalWordLength.BYT, bool? negative = false) {

            string binary_string = represent_binary_by_word_length (bin_value, wrd_length, false);
            uint64 octalNum = 0, decimalNum = 0, count = 1;
            string converted_binary = binary_string;
            if (negative) {
                converted_binary = "";
                for (int i = 0; i < binary_string.length; i++) {
                    converted_binary += (binary_string.get(i) == '1') ? "0" : "1";
                }
            }
            uint64.from_string (converted_binary, out decimalNum, 2);
            if (negative) {
                decimalNum++;
            }
            while (decimalNum != 0) {
               octalNum += (uint64)Math.fabs(decimalNum % 8) * count;
               decimalNum = (uint64)(decimalNum / 8);
               count *= 10;
            }
            return (negative) ? "-" + octalNum.to_string() : octalNum.to_string();
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
        // Evaluation ///////////////////////////////////////////////////////////////

        private static bool has_precedence_pemdas (char op1, char op2) {
            if (op2 == '(' || op2 == ')') {
                return false;
            }
            // Following the PEMDAS rule: <http://mathworld.wolfram.com/PEMDAS.html>
            if ((op1 == 'u') && (op2 == '|' || op2 == '&' || op2 == '<' || op2 == '>' || op2 == '+' || op2 == '-' || op2 == 'x' || op2 == 'n' || op2 == '/' || op2 == '*' || op2 == '!' || op2 == 'm')) {
                return false;
            }
            if ((op1 == '!' || op1 == 'm') && (op2 == '|' || op2 == '&' || op2 == '<' || op2 == '>' || op2 == '+' || op2 == '-' || op2 == 'x' || op2 == 'n' || op2 == '/' || op2 == '*')) {
                return false;
            }
            else if ((op1 == '/' || op1 == '*') && (op2 == '|' || op2 == '&' || op2 == '<' || op2 == '>' || op2 == '+' || op2 == '-' || op2 == 'x' || op2 == 'n')) {
                return false;
            }
            else if ((op1 == '+' || op1 == '-') && (op2 == '<' || op2 == '>' || op2 == '|' || op2 == '&' || op2 == 'x' || op2 == 'n')) {
                return false;
            }
            else if ((op1 == '<' || op1 == '>') && (op2 == '|' || op2 == '&' || op2 == 'x' || op2 == 'n')) {
                return false;
            }
            else if ((op1 == '&') && (op2 == '|' || op2 == 'x' || op2 == 'n')) {
                return false;
            }
            else {
                return true;
            }
        }

        public bool[] apply_op (Programmer prog_calc, char op, bool[] a, bool[] b, int word_size) {
            bool[] bool_array = new bool[int.max(a.length, b.length)];
            switch (op) {
                case '+':
                return prog_calc.add (a, b, word_size);
                case '-':
                return prog_calc.subtract (b, a, word_size);
                case '*':
                return prog_calc.multiply (a, b);
                case '/':
                // This is using a hacky workaround for division which is not ideal.
                // There is a badly made restoring division function as well which
                // needs to be fixed and used.
                string result = prog_calc.division_signed_integer (b, a, word_size);
                return string_to_bool_array (result, NumberSystem.DECIMAL, Settings.get_default().global_word_length);
                case '&':
                return prog_calc.and (a, b);
                case '<':
                return prog_calc.left_shift (b, a, false, word_size);
                case '>':
                return prog_calc.right_shift (b, a, false, word_size);
            }
            return bool_array;
        }

        public string evaluate_exp (GlobalWordLength? wrd_length = GlobalWordLength.BYT, NumberSystem number_system) {
            CharStack ops = new CharStack (50);
            BoolArrayStack values = new BoolArrayStack(50);
            Programmer prog_calc = new Programmer();
            int word_size = 8;
            switch (wrd_length) {
                case GlobalWordLength.BYT:
                prog_calc.word_size = WordSize.BYTE;
                break;
                case GlobalWordLength.WRD:
                prog_calc.word_size = WordSize.WORD;
                word_size = 16;
                break;
                case GlobalWordLength.DWD:
                prog_calc.word_size = WordSize.DWORD;
                word_size = 32;
                break;
                case GlobalWordLength.QWD:
                prog_calc.word_size = WordSize.QWORD;
                word_size = 64;
                break;
            }
            prog_calc.word_size = WordSize.BYTE;
            for (int i = 0; i < stored_tokens.length; i++) {
                print("2\n");
                if (stored_tokens[i].type == TokenType.OPERAND) {
                    //ops.push((char)(stored_tokens[i].token.get_char(0)));
                    values.push(string_to_bool_array(stored_tokens[i].token, stored_tokens[i].number_system, wrd_length));
                    print("3\n");
                } else if (stored_tokens[i].type == TokenType.PARENTHESIS) {
                    print("/3\n");
                    if (stored_tokens[i].token == "(") {
                        ops.push ('(');
                        print("4\n");
                    }
                    else {
                        while (ops.peek() != '(') {
                            bool[] tmp = apply_op(prog_calc, ops.pop(), values.pop(), values.pop(), word_size);
                            values.push(tmp);
                            print("4\n");
                        }
                        ops.pop();
                        print("5\n");
                    }
                } else if (stored_tokens[i].type == TokenType.OPERATOR) {
                    print(">>6\n");
                    while (!ops.empty() && has_precedence_pemdas(stored_tokens[i].token.get(0), ops.peek())) {
                        print(">>7\n");
                        bool[] tmp = apply_op(prog_calc, ops.pop(), values.pop(), values.pop(), word_size);
                        values.push(tmp);
                        print("7\n");
                    }
                    // Push current token to stack
                    ops.push(stored_tokens[i].token.get(0));
                    print("<<6\n");
                }
            }
            while (!ops.empty()) {
                print(">>8\n");
                bool[] tmp = apply_op(prog_calc, ops.pop(), values.pop(), values.pop(), word_size);
                values.push(tmp);
                print("8\n");
            }

            // Take care of float accuracy of the result
            print("9\n");
            string output = bool_array_to_string (values.pop(), wrd_length, number_system);
            print("9\n");
            return output;
        }
        private bool[] string_to_bool_array (string str, NumberSystem number_system, GlobalWordLength wrd_length) {
            bool[] bool_array = new bool[64];
            string converted_str = "";
            switch (number_system) {
                case NumberSystem.OCTAL:
                converted_str = convert_octal_to_binary (str, wrd_length, true).replace (" ", "");
                break;
                case NumberSystem.DECIMAL:
                converted_str = convert_decimal_to_binary (str, wrd_length, true).replace (" ", "");
                break;
                case NumberSystem.HEXADECIMAL:
                converted_str = convert_hexadecimal_to_binary (str, wrd_length, true).replace (" ", "");
                break;
                default:
                converted_str = represent_binary_by_word_length (str, wrd_length, true).replace (" ", "");
                break;
            }
            int j = 0;
            for (int i = 64-converted_str.length; i < 64; i++) {
                if (converted_str.get_char(j) == '0') {
                    bool_array[i] = false;
                } else {
                    bool_array[i] = true;
                }
                j++;
            }
            return bool_array;
        }

        private string bool_array_to_string(bool[] arr, GlobalWordLength wrd_length, NumberSystem number_system) {
            string str = "";
            print("length%d\n", arr.length);
            for (int i = 0; i <= arr.length; i++) {
                if (arr[i] == true) {
                    str += "1";
                } else {
                    str += "0";
                }
            }
            switch (number_system) {
                case NumberSystem.OCTAL:
                str = convert_binary_to_octal (str, wrd_length, arr[0]);
                break;
                case NumberSystem.DECIMAL:
                str = convert_binary_to_decimal (str, wrd_length, arr[0]);
                break;
                case NumberSystem.HEXADECIMAL:
                str = convert_binary_to_hexadecimal (str, wrd_length, arr[0]);
                break;
                default:
                str = represent_binary_by_word_length (str, wrd_length);
                break;
            }
            return str;
        }
    }
}
