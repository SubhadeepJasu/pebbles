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
            stdout.printf ("Copyright (c) 2017-2020 Subhadeep Jasu <subhajasu@gmail.com>\n");
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
        private static void test_programmer_integration () {
            var settings = Settings.get_default ();
            settings.number_system = NumberSystem.DECIMAL;
            //  ProgrammerCalculator prog_calc_front = new ProgrammerCalculator ();
        }
        //  private static void test_programmer(string input1, string input2) {
        //      Programmer prog_calc = new Programmer();
        //      string[] input1_arr = input1.split(" ");
        //      string[] input2_arr = input2.split(" ");
        //      bool[] input_a = new bool[64];
        //      bool[] input_b = new bool[64];
        //      bool[] output;
        //      for (int i = 0; i< 64; i++) {
        //          if(input1_arr[i] == "0") {
        //              input_a[i] = false;
        //          }
        //          else {
        //              input_a[i] = true;
        //          }

        //          if(input2_arr[i] == "0") {
        //              input_b[i] = false;
        //          }
        //          else {
        //              input_b[i] = true;
        //          }
        //      }

        //      prog_calc.word_size = WordSize.BYTE;
        //      print("Binary 1's complement operation:");
        //      prog_calc.ones_complement(input_a);
        //      output = prog_calc.output;
        //      for(int i =0; i<64; i++) {
        //          print("%s",output[i]?"1":"0");
        //      }
        //      print("\n");

        //      prog_calc.word_size = WordSize.BYTE;
        //      print("Binary 2's complement operation:");
        //      prog_calc.twos_complement(input_a);
        //      output = prog_calc.output;
        //      for(int i =0; i<64; i++) {
        //          print("%s",output[i]?"1":"0");
        //      }
        //      print("\n");

        //      prog_calc.word_size = WordSize.BYTE;
        //      print("Binary Addition operation:");
        //      prog_calc.add(input_a, input_b);
        //      output = prog_calc.output;
        //      for(int i =0; i<64; i++) {
        //          print("%s",output[i]?"1":"0");
        //      }
        //      print("\n");

        //      print("Binary Subtraction operation:");
        //      prog_calc.subtract(input_a, input_b, 8);
        //      output = prog_calc.output;
        //      print("sub\n");
        //      for(int i =0; i<64; i++) {
        //          print("%s",output[i]?"1":"0");
        //      }
        //      print("\n");

        //      print("Binary Multiplication operation:");
        //      prog_calc.multiply(input_a, input_b);
        //      output = prog_calc.output;
        //      for(int i =0; i<64; i++) {
        //          print("%s",output[i]?"1":"0");
        //      }
        //      print("\n");

        //      print("Binary Division quotient operation:");
        //      prog_calc.division_quotient(input_a, input_b, 8);
        //      output = prog_calc.output;
        //      for(int i =0; i<64; i++) {
        //          print("%s",output[i]?"1":"0");
        //      }
        //      print("\n");

        //      prog_calc.word_size = WordSize.BYTE;
        //      print("Binary And operation:");
        //      prog_calc.and(input_a, input_b);
        //      output = prog_calc.output;
        //      for(int i =0; i<64; i++) {
        //          print("%s",output[i]?"1":"0");
        //      }
        //      print("\n");

        //      prog_calc.word_size = WordSize.BYTE;
        //      print("Binary Nand operation:");
        //      prog_calc.nand(input_a, input_b);
        //      output = prog_calc.output;
        //      for(int i =0; i<64; i++) {
        //          print("%s",output[i]?"1":"0");
        //      }
        //      print("\n");

        //      prog_calc.word_size = WordSize.BYTE;
        //      print("Binary Or operation:");
        //      prog_calc.or(input_a, input_b);
        //      output = prog_calc.output;
        //      for(int i =0; i<64; i++) {
        //          print("%s",output[i]?"1":"0");
        //      }
        //      print("\n");

        //      prog_calc.word_size = WordSize.BYTE;
        //      print("Binary Nor operation:");
        //      prog_calc.nor(input_a, input_b);
        //      output = prog_calc.output;
        //      for(int i =0; i<64; i++) {
        //          print("%s",output[i]?"1":"0");
        //      }
        //      print("\n");

        //      prog_calc.word_size = WordSize.BYTE;
        //      print("Binary Xor operation:");
        //      prog_calc.xor(input_a, input_b);
        //      output = prog_calc.output;
        //      for(int i =0; i<64; i++) {
        //          print("%s",output[i]?"1":"0");
        //      }
        //      print("\n");

        //      prog_calc.word_size = WordSize.BYTE;
        //      print("Binary Xnor operation:");
        //      prog_calc.xnor(input_a, input_b);
        //      output = prog_calc.output;
        //      for(int i =0; i<64; i++) {
        //          print("%s",output[i]?"1":"0");
        //      }
        //      print("\n");

        //      prog_calc.word_size = WordSize.BYTE;
        //      print("Binary Not operation:");
        //      prog_calc.not(input_a);
        //      output = prog_calc.output;
        //      for(int i =0; i<64; i++) {
        //          print("%s",output[i]?"1":"0");
        //      }
        //      print("\n");
        //  }
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

            stdout.printf ("\nIntegration Testing Programmer Calculator\n");
            stdout.printf ("-------------------------------------------------------------\n");

            test_programmer_integration ();

            stdout.printf ("\nTesting Programmer New Calculator\n");
            stdout.printf ("-------------------------------------------------------------\n");

            //  test_programmer("0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0", "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1");
            //  test_programmer("0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0", "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1");
            //  test_programmer("0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0", "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 1 1 0 0 0 1 0 1 1");
            //  test_programmer("0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1", "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1");

            stdout.printf ("\nTesting Date Difference Calculator\n");
            stdout.printf ("-------------------------------------------------------------\n");

            test_date_difference (20, 11, 2018, 30, 11, 2018, "10", "0", "0", "1", "3");
            test_date_difference (17, 1, 2019, 7, 2, 2042, "8422", "23", "0", "3", "0");
            test_date_difference (20, 11, 2018, 20, 11, 2018, "0", "0", "0", "0", "0");
        }
    }
}
