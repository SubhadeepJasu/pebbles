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
        public bool[] add (bool[] input_a, bool[] input_b) {
            for(int i=63; i>63-word_size;i--) {
                output[i] = full_add(input_a[i], input_b[i]);  //always set carry to false on first iteration
            }
            return output;
        }
        public bool[] ones_complement(bool[] input) {
            for(int i=64-word_size;i<64;i++) {
                output[i] = !input[i];  //always set carry to false on first iteration
            }
            return output;
        }
        public bool[] twos_complement(bool[] input) {
            bool[] input_copy = ones_complement(input);
            bool[] binary_one = new bool[64];
            for(int i = 0; i<63; i++) {
                binary_one[i] = false;
            }
            binary_one[63] = true;
            add(input_copy, binary_one);
            return output;
        }
        public bool[] subtract (bool[] input_a, bool[] input_b) {
            bool[] input_b_copy = twos_complement(input_b);
            add(input_a, input_b_copy);
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
            for(int i=0; i<64-word_size;i++) {
                input_a_copy[i] = false;
                input_b_copy[i] = false;
            }
            for(int i=64-word_size; i<64;i++) {
                input_a_copy[i] = input_a[i];
                input_b_copy[i] = input_b[i];
            }
            //bool[,] each_bit_product = new bool[64,64];
            bool[] bit_product = new bool[64];
            bool[] sum_of_products = new bool[64];
            int k=0;
            for (int i=63;i>=64-word_size;i--) {
                for (int j=63-k; j>=64-word_size; j--) {
                    //each_bit_product[i,j] = multiply_two_bits(input_a_copy[j+k], input_b_copy[i]);
                    bit_product[j] = multiply_two_bits(input_a_copy[j+k], input_b_copy[i]);
                    
                }
                k++;
                carry = false;
                sum_of_products = add(sum_of_products,bit_product);
            }
            output = sum_of_products;
            return output;
        }
        public bool[] and(bool[] input_a, bool[] input_b) {
            for(int i=64-word_size; i<64;i++) {
                output[i] = input_a[i] && input_b[i];
            }
            return output;
        }
        public bool[] or(bool[] input_a, bool[] input_b) {
            for(int i=64-word_size; i<64;i++) {
                output[i] = input_a[i] || input_b[i];
            }
            return output;
        }
        public bool[] xor(bool[] input_a, bool[] input_b) {
            for(int i=64-word_size; i<64;i++) {
                output[i] = xor_each_bit(input_a[i], input_b[i]);
            }
            return output;
        }
        public bool[] not(bool[] input) {
            bool[] input_copy = ones_complement(input);
            return input_copy; //not() does not modify output buffer
        }
   }
}
