namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/graphing_view.ui")]
    public class GraphingView : View {
        [GtkChild]
        private unowned Gtk.Stack graphing_stack;
        [GtkChild]
        private unowned Gtk.Box equation_panel;
        [GtkChild]
        private unowned Gtk.Box graphing_panel;

        protected string constant_label { get; private set; default = "C"; }
        protected string constant_desc { get; private set; default = ""; }

        public bool collapsed { get; set; }

        public signal void panel_changed (bool showing_graphs);

        [GtkCallback]
        public void show_graph_panel () {
            if (graphing_stack.visible_child != graphing_panel) {
                graphing_stack.visible_child = graphing_panel;
                panel_changed (true);
            }
        }

        //  [GtkCallback]
        public void show_equation_panel () {
            if (graphing_stack.visible_child != equation_panel) {
                graphing_stack.visible_child = equation_panel;
                panel_changed (false);
            }
        }
    }
}
