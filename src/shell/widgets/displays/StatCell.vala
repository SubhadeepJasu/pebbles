namespace Pebbles {
    public class StatCell: Gtk.Entry {
        public uint index { get; set construct; }
        public uint series_index { get; set construct; }
        public double value { get; private set; }

        public signal void data_changed (double value, uint index, uint series_index);
        public signal void focus_in (StatCell cell);

        private Gtk.EventControllerFocus focus_controller;
        private unowned MainWindow window;
        private bool block_change_signal = false;

        public StatCell (uint index, uint series_index) {
            Object (
                input_purpose: Gtk.InputPurpose.NUMBER,
                hexpand: false,
                halign: Gtk.Align.START
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

            focus_controller.enter.connect (() => {
                focus_in (this);
            });

            //  focus_controller.leave.connect (() => {
            //      double _value;
            //      var parsed = double.try_parse (text, out _value);
            //      if (parsed && value != _value) {
            //          value = _value;
            //          //  var max_cols = window.on_stat_cell_update (_value, (int) index, (int) series_index);
            //          data_changed (_value, index, series_index);
            //      }
            //  });

            changed.connect (() => {
                double _value;
                var parsed = double.try_parse (text, out _value);
                if (parsed && value != _value) {
                    value = _value;
                    //  var max_cols = window.on_stat_cell_update (_value, (int) index, (int) series_index);
                    if (!block_change_signal) {
                        data_changed (_value, index, series_index);
                    }
                }
            });
        }

        public void refresh () {
            if (window != null) {
                block_change_signal = true;
                text = window.on_stat_cell_query ((int) index, (int) series_index);
                block_change_signal = false;
            }
        }
    }
}
