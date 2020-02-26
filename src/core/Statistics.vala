/*
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
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Saunak Biswas <saunakbis97@gmail.com>
*/


namespace Pebbles
{
    public class Statistics{
        private string[] tokens;
        private double[] x;
        private int decimal_places;
        public Statistics (int decimal_places) {
            this.decimal_places = decimal_places;
        }
        
        private void string_splitter (string input_vals){
            tokens = input_vals.split(",");
            x = new double [tokens.length];
            for(int i = 0; i < tokens.length; i++) { 
                x[i] = double.parse(tokens[i]);
            }
        }
        
        private string output_to_string (double values) {
            // Take care of float accuracy of the result
            string output = Utils.manage_decimal_places (values, decimal_places);

            // Remove trailing 0s and decimals
            while (output.has_suffix ("0")) {
                output = output.slice (0, -1);
            }
            if (output.has_suffix (".")) {
                output = output.slice (0, -1);
            }
            return output;
        }
        
        public string summation_x (string input_vals) {
            double sum_x=0.0;
            string_splitter(input_vals);
            for(int i = 0; i < x.length; i++) {
                sum_x = sum_x + x[i];
            }
            
            return output_to_string (sum_x);
        }
        
        public string summation_x_square (string input_vals) {
            double sum_x_square=0.0;
            string_splitter(input_vals);
            for(int i = 0; i < x.length; i++) {
                sum_x_square = sum_x_square + Math.pow(x[i],2);
            }
            
            return output_to_string (sum_x_square);
        }
        
        public string mean_x (string input_vals) {
            double avg_x = 0.0;
            string_splitter(input_vals);
            for(int i = 0; i < x.length; i++) {
                avg_x = avg_x + x[i];
            }
            return output_to_string (avg_x / x.length);
        }
        
        public string mean_x_square (string input_vals) {
            double avg_x_square = 0.0;
            string_splitter(input_vals);
            for(int i = 0; i < x.length; i++) {
                avg_x_square = avg_x_square + Math.pow(x[i],2);
            }
            return output_to_string (avg_x_square / x.length);
        }
        
        public string median (string input_vals) {
            string_splitter(input_vals);
            Gsl.Sort.sort (x, 1, x.length);
            if(x.length % 2 == 0) {
                return (output_to_string(x[x.length / 2 - 1]) + ", " + output_to_string(x[(x.length / 2) ]) );
            }
            else {
                return output_to_string (x[x.length / 2]);
            }
        }

        public string mode (string input_vals) {
            if(input_vals == " " || input_vals == null) {
                return "0";
            }
            string_splitter(input_vals);
            double[] element = new double[x.length];
            int no_of_elements = 1;
            int max_frequency = 0;
            for(int i = 0; i < x.length; i++) {
                double temp_element = x[i];
                int temp_frequency = 0;
                for(int j = 0; j < x.length; j++) {
                    if(temp_element == x[j]){
                        temp_frequency = temp_frequency + 1;
                    }
                }
                if(temp_frequency == max_frequency) {
                    no_of_elements = no_of_elements + 1;
                    element[no_of_elements - 1] = temp_element;
                }
                if(temp_frequency > max_frequency){
                    element[0] = temp_element;
                    for(int j = 1; j < no_of_elements; j++) {
                        element[j] = 0;
                    }
                    no_of_elements = 1;
                    max_frequency = temp_frequency;
                }
            }
            //element array may contain duplicates entries of the same mode element(s)
            string mode_elements = output_to_string (element[0]);
            int flag = 0;
            for(int i =1; i< no_of_elements; i++) {
                flag = 0;
                for(int j = 0; j < i; j++) {
                    if(element[i] == element[j]) {
                        flag =1;
                        break;
                    }
                }
                if(flag == 0) {
                    mode_elements = mode_elements.concat(", ", output_to_string (element[i]));
                }
            }
            return mode_elements;
        }

        public string geometric_mean (string input_vals) {
            string_splitter(input_vals);
            double geo_mean = 0;
            for(int i = 0; i < x.length; i++) {
                geo_mean = geo_mean + Math.log(x[i]);
            }
            geo_mean = geo_mean / x.length;
            geo_mean = Math.exp(geo_mean);
            return output_to_string (geo_mean);
        }

        private string summation_x_minus_mean_whole_square (string input_vals) {
            double mean_of_x = double.parse(mean_x(input_vals));
            double summation=0.0;
            for(int i = 0; i < x.length; i++) {
                summation = summation + Math.pow((x[i] - mean_of_x),2);
            }
            return output_to_string (summation);
        }
        
        //s^2
        public string sample_variance (string input_vals) {
            double variance = double.parse(summation_x_minus_mean_whole_square(input_vals));
            variance = variance / (x.length - 1);
            return output_to_string (variance);
        }

        //s
        public string sample_standard_deviation (string input_vals) {
            double standard_deviation = double.parse(sample_variance(input_vals));
            standard_deviation = Math.sqrt(standard_deviation);
            return output_to_string (standard_deviation);
        }

        //sigma^2
        public string population_variance (string input_vals) {
            double variance = double.parse(summation_x_minus_mean_whole_square(input_vals));
            variance = variance / x.length;
            return output_to_string (variance);
        }

        //sigma
        public string population_standard_deviation (string input_vals) {
            double standard_deviation = double.parse(population_variance(input_vals));
            standard_deviation = Math.sqrt(standard_deviation);
            return output_to_string (standard_deviation);
        }
    }

}

