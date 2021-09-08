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
    public class HistoryManager {
        private Queue<EvaluationResult> _history;
        public signal void history_updated ();

        public HistoryManager () {
            if (_history == null) {
                _history = new Queue<EvaluationResult>();
            }
        }

        public void append_from_strings (
                                        EvaluationResult.ResultSource result_source,
                                        string problem_expression, 
                                        string result, 
                                        GlobalAngleUnit? angle_mode = null,
                                        EvaluationResult.CalculusResultMode? calc_mode = null, 
                                        double? int_limit_a = null, 
                                        double? int_limit_b = null, 
                                        double? derivative_point = null,
                                        ProgrammerCalculator.Token[]? token_list = null, 
                                        bool[]? output = null, 
                                        GlobalWordLength? output_word_length = GlobalWordLength.BYT,
                                        NumberSystem? number_system = NumberSystem.DECIMAL) {
            if (_history.length > 16) {
                _history.pop_head ();
            }
            _history.push_tail (new EvaluationResult(problem_expression,
                                                result, 
                                                angle_mode, 
                                                calc_mode, 
                                                int_limit_a,
                                                int_limit_b,
                                                derivative_point,
                                                result_source,
                                                token_list,
                                                output,
                                                output_word_length,
                                                number_system));
            appended ();
        }

        public void append_from_evaluation_result (EvaluationResult eval_res) {
            if (_history.length > 16) {
                _history.pop_head ();
            }
            _history.push_tail (eval_res);
            appended ();
        }

        private void appended () {
            history_updated ();
        }

        public EvaluationResult get_nth_evaluation_result (uint n) {
            return _history.peek_nth(n);
        }

        public EvaluationResult get_last_evaluation_result (EvaluationResult.ResultSource? mode = null) {
            if (mode != null) {
                for (uint i = _history.length - 1; i >= 0; i--) {
                    if (_history.peek_nth(i) != null && _history.peek_nth(i).result_source == mode) {
                        return _history.peek_nth(i);
                    }
                }
            }
            unowned EvaluationResult last = _history.peek_tail ();
            return last;
        }

        public uint length (EvaluationResult.ResultSource? mode = null) {
            if (mode != null) {
                uint count = 0;
                for (uint i = 0; i < _history.length; i++) {
                    if (_history.peek_nth(i) != null && _history.peek_nth(i).result_source == mode) {
                        count++;
                    }
                    if (i == 0) {
                        break;
                    }
                }
                return count;
            }
            return _history.length;
        }

        public bool is_empty (EvaluationResult.ResultSource? mode = null) {
            debug ("Finding if history is empty");
            if (_history.length == 0) {
                return true;
            } else {
                // i >= 0 is not the proper way to go and the last condition is
                // for breaking an infinite loop
                if (mode != null && _history != null) {
                    for (uint i = _history.length - 1; i >= 0; i--) {
                        if (_history.peek_nth(i) != null && _history.peek_nth(i).result_source == mode) {
                            return false;
                        }
                        debug ("Found history item (%u)...", i);
                        if (i == 0) {
                            return true;
                        }
                    }
                }
                return true;
            }
        }

        public string to_csv () {
            string csv_data = "";
            for (int j = 0; j < _history.length; j++) {
                csv_data += _history.peek_nth (j).problem_expression + ",";
                csv_data += _history.peek_nth (j).result + ",";
                switch (_history.peek_nth (j).angle_mode) {
                    case GlobalAngleUnit.DEG:
                    csv_data += "DEG,";
                    break;
                    case GlobalAngleUnit.RAD:
                    csv_data += "RAD,";
                    break;
                    case GlobalAngleUnit.GRAD:
                    csv_data += "GRAD,";
                    break;
                }
                switch (_history.peek_nth (j).calc_mode) {
                    case EvaluationResult.CalculusResultMode.INT:
                    csv_data += "INT,";
                    break;
                    case EvaluationResult.CalculusResultMode.DER:
                    csv_data += "DER,";
                    break;
                    default:
                    csv_data += "NONE,";
                    break;
                }
                csv_data += _history.peek_nth (j).int_limit_a.to_string () + ",";
                csv_data += _history.peek_nth (j).int_limit_b.to_string () + ",";
                csv_data += _history.peek_nth (j).derivative_point.to_string () + ",";
                switch (_history.peek_nth (j).result_source) {
                    case EvaluationResult.ResultSource.SCIF:
                    csv_data += "SCIF,";
                    break;
                    case EvaluationResult.ResultSource.CALC:
                    csv_data += "CALC,";
                    break;
                    case EvaluationResult.ResultSource.PROG:
                    csv_data += "PROG,";
                    break;
                }
                for (int i = 0; i < _history.peek_nth (j).prog_output.length; i++) {
                    csv_data += (_history.peek_nth (j).prog_output[i]) ? "1" : "0";
                }
                csv_data += ",";
                switch (_history.peek_nth (j).word_length) {
                    case GlobalWordLength.QWD:
                    csv_data += "QWD,";
                    break;
                    case GlobalWordLength.DWD:
                    csv_data += "DWD,";
                    break;
                    case GlobalWordLength.WRD:
                    csv_data += "WRD,";
                    break;
                    case GlobalWordLength.BYT:
                    csv_data += "BYT,";
                    break;
                }
                switch (_history.peek_nth (j).number_system) {
                    case NumberSystem.BINARY:
                    csv_data += "BINARY";
                    break;
                    case NumberSystem.OCTAL:
                    csv_data += "OCTAL";
                    break;
                    case NumberSystem.DECIMAL:
                    csv_data += "DECIMAL";
                    break;
                    case NumberSystem.HEXADECIMAL:
                    csv_data += "HEXADECIMAL";
                    break;
                }
                csv_data += "\n";
            }
            return csv_data;
        }

        public void load_from_csv (string csv_data) {
            //_history = new List<EvaluationResult>();
            string[] lines = csv_data.split ("\n");
            debug ("Found " + lines.length.to_string () + "entries in memory");
            foreach (string line in lines) {
                if (line != "") {
                    string[] item = line.split (",");
                    GlobalAngleUnit angle_mode = GlobalAngleUnit.DEG;
                    switch (item[2]) {
                        case "DEG":
                        angle_mode = GlobalAngleUnit.DEG;
                        break;
                        case "RAD":
                        angle_mode = GlobalAngleUnit.RAD;
                        break;
                        case "GRAD":
                        angle_mode = GlobalAngleUnit.GRAD;
                        break;
                    }
                    EvaluationResult.CalculusResultMode calc_mode = EvaluationResult.CalculusResultMode.NONE;
                    switch (item[3]) {
                        case "INT":
                        calc_mode = EvaluationResult.CalculusResultMode.INT;
                        break;
                        case "DER":
                        calc_mode = EvaluationResult.CalculusResultMode.DER;
                        break;
                        case "NONE":
                        calc_mode = EvaluationResult.CalculusResultMode.NONE;
                        break;
                    }
                    EvaluationResult.ResultSource result_source = EvaluationResult.ResultSource.SCIF;
                    switch (item[7]) {
                        case "SCIF":
                        result_source = EvaluationResult.ResultSource.SCIF;
                        break;
                        case "CALC":
                        result_source = EvaluationResult.ResultSource.CALC;
                        break;
                        case "PROG":
                        result_source = EvaluationResult.ResultSource.PROG;
                        break;
                    }
                    string output_string = item[8];
                    bool[] output = new bool[output_string.length];
                    for (int i = 0; i < output_string.length; i++) {
                        output[i] = (output_string.get_char(i) == '1');
                    }
                    GlobalWordLength output_word_length = GlobalWordLength.BYT;
                    switch (item[9]) {
                        case "QWD":
                        output_word_length = GlobalWordLength.QWD;
                        break;
                        case "DWD":
                        output_word_length = GlobalWordLength.DWD;
                        break;
                        case "WRD":
                        output_word_length = GlobalWordLength.WRD;
                        break;
                        case "BYT":
                        output_word_length = GlobalWordLength.BYT;
                        break;
                    }
                    NumberSystem number_system = NumberSystem.DECIMAL;
                    switch (item[10]) {
                        case "BINARY":
                        number_system = NumberSystem.BINARY;
                        break;
                        case "OCTAL":
                        number_system = NumberSystem.OCTAL;
                        break;
                        case "DECIMAL":
                        number_system = NumberSystem.DECIMAL;
                        break;
                        case "HEXADECIMAL":
                        number_system = NumberSystem.HEXADECIMAL;
                        break;
                    }
                    _history.push_tail (new EvaluationResult(item[0],
                                                    item[1], 
                                                    angle_mode, 
                                                    calc_mode, 
                                                    double.parse(item[4]),
                                                    double.parse(item[5]),
                                                    double.parse(item[6]),
                                                    result_source,
                                                    null,
                                                    output,
                                                    output_word_length,
                                                    number_system));
                }
            }
        }

        public void clear_history () {
            _history.clear ();
            history_updated ();
        }
    }
}
