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
    public class ProgrammerCalculator {

        private static string binary_equivalent_hexadecimal (string token) {
            if (token == "0000") {
                return "0";
            }
            else if (token == "0001") {
                return "1";
            }
            else if (token == "0010") {
                return "2";
            }
            else if (token == "0011") {
                return "3";
            }
            else if (token == "0100") {
                return "4";
            }
            else if (token == "0101") {
                return "5";
            }
            else if (token == "0110") {
                return "6";
            }
            else if (token == "0111") {
                return "7";
            }
            else if (token == "1000") {
                return "8";
            }
            else if (token == "1001") {
                return "9";
            }
            else if (token == "1010") {
                return "a";
            }
            else if (token == "1011") {
                return "b";
            }
            else if (token == "1100") {
                return "c";
            }
            else if (token == "1101") {
                return "d";
            }
            else if (token == "1110") {
                return "e";
            }
            else if (token == "1111") {
                return "f";
            }
            return "E";
        }

        private static string remove_extra_zeroes (string bin) {
            long i = 0;
            for (; i < bin.length; i++) {
                if (bin.get(i) == '1') {
                    break;
                }
            }
            return bin.slice (i, bin.length);
        }

        public static string binary_to_hexadecimal (string bin) {
            string given_string = remove_extra_zeroes(bin);                               // Getting an owned copy of binary string

            int last_index = given_string.length - 1;
            int i = last_index, cnt;
            string hex_string = "";
            if (bin.length % 4 != 0) {                               // Fills quatrates with zeroes
                for (cnt = (i + 1) % 4; cnt < 4; cnt++) {
                    given_string = "0".concat (given_string);
                }
            }
            i = given_string.length;
            for (; i/4 > 0; i-=4) {
                hex_string = binary_equivalent_hexadecimal(given_string.slice (i - 4, i)).concat (hex_string);
                if (hex_string == "E") {
                    return "E";
                }
                else {
                    continue;
                }
            }
            return hex_string;
        }

        public static string hexadecimal_to_binary (string hex) {
            if(int64.parse(hex) == 0) {
                return "0";
            }
	        string[] tokens=new string[hex.length];
	        for(int i=0;i<hex.length;i++)
	            tokens[i] = hex.get_char(i).to_string();
	        string binary = "";
	        int i = 0;
	        for (; i < hex.length; i++) {
	            if (tokens[i] == "0")
		            binary = binary.concat("0000");
	            else if (tokens[i] == "1")
		            binary = binary.concat("0001");
		        else if (tokens[i] == "2")
		            binary = binary.concat("0010");
		        else if (tokens[i] == "3")
		            binary = binary.concat("0011");
		        else if (tokens[i] == "4")
		            binary = binary.concat("0100");
		        else if (tokens[i] == "5")
		            binary = binary.concat("0101");
		        else if (tokens[i] == "6")
		            binary = binary.concat("0110");
		        else if (tokens[i] == "7")
		            binary = binary.concat("0111");
		        else if (tokens[i] == "8")
		            binary = binary.concat("1000");
		        else if (tokens[i] == "9")
		            binary = binary.concat("1001");
		        else if (tokens[i] == "a")
		            binary = binary.concat("1010");
		        else if (tokens[i] == "b")
		            binary = binary.concat("1011");
		        else if (tokens[i] == "c")
		            binary = binary.concat("1100");
		        else if (tokens[i] == "d")
		            binary = binary.concat("1101");
		        else if (tokens[i] == "e")
		            binary = binary.concat("1110");
		        else if (tokens[i] == "f")
		            binary = binary.concat("1111");    
	        }
	        return remove_extra_zeroes (binary);
        }

        public static string hexadecimal_to_decimal (string hex) {
            int64 ans = 0;
            string[] tokens = new string [hex.length];
            for(int i = 0; i < hex.length; i++)
	            tokens[i] = hex.get_char (i).to_string ();
            int[] conv = new int [hex.length];
            for (int i = 0; i < tokens.length; i++) {
                if (tokens[i] == "a")
                    conv[i] = 10;
                else if (tokens[i] == "b")
                    conv[i] = 11;
                else if (tokens[i] == "c")
                    conv[i] = 12;
                else if (tokens[i] == "d")
                    conv[i] = 13;
                else if (tokens[i] == "e")
                    conv[i] = 14;
                else if (tokens[i] == "f")
                    conv[i] = 15;
                else
                    conv[i] = int.parse(tokens[i]);
            }

            for (int i = 0; i < tokens.length; i++) {
                ans += (int)(conv[i] * Math.pow (16, tokens.length - 1 - i));
            }
            return ans.to_string();
        }

        public static string decimal_to_hexadecimal (string dec) {
	    string hex_num = "";
	    int64 n = int64.parse (dec);
        if (n == 0) {
            return "0";
        }
	    while (n != 0) {
	        int64 temp  = n % 16;
	        if ( temp < 10 ) {
		    hex_num = hex_num.concat(temp.to_string());
	        }
	        else {
		    switch (temp) {
		        case 10 : hex_num = hex_num.concat ("a");
			          break;
		        case 11 : hex_num = hex_num.concat ("b");
			          break;
		        case 12 : hex_num = hex_num.concat ("c");
			          break;
		        case 13 : hex_num = hex_num.concat ("d");
			          break;
		        case 14 : hex_num = hex_num.concat ("e");
			          break;
		        case 15 : hex_num = hex_num.concat ("f");
			          break;
		    }
	        }
	        n = n / 16;
	    }
	    return hex_num.reverse ();
        }

        public static string decimal_to_octal (string dec) {
	        int64 quotient, decimalnum;
	        decimalnum = int64.parse (dec);
	        string octal_number = "";
	        quotient = decimalnum;
            if(quotient == 0) {
                return "0";
            }
	        while (quotient != 0) {
	            octal_number = octal_number.concat ((quotient % 8).to_string());
	            quotient = quotient / 8;
	        }
	        return octal_number.reverse();
        }

        public static string binary_to_decimal (string binary) {
                int64 ans = 0;
                string[] tokens = new string [binary.length];
                for(int i = 0; i < binary.length; i++)
                    tokens[i] = binary.get_char (i).to_string ();
                int[] conv = new int [binary.length];
                for (int i = 0; i < tokens.length; i++) {
                    if (int.parse(tokens[i]) < 2)
                        conv[i] = int.parse(tokens[i]);
                }
                for (int i = 0; i < tokens.length; i++) {
                    ans += (int)(conv[i] * Math.pow (2, tokens.length - 1 - i));
                }
                return ans.to_string();
        }

        private static string binary_equivalent_octal (string token) {
                if (token == "000") {
                    return "0";
                }
                else if (token == "001") {
                    return "1";
                }
                else if (token == "010") {
                    return "2";
                }
                else if (token == "011") {
                    return "3";
                }
                else if (token == "100") {
                    return "4";
                }
                else if (token == "101") {
                    return "5";
                }
                else if (token == "110") {
                    return "6";
                }
                else if (token == "111") {
                    return "7";
                }
                return "e";
        }
        public static string binary_to_octal (string bin) {
                string given_string = remove_extra_zeroes(bin);                               // Getting an owned copy of binary string
                int last_index = given_string.length - 1;
                int i = last_index, cnt;
                string octal_string = "";
                if (bin.length % 3 != 0) {                               // Fills front extra with zeroes
                    for (cnt = (i + 1) % 3; cnt < 3; cnt++) {
                        given_string = "0".concat (given_string);
                    }
                }
                i = given_string.length;
                for (; i/3 > 0; i-=3) {
                    octal_string = binary_equivalent_octal(given_string.slice (i - 3, i)).concat (octal_string);
                    if (octal_string == "e") {
                        return "E";
                    }
                    else {
                        continue;
                    }
                }
                return octal_string;
        }

        public static string decimal_to_binary (string decimal) 
        {
            int64 quotient, decimalnum;
            decimalnum = int64.parse (decimal);
            if(decimalnum == 0) {
                return "0";
            }
            string binary_number_rev = "";
            quotient = decimalnum;
            while (quotient != 0) {
                binary_number_rev = binary_number_rev.concat ((quotient % 2).to_string());
                quotient = quotient / 2;
            }
            return binary_number_rev.reverse();
        }

        public static string octal_to_binary (string octal) {
            if(int64.parse(octal) == 0) {
                return "0";
            }
            string[] tokens=new string[octal.length];
            for(int i=0;i<octal.length;i++)
                tokens[i] = octal.get_char(i).to_string();
            string binary = "";
            int i = 0;
            for (; i < octal.length; i++) {
                if (tokens[i] == "0")
                    binary = binary.concat("000");
                else if (tokens[i] == "1")
                    binary = binary.concat("001");
                else if (tokens[i] == "2")
                    binary = binary.concat("010");
                else if (tokens[i] == "3")
                    binary = binary.concat("011");
                else if (tokens[i] == "4")
                    binary = binary.concat("100");
                else if (tokens[i] == "5")
                    binary = binary.concat("101");
                else if (tokens[i] == "6")
                    binary = binary.concat("110");
                else if (tokens[i] == "7")
                    binary = binary.concat("111");
            }
            return remove_extra_zeroes (binary);
        }

        public static string octal_to_decimal (string octal) {
            int ans = 0;
            string[] tokens = new string [octal.length];
            for(int i = 0; i < octal.length; i++)
                tokens[i] = octal.get_char (i).to_string ();
            int[] conv = new int [octal.length];
            for (int i = 0; i < tokens.length; i++) {
                if (int.parse(tokens[i]) < 8)
                    conv[i] = int.parse(tokens[i]);
            }
            for (int i = 0; i < tokens.length; i++) {
                ans += (int)(conv[i] * Math.pow (8, tokens.length - 1 - i));
            }
            return ans.to_string();
        }

        public static string octal_to_hexadecimal (string octal) {
            if(int64.parse(octal) == 0) {
                return "0";
            }
            return  binary_to_hexadecimal (remove_extra_zeroes (octal_to_binary (octal)));
        }

        public static string hexadecimal_to_octal (string hex) {
            if(int64.parse(hex) == 0) {
                return "0";
            }
            return binary_to_octal (remove_extra_zeroes (hexadecimal_to_binary (hex)));
        }

        public static string decimal_and_operation (string decimal1, string decimal2) {
            int64 ans;
            ans = int64.parse(decimal1) & int64.parse(decimal2);
            return ans.to_string();
        }

        public static string decimal_or_operation (string decimal1, string decimal2) {
            int64 ans;
            ans = int64.parse(decimal1) | int64.parse(decimal2);
            return ans.to_string();
        }

        public static string decimal_xor_operation (string decimal1, string decimal2) {
            int64 ans;
            ans = int64.parse(decimal1) ^ int64.parse(decimal2);
            return ans.to_string();
        }

        public static string decimal_not_operation (string decimal) {
            int64 ans;
            ans = ~ int64.parse(decimal);
            return ans.to_string();
        }

        public static string decimal_mod_operation (string decimal1, string decimal2) {
            int64 ans;
            ans = int64.parse(decimal1) % int64.parse(decimal2);
            return ans.to_string();
        }

        public static string decimal_addition_operation (string decimal1, string decimal2) {
            int64 ans;
            ans = int64.parse(decimal1) + int64.parse(decimal2);
            return ans.to_string();
        }

        public static string decimal_subtraction_operation (string decimal1, string decimal2) {
            int64 ans;
            ans = int64.parse(decimal1) - int64.parse(decimal2);
            return ans.to_string();
        }

        public static string decimal_multiplication_operation (string decimal1, string decimal2) {
            int64 ans;
            ans = int64.parse(decimal1) * int64.parse(decimal2);
            return ans.to_string();
        }

        public static string decimal_division_operation (string decimal1, string decimal2) {
            int64 ans;
            ans = int64.parse(decimal1) / int64.parse(decimal2);
            return ans.to_string();
        }

        public static string decimal_left_shift_operation (string decimal1, string decimal2, string value_mode) {
            string ans;
            string binary1 = decimal_to_binary (decimal1);
            if(value_mode == "QWORD") {
                for(int i= 0 ; i < 64 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    binary1 = binary1.slice(1,binary1.length + 1) + "0";
                }
            }
            else if(value_mode == "DWORD") {
                for(int i= 0 ; i < 32 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    binary1 = binary1.slice(1,binary1.length + 1) + "0";
                }
            }
            else if(value_mode == "WORD") {
                for(int i= 0 ; i < 16 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    binary1 = binary1.slice(1,binary1.length + 1) + "0";
                }
            }
            else if(value_mode == "BYTE") {
                for(int i= 0 ; i < 8 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    binary1 = binary1.slice(1,binary1.length + 1) + "0";
                }
            }
            ans = binary_to_decimal (binary1);
            return ans;
        }

        public static string decimal_right_shift_operation (string decimal1, string decimal2, string value_mode) {
            string ans;
            string binary1 = decimal_to_binary (decimal1);
            if(value_mode == "QWORD") {
                for(int i= 0 ; i < 64 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    binary1 = "0" + binary1.slice(0,binary1.length);
                }
            }
            else if(value_mode == "DWORD") {
                for(int i= 0 ; i < 32 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    binary1 = "0" + binary1.slice(0,binary1.length);
                }
            }
            else if(value_mode == "WORD") {
                for(int i= 0 ; i < 16 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    binary1 = "0" + binary1.slice(0,binary1.length);
                }
            }
            else if(value_mode == "BYTE") {
                for(int i= 0 ; i < 8 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    binary1 = "0" + binary1.slice(0,binary1.length);
                }
            }
            ans = binary_to_decimal (binary1);
            return ans;
        }

        public static string decimal_left_rotate_operation (string decimal1, string decimal2, string value_mode) {
            string ans;
            string rotating_bit;
            string binary1 = decimal_to_binary (decimal1);
            if(value_mode == "QWORD") {
                for(int i= 0 ; i < 64 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    rotating_bit = binary1.slice(0,1);
                    binary1 = binary1.slice(1,binary1.length + 1) + rotating_bit;
                }
            }
            else if(value_mode == "DWORD") {
                for(int i= 0 ; i < 32 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    rotating_bit = binary1.slice(0,1);
                    binary1 = binary1.slice(1,binary1.length + 1) + rotating_bit;
                }
            }
            else if(value_mode == "WORD") {
                for(int i= 0 ; i < 16 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    rotating_bit = binary1.slice(0,1);
                    binary1 = binary1.slice(1,binary1.length + 1) + rotating_bit;
                }
            }
            else if(value_mode == "BYTE") {
                for(int i= 0 ; i < 8 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    rotating_bit = binary1.slice(0,1);
                    binary1 = binary1.slice(1,binary1.length + 1) + rotating_bit;
                }
            }
            ans = binary_to_decimal (binary1);
            return ans;
        }

        public static string decimal_right_rotate_operation (string decimal1, string decimal2, string value_mode) {
            string ans;
            string rotating_bit;
            string binary1 = decimal_to_binary (decimal1);
            if(value_mode == "QWORD") {
                for(int i= 0 ; i < 64 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    rotating_bit = binary1.slice(binary1.length,binary1.length + 1);
                    binary1 = rotating_bit + binary1.slice(0,binary1.length);
                }
            }
            else if(value_mode == "DWORD") {
                for(int i= 0 ; i < 32 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    rotating_bit = binary1.slice(binary1.length,binary1.length + 1);
                    binary1 = rotating_bit + binary1.slice(0,binary1.length);
                }
            }
            else if(value_mode == "WORD") {
                for(int i= 0 ; i < 16 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    rotating_bit = binary1.slice(binary1.length,binary1.length + 1);
                    binary1 = rotating_bit + binary1.slice(0,binary1.length);
                }
            }
            else if(value_mode == "BYTE") {
                for(int i= 0 ; i < 8 - binary1.length; i++) {
                        binary1 = "0" + binary1;
                    }
                for(int64 i = 0; i < int64.parse(decimal2); i++) {
                    rotating_bit = binary1.slice(binary1.length,binary1.length + 1);
                    binary1 = rotating_bit + binary1.slice(0,binary1.length);
                }
            }
            ans = binary_to_decimal (binary1);
            return ans;
        }

        //function calls have unmatched parameters from here on
        public static string binary_ones_complement_operation (string binary, string value_mode) {
            string complement = "";
            for(int i = 0; i < binary.length; i++) {
                if(binary.slice(i,i+1) == "0") {
                    complement = complement + "1";
                }
                else if(binary.slice(i,i+1) == "1") {
                    complement = complement + "0";
                }
            }
           return decimal_to_binary (decimal_addition_operation (binary_to_decimal (complement, value_mode), "1") ,value_mode);
        }
        //no wrong calls after this point
   }
}
