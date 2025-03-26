namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/graph_viewport.ui")]
    public class GraphViewport : Gtk.Box {
        [GtkChild]
        private unowned Gtk.DrawingArea renderer;
        unowned EquationModel[] equations;
        public int x_min { get; set; }
        public int x_max { get; set; }
        public double scale { get; set; }
        public GraphAxisScaling x_scaling_mode = LINEAR;
        public GraphAxisScaling y_scaling_mode = LINEAR;

        public void render (EquationModel[]? equations = null) {
            if (equations != null) {
                this.equations = equations;
            }

            var window = (MainWindow) get_ancestor (typeof (MainWindow));

            var display = window.get_display ();
            var monitor = display.get_monitor_at_surface (window.get_surface ());
            double width_mm = monitor.get_width_mm ();
            int width_px = monitor.get_geometry ().width;

            var payload = new GraphPayloadModel () {
                equations = this.equations,
                x_min = this.x_min,
                x_max = this.x_min,
                scale = this.scale,
                x_scaling = x_scaling_mode,
                y_scaling = y_scaling_mode,
                width = renderer.get_width (),
                height = renderer.get_height (),
                dpi = width_px / (width_mm / 25.4)
            };

            window.on_render_graph (payload);
        }
    }
}
