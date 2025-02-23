namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/statistics_view.ui")]
    public class StatisticsView : Gtk.Grid {
        [GtkChild]
        private unowned StatisticsDisplay display;

        private bool _collapsed;
        public bool collapsed {
            get {
                return _collapsed;
            }

            set construct {
                _collapsed = value;
                show_hide_fx_btn = !value;
            }
        }

        protected bool show_hide_fx_btn { get; set; }

        protected List<List<string>> table;

        public signal void on_evaluate (string op, double[] series, int series_index, double width, double height);

        construct {
            display.changed.connect ((series, series_index, width, height) => {
                on_evaluate ("set", series, series_index, width, height);
            });
        }

        public void plot () {
            display.plot ();
        }

        [GtkCallback]
        protected void add_cell () {
            display.insert_cell (null);
        }

        [GtkCallback]
        protected void switch_plot () {
            display.switch_plot ();
        }
    }
}
