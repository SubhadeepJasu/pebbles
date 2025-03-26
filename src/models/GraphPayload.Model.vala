namespace Pebbles {
    public class GraphPayloadModel : Object {
        public EquationModel[] equations { get; set; }
        public int x_min { get; set; }
        public int x_max { get; set; }
        public double scale { get; set; }
        public GraphAxisScaling x_scaling { get; set; }
        public GraphAxisScaling y_scaling { get; set; }
        public int width { get; set; }
        public int height { get; set; }
        public double dpi { get; set; }
    }
}
