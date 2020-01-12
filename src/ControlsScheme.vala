namespace Pebbles { 
    public class ControlScheme {
        public string[,] common;
        public string[,] scientific;
        public string[,] statistics;

        public ControlScheme () {
            common = {
                {
                    "Show this controls window", "F1"
                },
                {
                    "Add to Memory", "F2"
                },
                {
                    "Subtract from Memory", "F3"
                },
                {
                    "Recall from Memory", "F4"
                },
                {
                    "Clear Memory", "F5"
                },
                {
                    "Last Answer", "F6"
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
        }
    }
}