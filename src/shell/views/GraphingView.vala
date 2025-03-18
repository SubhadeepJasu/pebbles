namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/graphing_view.ui")]
    public class GraphingView : View {
        [GtkChild]
        private unowned Gtk.Stack graphing_stack;
        [GtkChild]
        private unowned Gtk.Box equation_panel;
        [GtkChild]
        private unowned Gtk.Overlay graphing_panel;
        [GtkChild]
        private unowned EquationDisplay display;

        [GtkChild]
        private unowned Pebbles.Button variable_button;

        protected string constant_label { get; private set; default = "C"; }
        protected string constant_desc { get; private set; default = ""; }

        public bool collapsed { get; set; }

        public signal void panel_changed (bool showing_graphs);

        [GtkCallback]
        public void change_mode_handler (bool radial_mode) {
            if (radial_mode) {
                variable_button.label_text = "θ";
                variable_button.tooltip_desc = "Variable θ";
            } else {
                variable_button.label_text = "<i>X</i>";
                variable_button.tooltip_desc = "Variable x";
            }
        }

        [GtkCallback]
        public void show_graph_panel () {
            if (graphing_stack.visible_child != graphing_panel) {
                graphing_stack.visible_child = graphing_panel;
                panel_changed (true);
            }
        }

        [GtkCallback]
        public void show_equation_panel () {
            if (graphing_stack.visible_child != equation_panel) {
                graphing_stack.visible_child = equation_panel;
                panel_changed (false);
            }
        }

        [GtkCallback]
        protected void add_equation () {
            display.add_equation ();
        }
    }
}
