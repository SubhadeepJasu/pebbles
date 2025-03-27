namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/graph_viewport.ui")]
    public class GraphViewport : Gtk.Box {
        [GtkChild]
        private unowned Gtk.DrawingArea renderer;
        public int x_min { get; private set; }
        public int x_max { get; private set; }
        public int y_min { get; private set; }
        public int y_max { get; private set; }
        public GraphAxisScaling x_scaling_mode = LINEAR;
        public GraphAxisScaling y_scaling_mode = LINEAR;

        construct {
            x_min = 0;
            y_min = 0;
            x_max = 10;
            y_max = 10;
        }

        public void render (EquationModel[]? equations = null, GlobalAngleUnit angle_unit = DEG) {
            var window = (MainWindow) get_ancestor (typeof (MainWindow));

            var display = window.get_display ();
            var monitor = display.get_monitor_at_surface (window.get_surface ());

            var payload = new GraphPayloadModel () {
                equations = equations,
                angle_unit = angle_unit,
                x_min = this.x_min,
                x_max = this.x_max,
                y_min = this.y_min,
                y_max = this.y_max,
                x_scaling = x_scaling_mode,
                y_scaling = y_scaling_mode,
                width = renderer.get_width (),
                height = renderer.get_height (),
                dpi = monitor.get_geometry ().width / (monitor.get_width_mm () / 25.4),
                dark_mode = Gtk.Settings.get_default ().gtk_application_prefer_dark_theme
            };

            window.on_render_graph (payload);
        }
    }
}
