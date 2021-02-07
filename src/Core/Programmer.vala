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
    public enum WordSize {
        BYTE=8,
        WORD=16,
        DWORD=32,
        QWORD=64
    }
    public class Programmer {
        public WordSize word_size;
        public bool[] output;
        public bool carry;
        public bool aux_carry;
        public bool f0;
        public bool overflow_flag;
        public bool parity_flag;
        public bool zero_flag;
        public bool negative_flag;
        
        public Programmer() {
            output =new bool[64];
        }
        public bool xor_each_bit (bool a, bool b) {
            if(a == b) {
                return false;
            }
            return true;
        }
        public bool full_add (bool a, bool b) {
            bool c = carry;
            carry = (a && b) || (b && carry) || (a && carry);
            return xor_each_bit(c, xor_each_bit(a,b));
        }
        public bool[] add (bool[] input_a, bool[] input_b, int? word_size = 8) {
            for(int i=63; i>63-word_size;i--) {
                output[i] = full_add(input_a[i], input_b[i]);  //always set carry to false on first iteration
            }
            return output;
        }
        public bool[] ones_complement(bool[] input, int? word_size = 8) {
            for(int i=64-word_size;i<64;i++) {
                output[i] = !input[i];  //always set carry to false on first iteration
            }
            return output;
        }
        public bool[] twos_complement(bool[] input, int? word_size = 8) {
            bool[] input_copy = ones_complement(input, word_size);
            bool[] binary_one = new bool[64];
            binary_one[63] = true;
            add(input_copy, binary_one, word_size);
            return output;
        }
        public bool[] subtract (bool[] input_a, bool[] input_b, int? word_size = 8) {
            bool[] input_b_copy = twos_complement(input_b, word_size);
            add(input_a, input_b_copy, word_size);
            return output;
        }
        public bool multiply_two_bits (bool a, bool b) {
            if(a == true && b == true) {
                return true;
            }
            return false;
        }
        public bool[] multiply (bool[] input_a, bool[] input_b) {
            bool[] input_a_copy =new bool[64];
            bool[] input_b_copy =new bool[64];
            for(int i=0; i<64-(int)word_size;i++) {
                input_a_copy[i] = false;
                input_b_copy[i] = false;
            }
            for(int i=64-(int)word_size; i<64;i++) {
                input_a_copy[i] = input_a[i];
                input_b_copy[i] = input_b[i];
            }
            bool[] bit_product;
            bool[] sum_of_products = new bool[64];
            int k=0;
            for (int i=63;i>=64-(int)word_size;i--) {
                bit_product = new bool[64];
                //check if bit taken in multiplier is 1 then multiply and add to obtain final result else if 0 then skip
                if(input_b_copy[i]==true) {
                    for (int j=63-k; j>=64-(int)word_size; j--) {
                        //each_bit_product[i,j] = multiply_two_bits(input_a_copy[j+k], input_b_copy[i]);
                        bit_product[j] = multiply_two_bits(input_a_copy[j+k], input_b_copy[i]);
                    
                    }
                    carry = false;
                    sum_of_products = add(sum_of_products,bit_product);
                }
                k++;
            }
            output = sum_of_products;
            return output;
        }

        // Naive integer division using OS (Meant to be replaced by restoring division)
        public string division_signed_integer (bool[] input_a, bool[] input_b, int? word_size = 8) {
            string dividend = "";
            string divisor = "";
            for (int i = 63; i >= 0; i--) {
                dividend = ((input_a[i]) ? "1" : "0") + dividend;
                divisor = ((input_b[i]) ? "1" : "0") + divisor;
            }
            int64 int_dividend;
            int64.from_string (dividend, out int_dividend, 2);
            int64 int_divisor;
            int64.from_string (divisor, out int_divisor, 2);
            print("%s / %s", int_dividend.to_string (), int_divisor.to_string ());
            int64 quotient = int_dividend / int_divisor;
            return quotient.to_string ();
        }
        // Again, naive
        public string mod_signed_integer (bool[] input_a, bool[] input_b, int? word_size = 8) {
            string dividend = "";
            string divisor = "";
            for (int i = 63; i >= 0; i--) {
                dividend = ((input_a[i]) ? "1" : "0") + dividend;
                divisor = ((input_b[i]) ? "1" : "0") + divisor;
            }
            int64 int_dividend;
            int64.from_string (dividend, out int_dividend, 2);
            int64 int_divisor;
            int64.from_string (divisor, out int_divisor, 2);
            print("%s / %s", int_dividend.to_string (), int_divisor.to_string ());
            int64 remainder = int_dividend % int_divisor;
            return remainder.to_string ();
        }

        // Restoring division algorithm (needs to be fixed, may be the whole logic is incorrect here :v)
        public bool[] division_quotient (bool[] input_a, bool[] input_b, int? word_size = 8) {
            print("Inputs for division:");
            for(int j = 0; j< 64 ; j++){ print(input_a[j]?"1":"0"); }
            print("\n");
            for(int j = 0; j< 64 ; j++){ print(input_b[j]?"1":"0"); }
            print("\n");
            bool[] dividend = new bool[64];
            for (int i = 63; i >= 64 - input_a.length; i--) {
                dividend[i] = input_a[i];
            }
            int comparator_result;
            //for left shifting dividend/remainder by 1
            bool[] shift_size = new bool[64];
            shift_size[63] = true;
            output = new bool[64];
            int right_most = find_right_most_one (input_a);
            print("rightmost: %d", right_most);
            for(int i=64-(int)word_size +right_most; i<64; i++) {
                dividend = left_shift(dividend, shift_size, dividend[64 - word_size], word_size);
                print("Left shift : ");
                for(int j = 0; j< 64 ; j++){ print(dividend[j]?"1":"0"); }
                print("\n");
                dividend[63] = input_a[i];
                comparator_result = comparator(dividend, input_b, word_size);
                print("i : %d , Comparator : %d \n" , i, comparator_result);
                if(comparator_result == -1) {
                    output[i] = false;
                }
                else {
                    output[i] = true;
                    print("Subtract for div : ");
                    for(int j = 0; j< 64 ; j++){ print(dividend[j]?"1":"0"); }
                    print("\n");
                    for(int j = 0; j< 64 ; j++){ print(input_b[j]?"1":"0"); }
                    print("\n");
                    dividend = subtract(dividend, input_b, word_size);
                    for(int j = 0; j< 64 ; j++){ print(dividend[j]?"1":"0"); }
                    print("\n");
                }
            }
            return output;
        }

        private int find_right_most_one (bool[] input) {
            int i = 0;
            for (; i < input.length; i++) {
                if (input[i] == true) {
                    break;
                }
            }
            return (input.length - i);
        }

        /***
        compares two boolean arrays and returns an integer based on the following:
        a<b return -1
        a=b return 0
        a>b return 1
        */

        public int comparator(bool[] input_a, bool[] input_b, int? word_size = 8) {
            for(int i=64-(int)word_size; i<64;i++) {
                if(input_a[i] == false && input_b[i] == true) {
                    return -1;
                }
                else if(input_a[i] == input_b[i]) {
                    continue;
                }
                else {
                    return 1;
                }
            }
            return 0;
        }

        public bool[] left_shift(bool[] input_a, bool[] input_b, bool fill_bits, int? word_size = 8) {
            int64 shift_amount;
            string shift_amount_binary_string = "";
            for (int i = 63; i >= 0; i--) {
                shift_amount_binary_string = ((input_b[i]) ? "1" : "0") + shift_amount_binary_string;
            }
            int64.from_string (shift_amount_binary_string, out shift_amount, 2);
            if (shift_amount < 1)
                shift_amount = 1;
            if (shift_amount > word_size)
                shift_amount = word_size;
            for(int i=64-(int)word_size+(int)shift_amount; i<64;i++) {
                output[i-shift_amount] = input_a[i];
            }
            output[63] = fill_bits;
            return output;
        }

        public bool[] right_shift(bool[] input_a, bool[] input_b, bool fill_bits, int? word_size = 8) {
            int64 shift_amount;
            string shift_amount_binary_string = "";
            for (int i = 63; i >= 0; i--) {
                shift_amount_binary_string = ((input_b[i]) ? "1" : "0") + shift_amount_binary_string;
            }
            int64.from_string (shift_amount_binary_string, out shift_amount, 2);
            if (shift_amount < 1)
                shift_amount = 1;
            if (shift_amount > word_size)
                shift_amount = word_size;
            for (int i = 64-word_size; i < 64 - shift_amount; i++) {
                output[i+shift_amount] = input_a[i];
            }
            output[0] = fill_bits;
            return output;
        }

        public bool[] and(bool[] input_a, bool[] input_b, int? word_size = 8) {
            for(int i=64-(int)word_size; i<64;i++) {
                output[i] = input_a[i] && input_b[i];
            }
            return output;
        }
        public bool[] nand(bool[] input_a, bool[] input_b, int? word_size = 8) {
            for(int i=64-(int)word_size; i<64;i++) {
                output[i] = !(input_a[i] && input_b[i]);
            }
            return output;
        }
        public bool[] or(bool[] input_a, bool[] input_b, int? word_size = 8) {
            for(int i=64-(int)word_size; i<64;i++) {
                output[i] = input_a[i] || input_b[i];
            }
            return output;
        }
        public bool[] nor(bool[] input_a, bool[] input_b, int? word_size = 8) {
            for(int i=64-(int)word_size; i<64;i++) {
                output[i] = !(input_a[i] || input_b[i]);
            }
            return output;
        }
        public bool[] xor(bool[] input_a, bool[] input_b, int? word_size = 8) {
            for(int i=64-word_size; i<64;i++) {
                output[i] = xor_each_bit(input_a[i], input_b[i]);
            }
            return output;
        }
        public bool[] xnor(bool[] input_a, bool[] input_b, int? word_size = 8) {
            for(int i=64-(int)word_size; i<64;i++) {
                output[i] = !(xor_each_bit(input_a[i], input_b[i]));
            }
            return output;
        }
        public bool[] not(bool[] input, int? word_size = 8) {
            output = ones_complement(input, word_size);
            return output; //not() does not modify output buffer
        }
   }
}
