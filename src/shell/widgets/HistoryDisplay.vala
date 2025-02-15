namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/history_display.ui")]
    public class HistoryDisplay : Gtk.Box {
        public string mode { get; construct; }
        public unowned Gtk.ScrolledWindow viewport { get; construct; }

        [GtkChild]
        private unowned Gtk.ListBox list;

        private bool init = false;
        construct {
            realize.connect (() => {
                if (!init) {
                    init = true;
                    var win = get_ancestor (typeof (MainWindow)) as MainWindow;
                    win.history_changed.connect ((history) => {
                        Idle.add (() => {
                            list.remove_all ();
                            for (int i = history.length - 1; i > 0; i--) {
                                if (history[i].mode == mode) {
                                    list.append (new HistoryDisplayItem (history[i]));
                                }
                            }

                            Timeout.add (50, () => {
                                Idle.add (() => {
                                    if (viewport != null) {
                                        var v_adjustment = viewport.get_vadjustment ();
                                        v_adjustment.value = v_adjustment.upper;

                                        ((HistoryDisplayItem) list.get_last_child ()).pop_up ();
                                    }

                                    return false;
                                });

                                return false;
                            });

                            return false;
                        });
                    });
                }
            });
        }

        public HistoryDisplay (string mode) {
            Object (
                mode: mode
            );
        }
    }

    private class HistoryDisplayItem : Gtk.ListBoxRow {
        public HistoryDisplayItem (HistoryViewModel model) {
            Object (
                hexpand: true
            );

            var box = new Gtk.Box (VERTICAL, 2);
            set_child (box);

            var input_label = new Gtk.Label (model.input) {
                halign = END
            };
            input_label.add_css_class ("history-input");
            box.append (input_label);

            var output_label = new Gtk.Label ("= " + model.output) {
                halign = END
            };
            output_label.add_css_class ("history-output");
            box.append (output_label);
        }

        public void pop_up () {
            add_css_class ("pop-up");
            Timeout.add (500, () => {
                remove_css_class ("pop-up");
                return false;
            });
        }
    }
}
