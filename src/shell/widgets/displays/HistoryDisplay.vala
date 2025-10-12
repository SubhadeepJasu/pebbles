namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/history_display.ui")]
    public class HistoryDisplay : Gtk.Box {
        public string context { get; set; }
        public unowned Gtk.ScrolledWindow viewport { get; construct; }

        [GtkChild]
        private unowned Gtk.ListBox list;

        public signal void inserted (string text);
        public signal void recalled (HistoryModel history);

        construct {
            realize.connect (() => {
                Timeout.add_once (100, () => {
                    var win = (MainWindow) get_ancestor (typeof (MainWindow));
                    print ("DEBUG: Refreshing history of %s\n", context);
                    win.on_history_view (context);
                });
            });
        }

        public HistoryDisplay (string context) {
            Object (
                context: context
            );
        }

        public void update_list (HistoryModel[] history) {
            list.remove_all ();
            foreach (var item in history) {
                list.append (new HistoryDisplayItem (this, item));
            }

            Timeout.add (50, () => {
                Idle.add (() => {
                    if (viewport != null) {
                        var v_adjustment = viewport.get_vadjustment ();
                        v_adjustment.value = v_adjustment.upper - v_adjustment.page_size;

                        var h_adjustment = viewport.get_hadjustment ();
                        h_adjustment.value = h_adjustment.upper - h_adjustment.page_size;
                    }

                    return Source.REMOVE;
                });

                return Source.REMOVE;
            });
        }

        public void copy_result (int item_id) {
            var window = get_ancestor (typeof (MainWindow)) as MainWindow;
            if (window != null) {
                var raw_data = window.on_history_copy (item_id);
                var clip_board = get_clipboard ();
                clip_board.set_text (raw_data);
                window.send_toast (_("Answer copied to clipboard"));
            }
        }

        public void insert_result (int item_id) {
            var window = get_ancestor (typeof (MainWindow)) as MainWindow;
            if (window != null) {
                var formatted_data = window.on_history_insert (item_id);
                inserted (formatted_data);
            }
        }

        public void recall (int item_id) {
            var window = get_ancestor (typeof (MainWindow)) as MainWindow;
            if (window != null) {
                var snapshot = window.on_history_recall (item_id);
                recalled (snapshot);
            }
        }
    }

    private class HistoryDisplayItem : Gtk.ListBoxRow {
        public unowned HistoryDisplay history_display;
        public HistoryModel model;

        private Gtk.GestureClick right_click_gesture;
        private Gtk.GestureClick middle_click_gesture;

        public HistoryDisplayItem (HistoryDisplay history_display, HistoryModel model) {
            Object (
                hexpand: true
            );

            this.history_display = history_display;
            this.model = model;

            var box = new Gtk.Box (VERTICAL, 2);
            set_child (box);

            var input_label = new Gtk.Label (model.input) {
                halign = END
            };
            input_label.add_css_class ("history-input");
            box.append (input_label);

            var output_label = new Gtk.Label ("= " + model.result) {
                halign = END
            };
            output_label.add_css_class ("history-output");
            box.append (output_label);

            right_click_gesture = new Gtk.GestureClick ();
            right_click_gesture.set_button (Gdk.BUTTON_SECONDARY);
            right_click_gesture.pressed.connect ((n_press, x, y) => {
                show_context_menu (x, y);
            });
            add_controller (right_click_gesture);

            middle_click_gesture = new Gtk.GestureClick ();
            middle_click_gesture.set_button (Gdk.BUTTON_MIDDLE);
            middle_click_gesture.pressed.connect (() => {
                history_display.copy_result (model.id);
            });
            add_controller (middle_click_gesture);

            activate.connect (() => {
                history_display.recall (model.id);
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
                history_display.copy_result (model.id);
                popover.hide ();
            });

            insert_result_item.clicked.connect (() => {
                history_display.insert_result (model.id);
                popover.hide ();
            });

            recall_item.clicked.connect (() => {
                history_display.recall ( model.id);
                popover.hide ();
            });
        }
    }
}
