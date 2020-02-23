/*-
 * Copyright (c) 2017-2019 Subhadeep Jasu <subhajasu@gmail.com>
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
    public class EvaluationResult {
        private string _problem_expression;
        private string _result;
        private GlobalAngleUnit _angle_mode;
        private CalculusResultMode _calc_mode;
        private double _int_limit_a;
        private double _int_limit_b;
        private double _derivative_point;

        public enum CalculusResultMode {
            INT,
            DER
        }

        public string problem_expression {
            get {
                return _problem_expression;
            }
            set {
                _problem_expression = value;
            }
        }

        public string result {
            get {
                return _result;
            }
            set {
                _result = value;
            }
        }

        public GlobalAngleUnit angle_mode {
            get {
                return _angle_mode;
            }
            set {
                _angle_mode = value;
            }
        }

        public CalculusResultMode calc_mode {
            get {
                return _calc_mode;
            }
            set {
                _calc_mode = value;
            }
        }

        public double int_limit_a {
            get {
                return _int_limit_a;
            }
            set {
                _int_limit_a = value;
            }
        }

        public double int_limit_b {
            get {
                return _int_limit_b;
            }
            set {
                _int_limit_b = value;
            }
        }

        public double derivative_point {
            get {
                return _derivative_point;
            }
            set {
                _derivative_point = value;
            }
        }

        public EvaluationResult (string problem_expression, string result, GlobalAngleUnit? angle_mode = null, CalculusResultMode? calc_mode = null, double? int_limit_a = null, double? int_limit_b = null, double? derivative_point = null) {
            this._problem_expression = problem_expression;
            this._result = result;

            if (angle_mode != null) {
                this._angle_mode = angle_mode;
            }

            if (calc_mode != null) {
                this._calc_mode = calc_mode;
            }

            if (int_limit_a != null) {
                this._int_limit_a = int_limit_a;
            }

            if (int_limit_b != null) {
                this._int_limit_b = int_limit_b;
            }

            if (derivative_point != null) {
                this._derivative_point = derivative_point;
            }
        }
    }
}