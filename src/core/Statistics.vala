/*
* Copyright (c) 2017-2018 Subhadeep Jasu (https://github.com/subhadeepjasu)
* Copyright (c) 2017-2018 Saunak Biswas (https://github.com/saunakbis97)
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
        public string[] tokens;
        public double[] x;
        
        private void string_splitter (string input_vals){
            tokens = input_vals.split(",");
            x = new double [tokens.length];
            for(int i = 0; i < tokens.length; i++) { 
                x[i] = double.parse(tokens[i]);
            }
        }
        
        public string summation_x (string input_vals) {
            double sum_x=0.0;
            string_splitter(input_vals);
            for(int i = 0; i < x.length; i++) {
                sum_x = sum_x + x[i];
            }
            
            return ("%.9f".printf (sum_x));
        }
        
        public string summation_x_square (string input_vals) {
            double sum_x_square=0.0;
            string_splitter(input_vals);
            for(int i = 0; i < x.length; i++) {
                sum_x_square = sum_x_square + Math.pow(x[i],2);
            }
            
            return ("%.9f".printf (sum_x_square));
        }
        
        public string mean_x (string input_vals) {
            double avg_x = 0.0;
            string_splitter(input_vals);
            for(int i = 0; i < x.length; i++) {
                avg_x = avg_x + x[i];
            }
            return ("%.9f".printf (avg_x / x.length));
        }
        
        public string mean_x_square (string input_vals) {
            double avg_x_square = 0.0;
            string_splitter(input_vals);
            for(int i = 0; i < x.length; i++) {
                avg_x_square = avg_x_square + Math.pow(x[i],2);
            }
            return ("%.9f".printf (avg_x_square / x.length));
        }
        
        private void bubble_sort (){
            for(int i = 0; i < x.length - 1; i++) {
                for(int j=0; j < x.length - i - 1; i++) {
                    if(x[j+1] < x[j]){
                        double temp = x[j];
                        x[j] = x[j+1];
                        x[j+1] = temp;
                    }
                }
            }
        }
        public string median (string input_vals) {
            string_splitter(input_vals);
            bubble_sort();
            if(x.length % 2 == 0) {
                return ("%.9f".printf ((x[x.length / 2 - 1] + x[(x.length / 2) ]) / 2));
            }
            else {
                return x[x.length / 2].to_string();
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
            string mode_elements = ("%.9f".printf (element[0]));
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
                    mode_elements = mode_elements.concat(",%.9f".printf (element[i]));
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
            return ("%.9f".printf (geo_mean));
        }

        private string summation_x_minus_mean_whole_square (string input_vals) {
            double mean_of_x = double.parse(mean_x(input_vals));
            double summation=0.0;
            for(int i = 0; i < x.length; i++) {
                summation = summation + Math.pow((x[i] - mean_of_x),2);
            }
            return ("%.9f".printf (summation));
        }
        
        //s^2
        public string sample_variance (string input_vals) {
            double variance = double.parse(summation_x_minus_mean_whole_square(input_vals));
            variance = variance / (x.length - 1);
            return ("%.9f".printf (variance));
        }

        //s
        public string sample_standard_deviation (string input_vals) {
            double standard_deviation = double.parse(sample_variance(input_vals));
            standard_deviation = Math.sqrt(standard_deviation);
            return ("%.9f".printf (standard_deviation));
        }

        //sigma^2
        public string population_variance (string input_vals) {
            double variance = double.parse(summation_x_minus_mean_whole_square(input_vals));
            variance = variance / x.length;
            return ("%.9f".printf (variance));
        }

        //sigma
        public string population_standard_deviation (string input_vals) {
            double standard_deviation = double.parse(population_variance(input_vals));
            standard_deviation = Math.sqrt(standard_deviation);
            return ("%.9f".printf (standard_deviation));
        }
    }
/*
    void main() {
        stdout.printf("Enter the nos seperated by commas:- ");
        string input = stdin.read_line();
        Statistics s1 = new Statistics();
        stdout.printf("The summation of x is %s \n",s1.summation_x(input));
        stdout.printf("The summation of x square is %s \n",s1.summation_x_square(input));
        stdout.printf("The mean of x is %s \n",s1.mean_x(input));
        stdout.printf("The mean square of x is %s \n",s1.mean_x_square(input));
        stdout.printf("The median is %s \n",s1.median(input));
        stdout.printf("The mode element(s) is %s \n",s1.mode(input));
        stdout.printf("The geometric mean is %s \n",s1.geometric_mean(input));
        stdout.printf("The sample variance is %s \n",s1.sample_variance(input));
        stdout.printf("The sample standard deviation is %s \n",s1.sample_standard_deviation(input));
        stdout.printf("The population variance is %s \n",s1.population_variance(input));
        stdout.printf("The population standard deviation is %s \n",s1.population_standard_deviation(input));
    }
    */
}

