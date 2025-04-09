namespace Pebbles {
    public class EquationModel : Object {
        public string expression { get; construct; }
        public uint index { get; construct; }
        public bool radial_coord_mode { get; construct; }

        public EquationModel (uint index, string? expression, bool radial_coord_mode) {
            Object (
                index: index,
                expression: expression,
                radial_coord_mode: radial_coord_mode
            );
        }

        public string to_string () {
            return index.to_string () + ": " + (radial_coord_mode ? "r" : "y") + " = " + expression;
        }
    }
}
