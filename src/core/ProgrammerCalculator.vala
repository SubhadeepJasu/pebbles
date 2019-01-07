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
    public class Programmer {
        private static string bin_to_hexa (string token) {
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
                return "A";
            }
            else if (token == "1011") {
                return "B";
            }
            else if (token == "1100") {
                return "C";
            }
            else if (token == "1101") {
                return "D";
            }
            else if (token == "1110") {
                return "E";
            }
            else if (token == "1111") {
                return "F";
            }
            return "e";

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

        public static string convert_to_hexa (string bin) {
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
                hex_string = bin_to_hexa(given_string.slice (i - 4, i)).concat (hex_string);
                if (hex_string == "e") {
                    return "E";
                }
                else {
                    continue;
                }
            }
            return hex_string;
        }

        public static string hex_to_binary (string hex) {
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
		        else if (tokens[i] == "A")
		            binary = binary.concat("1010");
		        else if (tokens[i] == "B")
		            binary = binary.concat("1011");
		        else if (tokens[i] == "C")
		            binary = binary.concat("1100");
		        else if (tokens[i] == "D")
		            binary = binary.concat("1101");
		        else if (tokens[i] == "E")
		            binary = binary.concat("1110");
		        else if (tokens[i] == "F")
		            binary = binary.concat("1111");    
	        }
	        return binary;
        }
        public static string hex_to_dec (string hex) {
            int ans = 0;
            string[] tokens = new string [hex.length];
            for(int i = 0; i < hex.length; i++)
	            tokens[i] = hex.get_char (i).to_string ();
            int[] conv = new int [hex.length];
            for (int i = 0; i < tokens.length; i++) {
                if (tokens[i] == "A")
                    conv[i] = 10;
                else if (tokens[i] == "B")
                    conv[i] = 11;
                else if (tokens[i] == "C")
                    conv[i] = 12;
                else if (tokens[i] == "D")
                    conv[i] = 13;
                else if (tokens[i] == "E")
                    conv[i] = 14;
                else if (tokens[i] == "F")
                    conv[i] = 15;
                else
                    conv[i] = int.parse(tokens[i]);
            }
            
            for (int i = 0; i < tokens.length; i++) {
                ans += (int)(conv[i] * Math.pow (16, tokens.length - 1 - i));
            }
            return ans.to_string();
        }
        public static string dec_to_hex (string dec) {
	    string hex_num = "";
	    int n;
	    n = int.parse (dec);
	    while (n != 0) {
	        int temp  = n % 16;
	        if ( temp < 10 ) {
		    hex_num = hex_num.concat(temp.to_string());
	        }
	        else {
		    switch (temp) {
		        case 10 : hex_num = hex_num.concat ("A");
			          break;
		        case 11 : hex_num = hex_num.concat ("B");
			          break;
		        case 12 : hex_num = hex_num.concat ("C");
			          break;
		        case 13 : hex_num = hex_num.concat ("D");
			          break;
		        case 14 : hex_num = hex_num.concat ("E");
			          break;
		        case 15 : hex_num = hex_num.concat ("F");
			          break;
		    }
	        }
	        n = n / 16;
	    }
	    return hex_num.reverse ();
        }
        public static string dec_to_oct (string dec) {
	        int quotient, decimalnum;
	        decimalnum = int.parse (dec);
	        //int[] octal_number = new int [100];
	        
	        string octal_number = "";
	        quotient = decimalnum;

	        while (quotient != 0) {
	            octal_number = octal_number.concat ((quotient % 8).to_string());
	            quotient = quotient / 8;
	        }
	        return octal_number.reverse();
        }
    }
}
