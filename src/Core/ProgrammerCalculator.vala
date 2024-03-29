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

    public errordomain CalcError {
        DIVIDE_BY_ZERO
    }


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
            return stored_tokens[stored_tokens.length - 1];
        }

        public Token[] get_token_array () {
            return stored_tokens;
        }

        public string set_last_token (bool[] arr, GlobalWordLength wrd_length, NumberSystem number_system) {
            if (stored_tokens[stored_tokens.length - 1].type != TokenType.OPERAND) {
                stored_tokens.resize (stored_tokens.length + 1);
            }
            stored_tokens[stored_tokens.length - 1].token = bool_array_to_string (arr, wrd_length, number_system);
            string[] token_list = new string[stored_tokens.length];
            for (int i = 0; i < stored_tokens.length; i++) {
                token_list[i] = stored_tokens[i].token;
            }
            return Utils.get_natural_expression(string.joinv (" ", token_list));
        }

        public void populate_token_array (string exp) {
            stored_tokens = Utils.get_token_array (exp);
            for (int i = 0; i < stored_tokens.length; i++) {
            }
        }
        public string set_number_system (string exp, GlobalWordLength? wrd_length = GlobalWordLength.BYT, bool? force_decimal = false) {
            var token_structure = Utils.get_token_array (exp);
            if (compare_token_set (token_structure, stored_tokens)) {
                for (int i = 0; i < token_structure.length; i++) {
                    if (token_structure[i].type == TokenType.OPERAND) {
                        if (token_structure[i].number_system != stored_tokens[i].number_system) {
                            stored_tokens[i].token = convert_number_system (stored_tokens[i].token, stored_tokens[i].number_system, force_decimal ? NumberSystem.DECIMAL : token_structure[i].number_system, wrd_length);
                        }
                    }
                }
            }
            string[] token_list = new string[stored_tokens.length];
            for (int i = 0; i < stored_tokens.length; i++) {
                stored_tokens[i].token = Utils.remove_leading_zeroes(stored_tokens[i].token);
                token_list[i] = stored_tokens[i].token;
            }
            return Utils.get_natural_expression(string.joinv (" ", token_list));
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

        string decimal_to_binary_int_unsigned (uint64 k) {
            string bin = "";
            var n = k;
            for (int i = 0; n > 0; i++) {
                bin = ((uint8)(n%2)).to_string() + bin;
                n = (uint64)(n/2);
            }

            return bin;
        }
        public string convert_decimal_to_binary (string number, GlobalWordLength? wrd_length = GlobalWordLength.WRD, bool? format = false) {
            uint64 decimal = uint64.parse (number);
            print ("%s......\n", decimal.to_string());
            if (number.contains("-")) {
                switch (wrd_length) {
                    case GlobalWordLength.BYT:
                    decimal += 128;
                    break;
                    case GlobalWordLength.WRD:
                    decimal += 32768;
                    break;
                    case GlobalWordLength.DWD:
                    decimal += 2147483648;
                    break;
                    case GlobalWordLength.QWD:
                    decimal += 9223372036854775808;
                    break;
                }
            }
            print ("%s......\n", decimal.to_string());
            string binary = decimal_to_binary_int_unsigned(decimal).to_string();
            print ("%s b\n", binary);
            binary = represent_binary_by_word_length (binary, wrd_length, format);
            if (number.contains("-")) {
                binary = binary.substring(1, -1);
                binary = "1" + binary;
            }
            print ("%s n\n", binary);
            return binary;
        }
        public string convert_binary_to_decimal (string number, GlobalWordLength? wrd_length = GlobalWordLength.WRD) {
            string formatted_binary = represent_binary_by_word_length (number, wrd_length);
            int64 decimal = ProgrammerCalculator.convert_signed_binary_to_decimal(formatted_binary);
            return decimal.to_string ();
        }
        public static int64 convert_signed_binary_to_decimal (string binary) {
            int64 dec = 0;
            for (uint i = binary.length - 1; i > 0; i--){
                dec += (binary.get(i) == '1') ? (int64) pow64 (2, (binary.length - 1) - i) : 0;
            }
            if (binary.get(0) == '1') {
                return dec - (int64)pow64 (2, binary.length - 1);
            }
            return dec;
        }
        public string represent_binary_by_word_length (string binary_value, GlobalWordLength wrd_length = GlobalWordLength.BYT, bool? format = false) {
            string new_binary = "";
            switch (wrd_length) {
                case GlobalWordLength.BYT:
                if (binary_value.length > 8) {
                    new_binary = binary_value.slice (binary_value.length - 9, -1);
                } else {
                    string pre_zeros = "";
                    for (int i = 0; i < 8 - binary_value.length; i++) {
                        pre_zeros += "0";
                    }
                    new_binary = pre_zeros + binary_value;
                }
                break;
                case GlobalWordLength.WRD:
                if (binary_value.length > 16) {
                    new_binary = binary_value.slice (binary_value.length - 17, -1);
                } else {
                    string pre_zeros = "";
                    for (int i = 0; i < 16 - binary_value.length; i++) {
                        pre_zeros += "0";
                    }
                    new_binary = pre_zeros + binary_value;
                }
                break;
                case GlobalWordLength.DWD:
                if (binary_value.length > 32) {
                    new_binary = binary_value.slice (binary_value.length - 33, -1);
                } else {
                    string pre_zeros = "";
                    for (int i = 0; i < 32 - binary_value.length; i++) {
                        pre_zeros += "0";
                    }
                    new_binary = pre_zeros + binary_value;
                }
                break;
                case GlobalWordLength.QWD:
                if (binary_value.length > 64) {
                    new_binary = binary_value.slice (binary_value.length - 65, -1);
                } else {
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
            return (hex_value.chug () == "") ? "0" : hex_value;
        }

        public string convert_hexadecimal_to_decimal (string number, GlobalWordLength? wrd_length = GlobalWordLength.WRD) {
            string binary_value = convert_hexadecimal_to_binary (number, wrd_length, false);
            string decimal = convert_binary_to_decimal (binary_value, wrd_length);
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
            int i = 0;
            string hex_value = "";
            string converted_binary = bin;
            bool negative = bin[0] == '1';
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
            return (hex_value.chug () == "") ? "0" : hex_value;
        }

        public string convert_binary_to_octal (string bin_value, GlobalWordLength? wrd_length = GlobalWordLength.BYT) {

            string binary_string = represent_binary_by_word_length (bin_value, wrd_length, false);
            uint64 octalNum = 0, decimalNum = 0, count = 1;
            string converted_binary = binary_string;
            bool negative = binary_string[0] == '1';
            if (negative) {
                converted_binary = "";
                for (int i = 0; i < binary_string.length; i++) {
                    converted_binary += (binary_string.get(i) == '1') ? "0" : "1";
                }
            }
            try {
                uint64.from_string (converted_binary, out decimalNum, 2);
            } catch (Error e) {
                decimalNum = ProgrammerCalculator.convert_signed_binary_to_decimal(binary_string);
            }
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
            int64 decimalNum = 0, count = 0;

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
        private static uint64 pow64 (uint64 a, uint64 b) {
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
            if ((op1 == 'u') && (op2 == '|' || op2 == 'o' || op2 == '_' || op2 == '&' || op2 == '<' || op2 == '>' || op2 == '+' || op2 == '-' || op2 == 'x' || op2 == 'n' || op2 == '/' || op2 == '*' || op2 == '!' || op2 == 'm')) {
                return false;
            }
            if ((op1 == '!' || op1 == 'm') && (op2 == '|' || op2 == '&' || op2 == '<' || op2 == '>' || op2 == '+' || op2 == '-' || op2 == 'x' || op2 == 'n' || op2 == '/' || op2 == '*')) {
                return false;
            }
            else if ((op1 == '/' || op1 == '*') && (op2 == '|' || op2 == 'o' || op2 == '&' || op2 == '_' || op2 == '<' || op2 == '>' || op2 == '+' || op2 == '-' || op2 == 'x' || op2 == 'n')) {
                return false;
            }
            else if ((op1 == '+' || op1 == '-') && (op2 == '<' || op2 == '>' || op2 == '|' || op2 == 'o' || op2 == '&' || op2 == '_' || op2 == 'x' || op2 == 'n')) {
                return false;
            }
            else if ((op1 == '<' || op1 == '>') && (op2 == '|' || op2 == 'o' || op2 == '&' || op2 == '_' || op2 == 'x' || op2 == 'n')) {
                return false;
            }
            else if ((op1 == '&' || op1 == '_') && (op2 == '|' || op2 == 'o' || op2 == 'x' || op2 == 'n')) {
                return false;
            }
            else if ((op1 == 'x' || op1 == 'o' || op1 == 'n') && (op2 == '|')) {
                return false;
            }
            else {
                return true;
            }
        }

        public bool[] apply_op (char op, bool[] a_input, bool[] b_input, Pebbles.GlobalWordLength word_size) throws CalcError {
            bool[] ret_val = new bool[64];
            if (word_size == GlobalWordLength.BYT) {
                int8 a = 0;
                int8 b = 0;
                int8 result = 0;

                string str_a = "";
                string str_b = "";
                for (int i = 56; i < 64; i++) {
                    str_a += a_input[i] ? "1" : "0";
                    str_b += b_input[i] ? "1" : "0";
                }
                a = (int8)ProgrammerCalculator.convert_signed_binary_to_decimal(str_a);
                b = (int8)ProgrammerCalculator.convert_signed_binary_to_decimal(str_b);
                print ("%d %c %d = ", b, op, a);
                switch (op) {
                    case '+':
                    result = a + b;
                    break;
                    case '-':
                    result = b - a;
                    break;
                    case '*':
                    result = a * b;
                    break;
                    case '/':
                    if (a == 0) {
                        throw new CalcError.DIVIDE_BY_ZERO ("Dividing by zero not allowed");
                    } else {
                        result = b / a;
                    }
                    break;
                    case '&':
                    result = a & b;
                    break;
                    case '|':
                    result = a | b;
                    break;
                    case '!':
                    result = ~a;
                    break;
                    case '_':
                    result = ~(a & b);
                    break;
                    case 'o':
                    result = ~(a | b);
                    break;
                    case 'x':
                    result = (a | b) & (~a | ~b);
                    break;
                    case 'n':
                    result = (a & b) | (~a & ~b);
                    break;
                    case 'm':
                    if (a == 0) {
                        throw new CalcError.DIVIDE_BY_ZERO ("Dividing by zero not allowed");
                    } else {
                        result = b % a;
                    }
                    break;
                    case '<':
                    result = b << a;
                    break;
                    case '>':
                    result = b >> a;
                    break;
                }
                print ("%d\n", result);
                return string_to_bool_array(result.to_string(), Pebbles.NumberSystem.DECIMAL, Pebbles.GlobalWordLength.BYT);
            } else if (word_size == GlobalWordLength.WRD) {
                int16 a = 0;
                int16 b = 0;
                int16 result = 0;

                string str_a = "";
                string str_b = "";
                for (int i = 48; i < 64; i++) {
                    str_a += a_input[i] ? "1" : "0";
                    str_b += b_input[i] ? "1" : "0";
                }
                a = (int16)ProgrammerCalculator.convert_signed_binary_to_decimal(str_a);
                b = (int16)ProgrammerCalculator.convert_signed_binary_to_decimal(str_b);
                print ("%d %c %d = ", b, op, a);
                switch (op) {
                    case '+':
                    result = a + b;
                    break;
                    case '-':
                    result = b - a;
                    break;
                    case '*':
                    result = a * b;
                    break;
                    case '/':
                    if (a == 0) {
                        throw new CalcError.DIVIDE_BY_ZERO ("Dividing by zero not allowed");
                    } else {
                        result = b / a;
                    }
                    break;
                    case '&':
                    result = a & b;
                    break;
                    case '|':
                    result = a | b;
                    break;
                    case '!':
                    result = ~a;
                    break;
                    case '_':
                    result = ~(a & b);
                    break;
                    case 'o':
                    result = ~(a | b);
                    break;
                    case 'x':
                    result = (a | b) & (~a | ~b);
                    break;
                    case 'n':
                    result = (a & b) | (~a & ~b);
                    break;
                    case 'm':
                    if (a == 0) {
                        throw new CalcError.DIVIDE_BY_ZERO ("Dividing by zero not allowed");
                    } else {
                        result = b % a;
                    }
                    break;
                    case '<':
                    result = b << a;
                    break;
                    case '>':
                    result = b >> a;
                    break;
                }
                print ("%d\n", result);
                return string_to_bool_array(result.to_string(), Pebbles.NumberSystem.DECIMAL, Pebbles.GlobalWordLength.WRD);
            }if (word_size == GlobalWordLength.DWD) {
                int32 a = 0;
                int32 b = 0;
                int32 result = 0;

                string str_a = "";
                string str_b = "";
                for (int i = 32; i < 64; i++) {
                    str_a += a_input[i] ? "1" : "0";
                    str_b += b_input[i] ? "1" : "0";
                }
                a = (int8)ProgrammerCalculator.convert_signed_binary_to_decimal(str_a);
                b = (int8)ProgrammerCalculator.convert_signed_binary_to_decimal(str_b);
                print ("%d %c %d = ", b, op, a);
                switch (op) {
                    case '+':
                    result = a + b;
                    break;
                    case '-':
                    result = b - a;
                    break;
                    case '*':
                    result = a * b;
                    break;
                    case '/':
                    if (a == 0) {
                        throw new CalcError.DIVIDE_BY_ZERO ("Dividing by zero not allowed");
                    } else {
                        result = b / a;
                    }
                    break;
                    case '&':
                    result = a & b;
                    break;
                    case '|':
                    result = a | b;
                    break;
                    case '!':
                    result = ~a;
                    break;
                    case '_':
                    result = ~(a & b);
                    break;
                    case 'o':
                    result = ~(a | b);
                    break;
                    case 'x':
                    result = (a | b) & (~a | ~b);
                    break;
                    case 'n':
                    result = (a & b) | (~a & ~b);
                    break;
                    case 'm':
                    if (a == 0) {
                        throw new CalcError.DIVIDE_BY_ZERO ("Dividing by zero not allowed");
                    } else {
                        result = b % a;
                    }
                    break;
                    case '<':
                    result = b << a;
                    break;
                    case '>':
                    result = b >> a;
                    break;
                }
                print ("%d\n", result);
                return string_to_bool_array(result.to_string(), Pebbles.NumberSystem.DECIMAL, Pebbles.GlobalWordLength.DWD);
            }if (word_size == GlobalWordLength.QWD) {
                int64 a = 0;
                int64 b = 0;
                int64 result = 0;

                string str_a = "";
                string str_b = "";
                for (int i = 0; i < 64; i++) {
                    str_a += a_input[i] ? "1" : "0";
                    str_b += b_input[i] ? "1" : "0";
                }
                a = ProgrammerCalculator.convert_signed_binary_to_decimal(str_a);
                b = ProgrammerCalculator.convert_signed_binary_to_decimal(str_b);
                print ("%l %c %l = ", b, op, a);
                switch (op) {
                    case '+':
                    result = a + b;
                    break;
                    case '-':
                    result = b - a;
                    break;
                    case '*':
                    result = a * b;
                    break;
                    case '/':
                    if (a == 0) {
                        throw new CalcError.DIVIDE_BY_ZERO ("Dividing by zero not allowed");
                    } else {
                        result = b / a;
                    }
                    break;
                    case '&':
                    result = a & b;
                    break;
                    case '|':
                    result = a | b;
                    break;
                    case '!':
                    result = ~a;
                    break;
                    case '_':
                    result = ~(a & b);
                    break;
                    case 'o':
                    result = ~(a | b);
                    break;
                    case 'x':
                    result = (a | b) & (~a | ~b);
                    break;
                    case 'n':
                    result = (a & b) | (~a & ~b);
                    break;
                    case 'm':
                    if (a == 0) {
                        throw new CalcError.DIVIDE_BY_ZERO ("Dividing by zero not allowed");
                    } else {
                        result = b % a;
                    }
                    break;
                    case '<':
                    result = b << a;
                    break;
                    case '>':
                    result = b >> a;
                    break;
                }
                print ("%l\n", result);
                return string_to_bool_array(result.to_string(), Pebbles.NumberSystem.DECIMAL, Pebbles.GlobalWordLength.QWD);
            }

            return ret_val;
        }

        public string evaluate_exp (GlobalWordLength? wrd_length = GlobalWordLength.BYT, NumberSystem? number_system = NumberSystem.BINARY, out bool[]? output_array = null) throws CalcError {
            CharStack ops = new CharStack (50);
            BoolArrayStack values = new BoolArrayStack(50);
            for (int i = 0; i < stored_tokens.length; i++) {
                if (stored_tokens[i].type == TokenType.OPERAND) {
                    //ops.push((char)(stored_tokens[i].token.get_char(0)));
                    values.push(string_to_bool_array(stored_tokens[i].token, stored_tokens[i].number_system, wrd_length));
                } else if (stored_tokens[i].type == TokenType.PARENTHESIS) {
                    if (stored_tokens[i].token == "(") {
                        ops.push ('(');
                    }
                    else {
                        while (ops.peek() != '(') {
                            try {
                                bool[] tmp = apply_op(ops.pop(), values.pop(), values.pop(), wrd_length);
                                values.push(tmp);
                            } catch (CalcError e) {
                                throw e;
                            }
                        }
                        ops.pop();
                    }
                } else if (stored_tokens[i].type == TokenType.OPERATOR) {
                    while (!ops.empty() && has_precedence_pemdas(stored_tokens[i].token.get(0), ops.peek())) {
                        try {
                            bool[] tmp = apply_op(ops.pop(), values.pop(), values.pop(), wrd_length);
                            values.push(tmp);
                        } catch (CalcError e) {
                            throw e;
                        }
                    }
                    // Push current token to stack
                    ops.push(stored_tokens[i].token.get(0));
                }
            }
            while (!ops.empty()) {
                try {
                    bool[] tmp = apply_op(ops.pop(), values.pop(), values.pop(), wrd_length);
                    values.push(tmp);
                } catch (CalcError e) {
                    throw e;
                }
            }
            bool[] answer = values.pop();

            // Send the original array back for storage.
            output_array = answer;
            string output = bool_array_to_string (answer, wrd_length, number_system);

            return output;
        }
        public bool[] string_to_bool_array (string str, NumberSystem number_system, GlobalWordLength wrd_length) {
            bool[] bool_array = new bool[64];
            string converted_str = "";
            print ("%s: str\n", str);
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

        public string bool_array_to_string(bool[] arr, GlobalWordLength wrd_length, NumberSystem number_system) {
            string str = "";
            for (int i = 0; i <= arr.length; i++) {
                if (arr[i] == true) {
                    str += "1";
                } else {
                    str += "0";
                }
            }
            switch (number_system) {
                case NumberSystem.OCTAL:
                str = convert_binary_to_octal (str, wrd_length);
                break;
                case NumberSystem.DECIMAL:
                str = convert_binary_to_decimal (str, wrd_length);
                break;
                case NumberSystem.HEXADECIMAL:
                str = convert_binary_to_hexadecimal (str, wrd_length);
                break;
                default:
                str = represent_binary_by_word_length (str, wrd_length);
                break;
            }
            return str;
        }
    }
}
