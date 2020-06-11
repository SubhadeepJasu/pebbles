/*-
 * Copyright (c) 2017-2020 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright (c) 2017-2020 Saunak Biswas  <saunakbis97@gmail.com>
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
    
    public class ScientificCalculator {
        public string[] tokens;
        public GlobalAngleUnit angle_mode_sci;
        private const double GRAD_VAL     = Math.PI / 200;
        private const double DEG_VAL      = Math.PI / 180;
        private const double INV_GRAD_VAL = 200 / Math.PI;
        private const double INV_DEG_VAL  = 180 / Math.PI;

        public string get_result (string exp, GlobalAngleUnit angle_mode_in, int? float_accuracy = -1, bool? tokenize = true) {
            var result = exp;
            warning(result);
            if (tokenize) {
                result = Utils.st_tokenize (exp.replace (Utils.get_local_radix_symbol (), "."));
            }
            angle_mode_sci = angle_mode_in;
            if (result == "E") {
                return "E";
            }
            return evaluate_exp (result, float_accuracy);
        }

        private static bool has_precedence_pemdas (char op1, char op2) {
            if (op2 == '(' || op2 == ')') {
                return false;
            }
            // Following the PEMDAS rule: <http://mathworld.wolfram.com/PEMDAS.html>
            if (angle_op (op1) && (op2 == '!' || op2 == 'p' || op2 == 'b' || op2 == 'l' || op2 == 'u' || op2 == 'q' || op2 == '^' || op2 == '*' || op2 == '/' || op2 == '-' || op2 == '+' || op2 == 'm')) {
                return false;
            }
            else if ((op1 == '!') && (op2 == 'p' || op2 == 'b' || op2 == 'l' || op2 == 'u' || op2 == 'q' || op2 == '^' || op2 == '*' || op2 == '/' || op2 == '-' || op2 == '+' || op2 == 'm')) {
                return false;
            }
            else if ((op1 == 'p' || op1 == 'b') && (op2 == 'l' || op2 == 'u' || op2 == 'q' || op2 == '^' || op2 == '*' || op2 == '/' || op2 == '-' || op2 == '+' || op2 == 'm')) {
                return false;
            }
            else if ((op1 == 'l') && (op2 == 'u' || op2 == 'q' || op2 == '^' || op2 == '*' || op2 == '/' || op2 == '-' || op2 == '+' || op2 == 'm')) {
                return false;
            }
            else if ((op1 == 'u') && (op2 == '^' || op2 == 'q' || op2 == '*' || op2 == '/' || op2 == '-' || op2 == '+' || op2 == 'm')) {
                return false;
            }
            else if ((op1 == '^' || op1 == 'q') && (op2 == '*' || op2 == '/' || op2 == '-' || op2 == '+' || op2 == 'm')) {
                return false;
            }
            else if ((op1 == '*' || op1 == 'm') && (op2 == '/' || op2 == '+' || op2 == '-')) {
                return false;
            }
            else if ((op1 == '/') && (op2 == '+' || op2 == '-')) {
                return false;
            }
            else {
                return true;
            }
        }
        private static bool has_precedence_bodmas (char op1, char op2) {
            if (op2 == '(' || op2 == ')') {
                return false;
            }
            // Following the PEMDAS rule: <http://mathworld.wolfram.com/PEMDAS.html>
            if (angle_op (op1) && (op2 == '!' || op2 == 'p' || op2 == 'b' || op2 == 'l' || op2 == 'u' || op2 == 'q' || op2 == '^' || op2 == '*' || op2 == '/' || op2 == '-' || op2 == '+' || op2 == 'm')) {
                return false;
            }
            else if ((op1 == '!') && (op2 == 'p' || op2 == 'b' || op2 == 'l' || op2 == 'u' || op2 == 'q' || op2 == '^' || op2 == '*' || op2 == '/' || op2 == '-' || op2 == '+' || op2 == 'm')) {
                return false;
            }
            else if ((op1 == 'p' || op1 == 'b') && (op2 == 'l' || op2 == 'u' || op2 == 'q' || op2 == '^' || op2 == '*' || op2 == '/' || op2 == '-' || op2 == '+' || op2 == 'm')) {
                return false;
            }
            else if ((op1 == 'l') && (op2 == 'u' || op2 == 'q' || op2 == '^' || op2 == '*' || op2 == '/' || op2 == '-' || op2 == '+' || op2 == 'm')) {
                return false;
            }
            else if ((op1 == 'u') && (op2 == '^' || op2 == 'q' || op2 == '*' || op2 == '/' || op2 == '-' || op2 == '+' || op2 == 'm')) {
                return false;
            }
            else if ((op1 == '^' || op1 == 'q') && (op2 == '*' || op2 == '/' || op2 == '-' || op2 == '+' || op2 == 'm')) {
                return false;
            }
            else if ((op1 == '/' || op1 == 'm') && (op2 == '*' || op2 == '+' || op2 == '-')) {
                return false;
            }
            else if ((op1 == '*') && (op2 == '+' || op2 == '-')) {
                return false;
            }
            else if ((op1 == '+') && (op2 == '-')) {
                return false;
            }
            else {
                return true;
            }
        }
        public static double fact (double n) {
            int j = 1, fact = 1;
            for (; j <= n; j++) {
                fact = fact * j;
            }
            return fact;
        }
        public static bool angle_op (unichar op) {
            if (op == 's' || op == 'c' || op == 't' || op == 'i' || op == 'o' || op == 'a' || op == 'h'|| op == 'y' || op == 'e' || op == 'r' || op == 'z' || op == 'k') {
                return true;
            }
            else {
                return false;
            }
        }
        public string apply_op (char op, double a, double b) {
            switch (op) {
                case '+':
                    return (a + b).to_string();
                case '-':
                    return (a - b).to_string();
                case 'u':
                    return ((-1) * b).to_string();
                case '*':
                    return (a * b).to_string();
                case '/':
                    return (b == 0) ? "E" : (a/b).to_string ();
                case 'q':
                    return (Math.pow (b, ((1/a) + 0.0))).to_string ();
                case '^':
                    return (Math.pow(a + 0.0, b + 0.0)).to_string();
                case 'm':                                                           // Modulus
                    return (a % b).to_string();
                case 'l':                                                           // Logarithm
                    return (Math.log(b) / Math.log(a)).to_string();
                case '!':                                                           // Factorial
                    return fact (b).to_string();
                case 'p':
                    return (fact (a) / (fact (a - b))).to_string();
                case 'b':
                    return (fact (a) / (fact (b) * fact (a - b))).to_string();
                case 's':
                    switch (angle_mode_sci) {
                        case (GlobalAngleUnit.RAD):
                            return Math.sin (b).to_string ();
                        case (GlobalAngleUnit.GRAD):
                            return Math.sin (GRAD_VAL * b).to_string ();
                        default:
                            return Math.sin (DEG_VAL * b).to_string ();
                    }
                case 'c':
                    switch (angle_mode_sci) {
                        case (GlobalAngleUnit.RAD):
                            return Math.cos (b).to_string ();
                        case (GlobalAngleUnit.GRAD):
                            return Math.cos (GRAD_VAL * b).to_string ();
                        default:
                            return Math.cos (DEG_VAL * b).to_string ();
                    }
                case 't':
                    switch (angle_mode_sci) {
                        case (GlobalAngleUnit.RAD):
                            return Math.tan (b).to_string ();
                        case (GlobalAngleUnit.GRAD):
                            return Math.tan (GRAD_VAL * b).to_string ();
                        default:
                            return Math.tan (DEG_VAL * b).to_string ();
                    }
                case 'i':
                    {
                        if (b >= -1 && b <= 1) {
                            switch (angle_mode_sci) {
                                case (GlobalAngleUnit.RAD):
                                    return (Math.asin (b)).to_string ();
                                case (GlobalAngleUnit.GRAD):
                                    return (Math.asin (b) * INV_GRAD_VAL).to_string ();
                                default:
                                    return (Math.asin (b) * INV_DEG_VAL).to_string ();
                            }
                        }
                        else {
                            return "E";
                        }
                    }
                case 'o':
                    {
                        if (b >= -1 && b <= 1) {
                            switch (angle_mode_sci) {
                                case (GlobalAngleUnit.RAD):
                                    return (Math.acos (b)).to_string ();
                                case (GlobalAngleUnit.GRAD):
                                    return (Math.acos (b) * INV_GRAD_VAL).to_string ();
                                default:
                                    return (Math.acos (b) * INV_DEG_VAL).to_string ();
                            }
                        }
                        else {
                            return "E";
                        }
                    }
                case 'a':
                    switch (angle_mode_sci) {
                        case (GlobalAngleUnit.RAD):
                            return (Math.atan (b)).to_string ();
                        case (GlobalAngleUnit.GRAD):
                            return (Math.atan (b) * INV_GRAD_VAL).to_string ();
                        default:
                            return (Math.atan (b) * INV_DEG_VAL).to_string ();
                    }
                case 'h':
                switch (angle_mode_sci) {
                        case (GlobalAngleUnit.RAD):
                            return Math.sinh (b).to_string ();
                        case (GlobalAngleUnit.GRAD):
                            return Math.sinh (GRAD_VAL * b).to_string ();
                        default:
                            return Math.sinh (DEG_VAL * b).to_string ();
                    }
                case 'y':
                    switch (angle_mode_sci) {
                        case (GlobalAngleUnit.RAD):
                            return Math.cosh (b).to_string ();
                        case (GlobalAngleUnit.GRAD):
                            return Math.cosh (GRAD_VAL * b).to_string ();
                        default:
                            return Math.cosh (DEG_VAL * b).to_string ();
                    }
                case 'e':
                    switch (angle_mode_sci) {
                        case (GlobalAngleUnit.RAD):
                            return Math.tanh (b).to_string ();
                        case (GlobalAngleUnit.GRAD):
                            return Math.tanh (GRAD_VAL * b).to_string ();
                        default:
                            return Math.tanh (DEG_VAL * b).to_string ();
                    }
                case 'r':
                    switch (angle_mode_sci) {
                        case (GlobalAngleUnit.RAD):
                            return (Math.asinh (b)).to_string ();
                        case (GlobalAngleUnit.GRAD):
                            return (Math.asinh (b) * INV_GRAD_VAL).to_string ();
                        default:
                            return (Math.asinh (b) * INV_DEG_VAL).to_string ();
                    }
                case 'z':
                    switch (angle_mode_sci) {
                        case (GlobalAngleUnit.RAD):
                            return (Math.acosh (b)).to_string ();
                        case (GlobalAngleUnit.GRAD):
                            return (Math.acosh (b) * INV_GRAD_VAL).to_string ();
                        default:
                            return (Math.acosh (b) * INV_DEG_VAL).to_string ();
                    }
                case 'k':
                    switch (angle_mode_sci) {
                        case (GlobalAngleUnit.RAD):
                            return (Math.atanh (b)).to_string ();
                        case (GlobalAngleUnit.GRAD):
                            return (Math.atanh (b) * INV_GRAD_VAL).to_string ();
                        default:
                            return (Math.atanh (b) * INV_DEG_VAL).to_string ();
                    }
            }
            return "E";
        }
        private bool is_operator (string str) {
            unichar chr = str.get_char(0);
            if (chr == '+' || chr == '-' || chr == '/' || chr == '*' || chr == '^' || chr == 'm' || chr == 'l' || chr == '!' || chr == 'p' || chr == 'b' || angle_op (chr) || chr == 'q' || chr == 'u') {
                return true;
            }
            else {
                return false;
            }
        }
        public string evaluate_exp (string exp, int float_accuracy) {
            tokens = exp.split(" ");
            DoubleStack values = new DoubleStack (50);
            CharStack ops = new CharStack (50);
            for (int i = 0; i < tokens.length; i++) {
                // Current tokens is a number, push it to number stack
                if (!is_operator(tokens[i]) && tokens[i] != "(" && tokens[i] != ")") {
                    values.push(double.parse(tokens[i]));
                }

                // If tokens is an opening brace, push it to 'ops'
                else if (tokens[i] == "(") {
                    ops.push ('(');
                }

                //If tokens is a closing brace, solve it till the previous '(' is encountered
                else if (tokens[i] == ")") {
                    while (ops.peek() != '(') {
                        string? tmp = apply_op(ops.pop(), values.pop(), values.pop());
                        if (tmp != "E") {
                            values.push(double.parse(tmp));
                        }
                        else {
                            return "E";
                        }
                    }
                    ops.pop();
                }

                // If token is an operator
                else if (is_operator(tokens[i])) {
                    Settings settings = Settings.get_default ();
                    if (settings.use_pemdas) {
                        while (!r_l_associative (tokens[i]) && !ops.empty() && has_precedence_pemdas(tokens[i].get(0), ops.peek())) {
                            string tmp = apply_op(ops.pop(), values.pop(), values.pop());
                            if (tmp != "E") {
                                values.push(double.parse(tmp));
                            }
                            else {
                                return "E";
                            }
                        }
                    } else {
                        while (!r_l_associative (tokens[i]) && !ops.empty() && has_precedence_bodmas(tokens[i].get(0), ops.peek())) {
                            string tmp = apply_op(ops.pop(), values.pop(), values.pop());
                            if (tmp != "E") {
                                values.push(double.parse(tmp));
                            }
                            else {
                                return "E";
                            }
                        }
                    }
                    // Push current token to stack
                    ops.push(tokens[i].get(0));
                }
            }

            while (!ops.empty()) {
                string? tmp = apply_op(ops.pop(), values.pop(), values.pop());
                if (tmp != "E") {
                    values.push(double.parse(tmp));
                }
                else {
                    return "E";
                }
            }

            // Take care of float accuracy of the result
            string output = Utils.manage_decimal_places (values.pop (), float_accuracy);
            return output;
        }
        private static bool r_l_associative (string operator) {
            if (operator == "u" || operator == "^" || operator == "") {
                return true;
            }
            return false;
        }
    }
    public class CharStack {
        public char[] stack;
        private int top;
        private int n;
        private char temp;
        public CharStack (int num) {
            n = num;
            stack = new char[num];
            top = -1;
        }
        public bool push (char elem) {
            if (top < n) {
                ++top;
                stack[top] = elem;
                return true;
            }
            else {
                return false;
            }
        }
        public char pop () {
            if (top >= 0) {
                temp = stack[top];
                top--;
                return temp;
            }
            return temp;
        }
        public char peek () {
            if (top >= 0) {
                return stack[top];
            }
            return '0';
        }
        public bool empty() {
            if (top < 0) {
                return true;
            }
            else {
                return false;
            }
        }
    }
    public class DoubleStack {
        public double[] stack;
        private int tp;
        private int n;
        private double temp;
        public DoubleStack (int num) {
            n = num;
            stack = new double[num];
            tp = -1;
        }
        public bool push (double elem) {
            if (tp < n) {
                tp++;
                stack[tp] = elem;
                return true;
            }
            else {
                return false;
            }
        }
        public double pop () {
            if (tp >= 0) {
                temp = stack[tp];
                tp--;
                return temp;
            }
            return 0;
        }
    }

}
