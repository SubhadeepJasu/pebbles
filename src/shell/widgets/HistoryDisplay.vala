namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/history_display.ui")]
    public class HistoryDisplay : Gtk.Box {
        public string mode { get; construct; }
        public unowned Gtk.ScrolledWindow viewport { get; construct; }

        [GtkChild]
        private unowned Gtk.ListBox list;
        private bool init = false;

        public signal void on_copy_result (uint index, HistoryViewModel data);
        public signal void on_insert_result (uint index, HistoryViewModel data);
        public signal void on_recall (uint index, HistoryViewModel data);

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
                                    list.append (new HistoryDisplayItem ((uint) i, this, history[i]));
                                }
                            }

                            Timeout.add (50, () => {
                                Idle.add (() => {
                                    if (viewport != null) {
                                        var v_adjustment = viewport.get_vadjustment ();
                                        v_adjustment.value = v_adjustment.upper - v_adjustment.page_size;

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

        public void copy_result (uint index, HistoryViewModel data) {
            on_copy_result (index, data);
            var clip_board = get_clipboard ();
            clip_board.set_text (data.output);
        }

        public void insert_result (uint index, HistoryViewModel data) {
            on_insert_result (index, data);
        }

        public void recall (uint index, HistoryViewModel data) {
            on_recall (index, data);
        }
    }

    private class HistoryDisplayItem : Gtk.ListBoxRow {
        private Gtk.GestureClick click_gesture;
        public uint index { get; private set; }
        public unowned HistoryDisplay history_display;
        public unowned HistoryViewModel model;

        public HistoryDisplayItem (uint index, HistoryDisplay history_display, HistoryViewModel model) {
            Object (
                hexpand: true
            );

            this.index = index;
            this.history_display = history_display;
            this.model = model;

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

            click_gesture = new Gtk.GestureClick ();
            click_gesture.set_button (Gdk.BUTTON_SECONDARY);
            click_gesture.pressed.connect ((n_press, x, y) => {
                show_context_menu (x, y);
            });
            click_gesture.propagation_phase = CAPTURE;
            add_controller (click_gesture);
        }

        public void pop_up () {
            add_css_class ("pop-up");
            Timeout.add (500, () => {
                remove_css_class ("pop-up");
                return false;
            });
        }

        private void show_context_menu (double x, double y) {
            var popover = new Gtk.Popover ();
            popover.set_has_arrow (false);
            popover.set_pointing_to (Gdk.Rectangle () { x = (int) x, y = (int) y, height = 1, width = 1});
            popover.set_parent (this);

            var box = new Gtk.Box (HORIZONTAL, 0) {
                width_request = 100,
                homogeneous = true
            };
            popover.set_child (box);
            var copy_result_item = new Gtk.Button.from_icon_name ("edit-copy-symbolic") {
                tooltip_text = _("Copy Result"),
                can_focus = false
            };
            box.append (copy_result_item);

            var insert_result_item = new Gtk.Button.from_icon_name ("insert-text-symbolic") {
                tooltip_text = _("Insert Result"),
                can_focus = false
            };
            box.append (insert_result_item);

            var recall_item = new Gtk.Button.from_icon_name ("document-open-recent-symbolic") {
                tooltip_text = _("Recall"),
                can_focus = false
            };
            box.append (recall_item);

            popover.popup ();

            copy_result_item.clicked.connect (() => {
                history_display.copy_result (index, model);
                popover.hide ();
            });

            insert_result_item.clicked.connect (() => {
                history_display.insert_result (index, model);
                popover.hide ();
            });

            recall_item.clicked.connect (() => {
                history_display.recall (index, model);
                popover.hide ();
            });
        }
    }
}
