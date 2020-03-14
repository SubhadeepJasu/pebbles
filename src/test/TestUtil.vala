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
    public class TestUtil {
        public static void show_greeter () {
            stdout.printf ("                             
 _____     _   _   _         
|  _  |___| |_| |_| |___ ___ 
|   __| -_| . | . | | -_|_ -|
|__|  |___|___|___|_|___|___|
                             \n");
            stdout.printf ("=============================================================\n\n");
            stdout.printf ("Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>\n");
            stdout.printf ("\n=============================================================\n\n");
            stdout.printf ("Running Automatic Tests...\n");
        }
        private static void test_tokenize (string exp) {
            stdout.printf ("\n'%s'", exp);
            stdout.printf ("\n -> ");
            var result = Utils.st_tokenize (exp);
            stdout.printf ("'%s'\n", result);
        }
        private static void test_scientific (string exp, string what_i_should_get, GlobalAngleUnit? angle_type = GlobalAngleUnit.DEG) {
            ScientificCalculator sci_calc = new ScientificCalculator ();
            var what_i_got = sci_calc.get_result (exp, angle_type);
            if (what_i_got != what_i_should_get) {
                stdout.printf ("[ERROR] Given '%s':,\n", exp);
                stdout.printf ("        I should get '%s', but I got '%s'!\n", what_i_should_get, what_i_got);
            }
        }
        private static void test_date_difference (int d1, int m1, int y1, int d2, int m2, int y2, string days, string year, string month, string week, string day) {
            DateTime start_date_time = new DateTime( new TimeZone.local() , y1 , m1 , d1 , 0 , 0 , 0 );
            DateTime end_date_time = new DateTime( new TimeZone.local() , y2 , m2 , d2 , 0 , 0 , 0 );
            DateCalculator date_calculator_object = new DateCalculator();
            string result = date_calculator_object.date_difference( start_date_time , end_date_time );
            if (result != days) {
                stdout.printf ("[ERROR] Given %d/%d/%d to %d/%d/%d, we are getting %s, we should get %s\n", d1, m1, y1, d2, m2, y2, result, days);
            }
            DateFormatted formatted_date_difference = date_calculator_object.difference_formatter(start_date_time , end_date_time);
            string res_day = (formatted_date_difference.day).to_string ();
            string res_wek = (formatted_date_difference.week).to_string ();
            string res_mon = (formatted_date_difference.month).to_string ();
            string res_yar = (formatted_date_difference.year).to_string ();
            if (res_day != day || res_wek != week || res_mon != month || res_yar != year) {
                stdout.printf ("[ERROR] Given %d/%d/%d to %d/%d/%d, we are getting %s years %s months %s weeks %s days,\n", d1, m1, y1, d2, m2, y2, res_yar, res_mon, res_wek, res_day);
                stdout.printf ("        we should get %s years %s months %s weeks %s days.\n", year, month, week, day);
            }
        }
        private static void test_conversion_from_binary (string bin, string hex, string decimal, string octal) {
            if(ProgrammerCalculator.binary_to_decimal (bin) != decimal) {
                 stdout.printf ("[ERROR] Given %s, the decimal should be = %s but I got = %s\n",bin,decimal,ProgrammerCalculator.binary_to_decimal (bin));
            }
            if(ProgrammerCalculator.binary_to_octal (bin) != octal) {
                 stdout.printf ("[ERROR] Given %s, the octal should be = %s but I got = %s\n",bin,octal,ProgrammerCalculator.binary_to_octal (bin));
            }
            if(ProgrammerCalculator.binary_to_hexadecimal (bin) != hex) {
                 stdout.printf ("[ERROR] Given %s, the hexadecimal should be = %s but I got = %s\n",bin,hex,ProgrammerCalculator.binary_to_hexadecimal (bin));
            }
        }
        private static void test_conversion_from_octal (string octal, string hex, string decimal, string bin) {
            if(ProgrammerCalculator.octal_to_binary (octal) != bin) {
                 stdout.printf ("[ERROR] Given %s, the binary should be = %s but I got = %s\n",octal,bin,ProgrammerCalculator.octal_to_binary (octal));
            }
            if(ProgrammerCalculator.octal_to_decimal (octal) != decimal) {
                 stdout.printf ("[ERROR] Given %s, the decimal should be = %s but I got = %s\n",bin,octal,ProgrammerCalculator.octal_to_decimal (octal));
            }
            if(ProgrammerCalculator.octal_to_hexadecimal (octal) != hex) {
                 stdout.printf ("[ERROR] Given %s, the hexadecimal should be = %s but I got = %s\n",bin,hex,ProgrammerCalculator.octal_to_hexadecimal (octal));
            }
        }
        private static void test_conversion_from_decimal (string decimal, string hex, string octal, string bin) {
            if(ProgrammerCalculator.decimal_to_binary (decimal) != bin) {
                 stdout.printf ("[ERROR] Given %s, the binary should be = %s but I got = %s\n",decimal,bin,ProgrammerCalculator.decimal_to_binary (decimal));
            }
            if(ProgrammerCalculator.decimal_to_octal (decimal) != octal) {
                 stdout.printf ("[ERROR] Given %s, the octal should be = %s but I got = %s\n",decimal,octal,ProgrammerCalculator.decimal_to_octal (decimal));
            }
            if(ProgrammerCalculator.decimal_to_hexadecimal (decimal) != hex) {
                 stdout.printf ("[ERROR] Given %s, the hexadecimal should be = %s but I got = %s\n",decimal,hex,ProgrammerCalculator.decimal_to_hexadecimal (decimal));
            }
        }
        private static void test_conversion_from_hexadecimal (string hex, string decimal, string octal, string bin) {
            if(ProgrammerCalculator.hexadecimal_to_binary (hex) != bin) {
                 stdout.printf ("[ERROR] Given %s, the binary should be = %s but I got = %s\n",hex,bin,ProgrammerCalculator.hexadecimal_to_binary (hex));
            }
            if(ProgrammerCalculator.hexadecimal_to_octal (hex) != octal) {
                 stdout.printf ("[ERROR] Given %s, the octal should be = %s but I got = %s\n",hex,octal,ProgrammerCalculator.hexadecimal_to_octal (hex));
            }
            if(ProgrammerCalculator.hexadecimal_to_decimal (hex) != decimal) {
                 stdout.printf ("[ERROR] Given %s, the decimal should be = %s but I got = %s\n",hex,decimal,ProgrammerCalculator.hexadecimal_to_decimal (hex));
            }
        }
        private static void test_logical_operations_on_decimal (string decimal1, string decimal2, string and_decimal, string or_decimal, string not_decimal1, string not_decimal2, string xor_decimal) {
            if(ProgrammerCalculator.decimal_and_operation(decimal1,decimal2) != and_decimal) {
                stdout.printf ("[ERROR] Given %s and %s, the AND of the two should be = %s but I got = %s\n",decimal1, decimal2, and_decimal,ProgrammerCalculator.decimal_and_operation (decimal1, decimal2));
            }
            if(ProgrammerCalculator.decimal_or_operation(decimal1,decimal2) != or_decimal) {
                stdout.printf ("[ERROR] Given %s and %s, the OR of the two should be = %s but I got = %s\n",decimal1, decimal2, or_decimal,ProgrammerCalculator.decimal_or_operation (decimal1, decimal2));
            }
            if(ProgrammerCalculator.decimal_not_operation(decimal1) != not_decimal1) {
                stdout.printf ("[ERROR] Given %s , the NOT should be = %s but I got = %s\n",decimal1, not_decimal1,ProgrammerCalculator.decimal_not_operation (decimal1));
            }
            if(ProgrammerCalculator.decimal_not_operation(decimal2) != not_decimal2) {
                stdout.printf ("[ERROR] Given %s , the NOT should be = %s but I got = %s\n",decimal2, not_decimal2,ProgrammerCalculator.decimal_not_operation (decimal2));
            }
            if(ProgrammerCalculator.decimal_xor_operation(decimal1,decimal2) != xor_decimal) {
                stdout.printf ("[ERROR] Given %s and %s, the XOR of the two should be = %s but I got = %s\n",decimal1, decimal2, xor_decimal,ProgrammerCalculator.decimal_xor_operation (decimal1, decimal2));
            }
        }
        private static void test_arithmetic_operations_on_decimal (string decimal1, string decimal2, string mod_decimal, string addition_decimal, string subtraction_decimal, string multiplication_decimal, string division_decimal) {
            if(ProgrammerCalculator.decimal_mod_operation(decimal1,decimal2) != mod_decimal) {
                stdout.printf ("[ERROR] Given %s and %s, the MOD of the two should be = %s but I got = %s\n",decimal1, decimal2, mod_decimal,ProgrammerCalculator.decimal_mod_operation (decimal1, decimal2));
            }
            if(ProgrammerCalculator.decimal_addition_operation(decimal1,decimal2) != addition_decimal) {
                stdout.printf ("[ERROR] Given %s and %s, the ADDITION of the two should be = %s but I got = %s\n",decimal1, decimal2, addition_decimal,ProgrammerCalculator.decimal_addition_operation (decimal1, decimal2));
            }
            if(ProgrammerCalculator.decimal_subtraction_operation(decimal1,decimal2) != subtraction_decimal) {
                stdout.printf ("[ERROR] Given %s and %s, the SUBTRACTION of the two should be = %s but I got = %s\n",decimal1, decimal2, subtraction_decimal,ProgrammerCalculator.decimal_subtraction_operation (decimal1, decimal2));
            }
            if(ProgrammerCalculator.decimal_multiplication_operation(decimal1,decimal2) != multiplication_decimal) {
                stdout.printf ("[ERROR] Given %s and %s, the MULTIPLICATION of the two should be = %s but I got = %s\n",decimal1, decimal2, multiplication_decimal,ProgrammerCalculator.decimal_multiplication_operation (decimal1, decimal2));
            }
            if(ProgrammerCalculator.decimal_division_operation(decimal1,decimal2) != division_decimal) {
                stdout.printf ("[ERROR] Given %s and %s, the DIVISION of the two should be = %s but I got = %s\n",decimal1, decimal2, division_decimal,ProgrammerCalculator.decimal_division_operation (decimal1, decimal2));
            }
        }
        private static void test_shift_operations_on_decimal (string decimal1, string decimal2, string left_shift_decimal, string right_shift_decimal, string left_rotate_decimal, string right_rotate_decimal, string value_mode) {
            if(ProgrammerCalculator.decimal_left_shift_operation(decimal1,decimal2,value_mode) != left_shift_decimal) {
                stdout.printf ("[ERROR] Given %s and %s, value mode is %s, the LEFT SHIFT of the first by second should be = %s but I got = %s\n",decimal1, decimal2, value_mode, left_shift_decimal,ProgrammerCalculator.decimal_left_shift_operation (decimal1, decimal2, value_mode));
            }
            if(ProgrammerCalculator.decimal_right_shift_operation(decimal1,decimal2,value_mode) != right_shift_decimal) {
                stdout.printf ("[ERROR] Given %s and %s, value mode is %s, the RIGHT SHIFT of the first by second should be = %s but I got = %s\n",decimal1, decimal2, value_mode, right_shift_decimal,ProgrammerCalculator.decimal_right_shift_operation (decimal1, decimal2, value_mode));
            }
            if(ProgrammerCalculator.decimal_left_rotate_operation(decimal1,decimal2,value_mode) != left_rotate_decimal) {
                stdout.printf ("[ERROR] Given %s and %s, value mode is %s, the LEFT ROTATION of the first by second should be = %s but I got = %s\n",decimal1, decimal2, value_mode, left_rotate_decimal,ProgrammerCalculator.decimal_left_rotate_operation (decimal1, decimal2, value_mode));
            }
            if(ProgrammerCalculator.decimal_right_rotate_operation(decimal1,decimal2,value_mode) != right_rotate_decimal) {
                stdout.printf ("[ERROR] Given %s and %s, value mode is %s, the RIGHT ROTATION of the first by second should be = %s but I got = %s\n",decimal1, decimal2, value_mode, right_rotate_decimal,ProgrammerCalculator.decimal_right_rotate_operation (decimal1, decimal2, value_mode));
            }
        }
        public static void run_test () {
            show_greeter ();
            stdout.printf ("\nTesting Tokenization...\n");
            stdout.printf ("-------------------------------------------------------------\n");

           /* 
            * Certain UTF-8 escape characters require a space
            * after it to seperate it from the next character.
            * This is only during testing. This is however not
            * an issue when fetching input from the text entry
            * in ScientificDisplay.
            */

            test_tokenize ("sin60 + (tan 30)");
            test_tokenize ("4\xC3\xB7 2");
            test_tokenize ("sin60 + (tan 30)\xC3\x97 cos\xCF\x80 \xC3\xB7 2 + (isin 0.5 - itan 0.35 ^ icos0.854)");
            test_tokenize ("sin 45+5 \xC3\x97 isin 80 + 9 sinh \xF0\x9D\x9B\xBE + \xCF\x86 - isinh \xF0\x9D\x9B\x87(3)");
            test_tokenize ("log e\xC3\xB7 (ln K - 8P2 - 10C7)");
            stdout.printf ("\nTesting Bracket Balance Check...\n");
            stdout.printf ("-------------------------------------------------------------");
            test_tokenize ("2 + (9 - 5)\xC3\x97 5  - (8-7))");
            
            stdout.printf ("\nTesting Scientific Calculator\n");
            stdout.printf ("-------------------------------------------------------------\n");
            
            test_scientific ("2+2", "4");
            test_scientific ("4.23+    1.11", "5.34");
            test_scientific (".13+.51", "0.64");
            test_scientific ("25.123 - 234.2", "-209.077");
            test_scientific ("1*1", "1");
            test_scientific ("11 *1.1", "12.1");
            test_scientific ("5*-1", "-5");
            test_scientific ("5* - 3.000", "-15");
            test_scientific ("-1/-1", "1");
            test_scientific ("4\xC3\xB7 2", "2");
            test_scientific ("44÷2", "22");
            test_scientific ("4/2", "2");
            test_scientific ("89×5", "445");
            test_scientific ("69×52", "3,588");
            test_scientific ("-1 / (−1)", "1");
            test_scientific ("144 / 15", "9.6");
            test_scientific ("14400 / 12", "1,200");
            test_scientific ("144000 / 12", "12,000");
            test_scientific ("3456^0.5 - sqrt(3456)", "0");
            test_scientific ("3456^-0.5 * sqrt(3456)", "1");
            test_scientific ("723 mod 5", "3");
            test_scientific ("2%", "0.02");
            test_scientific ("(2 + 2)% - 0.04", "0");
            test_scientific ("14E-2", "0.14");
            test_scientific ("1.1E2 - 1E1", "100");

            test_scientific ("2 * pi", "6.283185307");
            test_scientific ("pi - 2", "1.141592654");
            test_scientific ("(π)", "3.141592654");
            test_scientific ("e", "2.718281828");

            test_scientific ("sqrt (144)", "12");
            test_scientific ("sqr 2", "4");
            test_scientific ("√423", "20.566963801");
            test_scientific ("sin(pi ÷ 2)", "1", GlobalAngleUnit.RAD);
            test_scientific ("sin(-pi)", "0", GlobalAngleUnit.RAD);
            test_scientific ("cos(90)", "0", GlobalAngleUnit.DEG);
            test_scientific ("sinh(2)", "3.626860408", GlobalAngleUnit.RAD);
            test_scientific ("cosh2", "3.762195691", GlobalAngleUnit.RAD);
            test_scientific ("sin(0.123)^2 + cos(0.123)^2", "4", GlobalAngleUnit.RAD);
            test_scientific ("tan(0.245) - sin(0.245) / cos(0.245)", "4", GlobalAngleUnit.RAD);

            test_scientific ("sqrt(5^2 - 4^2)", "3");
            test_scientific ("sqrt(423) + (3.23 * 8.56) - 1E2", "-51.784236199");
            test_scientific ("sqrt(-1 + 423 + 1) + (3.23 * 8.56) - sin(90 + 0.2)", "47.428606036");
            test_scientific ("e^5.25 / exp(5.25)", "1");
            test_scientific ("pi * pi", "9.869604401");
            test_scientific ("10 + 5 - 10%", "14.9");
            test_scientific ("100 + 20%", "120");
            test_scientific ("20% + 100", "100.2");
            
            stdout.printf ("\nTesting Date Difference Calculator\n");
            stdout.printf ("-------------------------------------------------------------\n");
            
            test_date_difference (20, 11, 2018, 30, 11, 2018, "10", "0", "0", "1", "3");
            test_date_difference (17, 1, 2019, 7, 2, 2042, "8422", "23", "0", "3", "0");
            test_date_difference (20, 11, 2018, 20, 11, 2018, "0", "0", "0", "0", "0"); 

            stdout.printf ("\nTesting All conversions from binary\n");
            stdout.printf ("-------------------------------------------------------------\n");
            test_conversion_from_binary ("10", "2", "2", "2");
            test_conversion_from_binary ("1110", "E", "14", "16");
            test_conversion_from_binary ("0", "0", "0", "0");

            stdout.printf ("\nTesting All conversions from octal\n");
            stdout.printf ("-------------------------------------------------------------\n");
            test_conversion_from_octal ("3", "3", "3", "11");
            test_conversion_from_octal ("16", "E", "14", "1110");
            test_conversion_from_octal ("2000", "400", "1024", "10000000000");
            test_conversion_from_octal ("0", "0", "0", "0");

            stdout.printf ("\nTesting All conversions from decimal\n");
            stdout.printf ("-------------------------------------------------------------\n");
            test_conversion_from_decimal ("3", "3", "3", "11");
            test_conversion_from_decimal ("1024", "400", "2000", "10000000000");
            test_conversion_from_decimal ("0", "0", "0", "0");

            stdout.printf ("\nTesting All conversions from hexadecimal\n");
            stdout.printf ("-------------------------------------------------------------\n");
            test_conversion_from_hexadecimal ("16", "22", "26", "10110");
            test_conversion_from_hexadecimal ("3", "3", "3", "11");
            test_conversion_from_hexadecimal ("0", "0", "0", "0");

            stdout.printf ("\nTesting All logical operations in decimal\n");
            stdout.printf ("-------------------------------------------------------------\n");
            test_logical_operations_on_decimal ("5", "0", "0", "5", "-6", "-1", "5");
            test_logical_operations_on_decimal ("889", "66", "64", "891", "-890", "-67", "827");
            test_logical_operations_on_decimal ("-66", "6", "6", "-66", "65", "-7", "-72");

            stdout.printf ("\nTesting All arithmetic operations in decimal\n");
            stdout.printf ("-------------------------------------------------------------\n");
            test_arithmetic_operations_on_decimal ("10", "51", "1", "61", "-41", "510", "0");
            test_arithmetic_operations_on_decimal ("-4", "0", "Undefined", "-4", "-4", "0", "Not possible");

            stdout.printf ("\nTesting All shift operations in decimal\n");
            stdout.printf ("-------------------------------------------------------------\n");
            test_shift_operations_on_decimal ("1010", "5", "32320", "3", "32320", "-1879048161", "DWORD");
            test_shift_operations_on_decimal ("88", "1", "-80", "44", "-80", "44", "BYTE");
        }
    }
}
