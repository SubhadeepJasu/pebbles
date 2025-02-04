/*
 * Copyright 2019-2025 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Pebbles {
    public class ControlScheme {
        public string[,] common;
        public string[,] scientific;
        public string[,] programmer;
        public string[,] statistics;
        public string[,] calculus;
        public string[,] converter;

        public ControlScheme () {
            common = {
                {
                    _("Show this controls window"), "F1"
                },
                {
                    _("Show Preferences"), "F2"
                },
                {
                    _("Add to Memory"), "F3"
                },
                {
                    _("Subtract from Memory"), "F4"
                },
                {
                    _("Recall from Memory"), "F5"
                },
                {
                    _("Clear Memory"), "F6"
                },
                {
                    _("Last Answer"), "F7"
                },
                {
                    _("Close Dialog"), "Escape"
                },
                {
                    _("All Clear"), "Delete"
                },
                {
                    _("Copy Result"), "<Ctrl>C"
                },
                {
                    _("Paste Input Expression"), "<Ctrl>V"
                }
            };
            scientific = {
                {
                    _("Square (root) a Number"), "Q"
                },
                {
                    _("Raise to the power (or nth root over)"), "Z"
                },
                {
                    _("10 (or e) raised to the power"), "W"
                },
                {
                    _("Log base 10 (or e)"), "L"
                },
                {
                    _("(Inverse) Sine"), "S"
                },
                {
                    _("(Inverse) Cosine"), "C"
                },
                {
                    _("(Inverse) Tangent"), "T"
                },
                {
                    _("(Inverse) Hyperbolic Sine"), "H"
                },
                {
                    _("(Inverse) Hyperbolic Cosine"), "O"
                },
                {
                    _("(Inverse) Hyperbolic Tangent"), "A"
                },
                {
                    _("Modulus or Log base x"), "M"
                },
                {
                    _("Permutation or Combination"), "P"
                },
                {
                    _("Factorial"), "F"
                },
                {
                    _("Constants"), "R"
                },
                {
                    _("Result"), "Return"
                }
            };
            programmer = {
                {
                    _("Logical OR or NOR"), "O"
                },
                {
                    _("Logical AND or NAND"), "N"
                },
                {
                    _("Logical XOR or XNOR"), "X"
                },
                {
                    _("Logical NOT or Mod"), "T"
                },
                {
                    _("Result"), "Return"
                }
            };
            statistics = {
                {
                    _("Add Cell"), "Page_Up"
                },
                {
                    _("Insert Cell"), "Page_Down"
                },
                {
                    _("Next Cell or Add Right"), "Tab"
                },
                {
                    _("Previous Cell or Add Left"), "<Shift>Tab"
                },
                {
                    _("Navigate Left"), "Left"
                },
                {
                    _("Navigate Right"), "Right"
                },
                {
                    _("Remove Cell"), "Home"
                },
                {
                    _("Remove All Cells (Reset)"), "End"
                },
                {
                    _("Cardinality"), "N"
                },
                {
                    _("Mode"), "O"
                },
                {
                    _("Median"), "E"
                },
                {
                    _("Summation"), "S"
                },
                {
                    _("Summation Squared"), "Q"
                },
                {
                    _("Sample Variance"), "V"
                },
                {
                    _("Mean"), "M"
                },
                {
                    _("Mean Squared"), "A"
                },
                {
                    _("Geometric Mean"), "G"
                },
                {
                    _("Sample Standard Deviation"), "D"
                },
                {
                    _("Population Variance"), "P"
                },
                {
                    _("Population Standard Deviation"), "L"
                }
            };
            calculus = {
                {
                    _("Variable x"), "X"
                },
                {
                    _("Definite Integral"), "I"
                },
                {
                    _("Derivative at a point"), "D"
                }
            };
            converter = {
                {
                    _("Interchange unit"), "Return"
                },
                {
                    _("Update Forex Data (Currency converter)"), "R"
                }
            };
        }
    }
}
