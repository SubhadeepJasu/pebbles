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

        public signal Gdk.Pixbuf on_visualize (double[] data, double width, double height);

        construct {
            realize.connect (() => {
                var window = get_ancestor (typeof (MainWindow)) as MainWindow;
                on_visualize.connect ((data, width, height) => {
                    print ("Drawing. Vala.\n");
                    return window.on_stat_plot (data, width, height);
                });
            });
        }

        [GtkCallback]
        protected void add_cell () {
            display.insert_cell (null);
        }

        [GtkCallback]
        protected void confirm_data () {
            double width;
            double height;
            var data = display.confirm_data (out width, out height);
            var pixbuf = on_visualize (data, width, height);
            display.plot_visualization (pixbuf);
        }
    }
}
