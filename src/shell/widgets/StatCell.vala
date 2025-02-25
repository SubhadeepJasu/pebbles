namespace Pebbles {
    public class StatCell: Gtk.Entry {
        public uint index { get; set construct; }
        public uint series_index { get; set construct; }

        public signal void data_changed (double value, uint index, uint series_index);

        private Gtk.EventControllerFocus focus_controller;
        private unowned MainWindow window;

        public StatCell (uint index, uint series_index) {
            Object (
                input_purpose: Gtk.InputPurpose.NUMBER
            );

            this.index = index;
            this.series_index = series_index;
        }

        construct {
            focus_controller = new Gtk.EventControllerFocus ();
            add_controller (focus_controller);

            add_css_class ("data-table-cell");
            has_frame = false;

            realize.connect (()=> {
                window = (MainWindow) get_ancestor (typeof (MainWindow));
            });

            focus_controller.leave.connect (() => {
                double _value;
                var parsed = double.try_parse (text, out _value);
                if (parsed) {
                    window.on_stat_cell_update (_value, (int) index, (int) series_index);
                }
            });
        }

        public void refresh () {
            if (window != null) {
                text = window.on_stat_cell_query ((int) index, (int) series_index);
            }
        }
    }
}
