namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/programmer_view.ui")]
    public class ProgrammerView : View {
        private bool _collapsed;
        public bool collapsed {
            get {
                return _collapsed;
            }

            set construct {
                _collapsed = value;
            }
        }

        [GtkChild]
        private unowned Gtk.Stack programmer_stack;
        [GtkChild]
        private unowned Adw.NavigationSplitView prog_nav_split_view;
        [GtkChild]
        private unowned BitGrid bit_grid;

        [GtkCallback]
        protected void on_expand_fx () {

        }

        [GtkCallback]
        protected void on_click_button () {

        }

        [GtkCallback]
        protected void on_click_function () {

        }

        public void open_bit_grid () {
            programmer_stack.set_visible_child (bit_grid);
        }

        [GtkCallback]
        public void on_hide_bit_grid () {
            programmer_stack.set_visible_child (prog_nav_split_view);

            var window = (MainWindow) get_ancestor (typeof (MainWindow));
            if (window.bit_grid_toggle.active) {
                window.bit_grid_toggle.active = false;
            }
        }
    }
}
