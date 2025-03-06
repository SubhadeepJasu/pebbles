namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/graphing_view.ui")]
    public class GraphingView : View {
        [GtkChild]
        private unowned Gtk.Stack graphing_stack;
        [GtkChild]
        private unowned Gtk.Box equation_panel;
        [GtkChild]
        private unowned Gtk.Box graphing_panel;

        public bool collapsed { get; set; }

        public void render_graph (bool active) {
            graphing_stack.set_visible_child (active ? graphing_panel : equation_panel);
        }
    }
}
