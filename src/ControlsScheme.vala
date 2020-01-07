namespace Pebbles { 
    public class ControlScheme {
        public string[,] common;
        public string[,] statistics;

        public ControlScheme () {
            common = {
                {
                    "All Clear", "Delete"
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
                }
            };
            statistics = {
                {
                    "Add Cell", "PageUp"
                },
                {
                    "Insert Cell", "PageDown"
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