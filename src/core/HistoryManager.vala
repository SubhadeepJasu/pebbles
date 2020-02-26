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
         private List<EvaluationResult> _history;

         public void append_from_strings (string problem_expression, 
                                        string result, 
                                        GlobalAngleUnit? angle_mode = null,
                                        EvaluationResult.CalculusResultMode? calc_mode = null, 
                                        double? int_limit_a = null, 
                                        double? int_limit_b = null, 
                                        double? derivative_point = null,
                                        EvaluationResult.ResultSource? result_source = null) {
            _history.append (new EvaluationResult(problem_expression,
                                                result, 
                                                angle_mode, 
                                                calc_mode, 
                                                int_limit_a,
                                                int_limit_b,
                                                derivative_point,
                                                result_source));
        }

        public void append_from_evaluation_result (EvaluationResult eval_res) {
            _history.append (eval_res);
        }

        public EvaluationResult get_nth_evaluation_result (uint n) {
            return _history.nth_data(n);
        }

        public EvaluationResult get_last_evaluation_result () {
            unowned List<EvaluationResult> last = _history.last ();
            return last.nth_data (0);
        }

        public uint length () {
            return _history.length ();
        }

        public bool is_empty () {
            return (_history.length () == 0) ? true : false;
        }
    }
}