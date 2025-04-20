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

        [GtkCallback]
        protected void on_expand_fx () {

        }

        [GtkCallback]
        protected void on_click_button () {

        }

        [GtkCallback]
        protected void on_click_function () {

        }
    }
}
