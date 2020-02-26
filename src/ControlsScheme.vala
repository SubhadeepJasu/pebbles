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
 */

namespace Pebbles { 
    public class ControlScheme {
        public string[,] common;
        public string[,] scientific;
        public string[,] statistics;
        public string[,] calculus;
        public string[,] converter;

        public ControlScheme () {
            common = {
                {
                    "Show this controls window", "F1"
                },
                {
                    "Show Preferences", "F2"
                },
                {
                    "Add to Memory", "F3"
                },
                {
                    "Subtract from Memory", "F4"
                },
                {
                    "Recall from Memory", "F5"
                },
                {
                    "Clear Memory", "F6"
                },
                {
                    "Last Answer", "F7"
                },
                {
                    "All Clear", "Delete"
                }
            };
            scientific = {
                {
                    "Square (root) a Number", "Q"
                },
                {
                    "Raise to the power (or nth root over)", "Z"
                },
                {
                    "10 (or e) raised to the power", "W"
                },
                {
                    "Log base 10 (or e)", "L"
                },
                {
                    "(Inverse) Sine", "S"
                },
                {
                    "(Inverse) Cosine", "C"
                },
                {
                    "(Inverse) Tangent", "T"
                },
                {
                    "(Inverse) Hyperbolic Sine", "H"
                },
                {
                    "(Inverse) Hyperbolic Cosine", "O"
                },
                {
                    "(Inverse) Hyperbolic Tangent", "A"
                },
                {
                    "Modulus or Log base x", "M"
                },
                {
                    "Permutation or Combination", "P"
                },
                {
                    "Factorial", "F"
                },
                {
                    "Constants", "R"
                },
                {
                    "Result", "Return"
                }
            };
            statistics = {
                {
                    "Add Cell", "Page_Up"
                },
                {
                    "Insert Cell", "Page_Down"
                },
                {
                    "Next Cell or Add Right", "Tab"
                },
                {
                    "Previous Cell or Add Left", "<Shift>Tab"
                },
                {
                    "Navigate Left", "Left"
                },
                {
                    "Navigate Right", "Right"
                },
                {
                    "Remove Cell", "Home"
                },
                {
                    "Remove All Cells (Reset)", "End"
                },
                {
                    "Cardinality", "N"
                },
                {
                    "Mode", "O"
                },
                {
                    "Median", "E"
                },
                {
                    "Summation", "S"
                },
                {
                    "Summation Squared", "Q"
                },
                {
                    "Sample Variance", "V"
                },
                {
                    "Mean", "M"
                },
                {
                    "Mean Squared", "A"
                },
                {
                    "Geometric Mean", "G"
                },
                {
                    "Sample Standard Deviation", "D"
                },
                {
                    "Population Variance", "P"
                },
                {
                    "Population Standard Deviation", "L"
                }
            };
            calculus = {
                {
                    "Variable x", "X"
                },
                {
                    "Definite Integral", "I"
                },
                {
                    "Derivative at a point", "D"
                }
            };
            converter = {
                {
                    "Interchange unit", "Return"
                },
                {
                    "Update Forex Data (Currency converter)", "R"
                }
            };
        }
    }
}