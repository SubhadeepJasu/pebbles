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
        public bool[] input_a;
        public bool[] input_b;
        public bool[] output;
        public bool carry;
        public bool aux_carry;
        public bool f0;
        public bool overflow_flag;
        public bool parity_flag;
        public bool zero_flag;
        public bool negative_flag;
        
        public Programmer() {
            input_a =new bool[64];
            input_b =new bool[64];
            output =new bool[64];
        }
        public bool xor (bool a, bool b) {
            if(a == b) {
                return false;
            }
            return true;
        }
        public bool full_add (bool a, bool b) {
            bool c = carry;
            carry = (a && b) || (b && carry) || (a && carry);
            return xor(c, xor(a,b));
        }
        public void add () {
            for(int i=63; i>63-word_size;i--) {
                output[i] = full_add(input_a[i], input_b[i]);  //always set carry to false on first iteration
            }
        }
        public bool[] twos_complement(bool[] input) {
        bool[] result = new bool[64];
            for(int i=0;i<63;i++) {
                result[i] = !input[i];  //always set carry to false on first iteration
            }
            Programmer prog= new Programmer();
            prog.input_a = result;
            for(int i = 0; i<63; i++) {
                prog.input_b[i] = false;
            }
            prog.input_b[63] = true;
            prog.add();
            return prog.output;
        }
        public void subtract () {
            input_b = twos_complement(input_b);
            add();
        }
   }
}
