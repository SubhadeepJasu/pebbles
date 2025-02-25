// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/main_window.ui")]
    public class MainWindow : Adw.ApplicationWindow {
        private ShortcutsDialog shortcuts_dialog;
        private PreferencesDialog preferences_dialog;
        [GtkChild]
        private unowned Adw.ToastOverlay toast_overlay;
        [GtkChild]
        private unowned Adw.NavigationSplitView split_view;

        [GtkChild]
        private unowned Adw.HeaderBar main_headerbar;
        [GtkChild]
        private unowned Gtk.Spinner spinner;
        [GtkChild]
        private unowned Button angle_mode;
        [GtkChild]
        private unowned Gtk.Box menu_box;
        [GtkChild]
        private unowned Gtk.CheckButton color_button_light;
        [GtkChild]
        private unowned Gtk.CheckButton color_button_dark;
        [GtkChild]
        private unowned Gtk.CheckButton color_button_system;

        [GtkChild]
        private unowned Gtk.Box navigation_pane;
        [GtkChild]
        private unowned Gtk.ListBox nav_list;
        [GtkChild]
        private unowned Gtk.Box main_view;
        [GtkChild]
        private unowned Adw.ViewStack view_stack;

        [GtkChild]
        private unowned ScientificView scientific_view;
        [GtkChild]
        private unowned StatisticsView statistics_view;

        [GtkChild]
        private unowned Gtk.Stack header_stack;
        [GtkChild]
        private unowned Gtk.Box scientific_header_box;
        [GtkChild]
        private unowned Gtk.Box statistics_header_box;
        [GtkChild]
        private unowned Gtk.Box null_header_box;

        private Gtk.EventControllerKey key_event_controller;

        private Pebbles.Settings settings;
        private HistoryViewModel[] history;

        protected signal void on_evaluate (string data);
        protected signal string on_memory_recall (string mode);
        protected signal void on_memory_clear (string mode);

        public signal void on_key_down (string? mode, uint keyval);
        public signal void on_key_up (string? mode, uint keyval);
        public signal void history_changed (HistoryViewModel[] history);
        public signal void on_stat_plot (double width, double height, StatPlotType plot_type, double dpi);
        public signal void on_stat_cell_update (double value, int index, int series_index);
        public signal string on_stat_cell_query (int index, int series_index);

        construct {
            navigation_pane.add_css_class (Granite.STYLE_CLASS_SIDEBAR);

            settings = Pebbles.Settings.get_default ();

            setup_theme ();
            setup_actions ();
            setup_evaluators ();
            setup_key_events ();
            setup_memory_events ();
            load_settings ();
        }

        private void setup_theme () {
            var gtk_settings = Gtk.Settings.get_default ();
            var granite_settings = Granite.Settings.get_default ();
            var pebbles_settings = Pebbles.Settings.get_default ();

            switch (pebbles_settings.theme) {
                case "dark":
                    gtk_settings.gtk_application_prefer_dark_theme = true;
                    color_button_dark.active = true;
                    break;
                case "light":
                    gtk_settings.gtk_application_prefer_dark_theme = false;
                    color_button_light.active = true;
                    break;
                default:
                    gtk_settings.gtk_application_prefer_dark_theme = (
                        granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
                    );
                    color_button_system.active = true;
                    break;
            }

            granite_settings.notify["prefers-color-scheme"].connect (() => {
                if (pebbles_settings.get_string ("theme") == "system") {
                    gtk_settings.gtk_application_prefer_dark_theme = (
                        granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
                    );
                }
            });
        }

        private void setup_actions () {
            nav_list.select_row (nav_list.get_row_at_index (0));
            var open_controls_action = new SimpleAction ("controls", null);
            open_controls_action.activate.connect (() => {
                shortcuts_dialog = new ShortcutsDialog ();
                shortcuts_dialog.present (this);
            });
            add_action (open_controls_action);

            var open_preferences_action = new SimpleAction ("preferences", null);
            open_preferences_action.activate.connect (() => {
                preferences_dialog = new PreferencesDialog ();
                preferences_dialog.present (this);
            });
            add_action (open_preferences_action);

            var enable_scientific_mode_action = new SimpleAction ("open_scientific_mode", null);
            enable_scientific_mode_action.activate.connect (() => {
                view_stack.set_visible_child_name ("sci");
                split_view.show_content = true;
                scientific_view.add_css_class ("animate");
                Timeout.add_once (600, () => {
                    scientific_view.remove_css_class ("animate");
                });
                header_stack.set_visible_child (scientific_header_box);
            });
            add_action (enable_scientific_mode_action);

            var enable_statistics_mode_action = new SimpleAction ("open_statistics_mode", null);
            enable_statistics_mode_action.activate.connect (() => {
                view_stack.set_visible_child_name ("stat");
                split_view.show_content = true;
                statistics_view.add_css_class ("animate");
                Timeout.add_once (600, () => {
                    statistics_view.remove_css_class ("animate");
                });
                header_stack.set_visible_child (statistics_header_box);
            });
            add_action (enable_statistics_mode_action);
        }

        private void setup_evaluators () {
            scientific_view.on_evaluate.connect ((input, memory_op) => {
                var gen = new Json.Generator ();
                var root = new Json.Node (Json.NodeType.OBJECT);
                var object = new Json.Object ();
                root.set_object (object);
                gen.set_root (root);

                object.set_string_member ("mode", "sci");
                object.set_string_member ("input", input);
                object.set_int_member ("angleMode", (int) Pebbles.Settings.get_default ().global_angle_unit);
                object.set_int_member ("memoryOp", memory_op);

                size_t length;
                string json = gen.to_data (out length);

                spinner.spinning = true;
                on_evaluate (json);
            });
            statistics_view.on_evaluate.connect ((op, options) => {
                var gen = new Json.Generator ();
                var root = new Json.Node (Json.NodeType.OBJECT);
                var object = new Json.Object ();
                root.set_object (object);
                gen.set_root (root);

                object.set_string_member ("mode", "stat");
                object.set_string_member ("op", op);
                object.set_object_member ("options", options);
                size_t length;
                string json = gen.to_data (out length);

                spinner.spinning = true;
                on_evaluate (json);
            });
        }

        private void setup_key_events () {
            key_event_controller = new Gtk.EventControllerKey ();
            key_event_controller.key_pressed.connect ((keyval, _, modifier) => {
                var shift_key = keyval == Gdk.Key.Shift_L || keyval == Gdk.Key.Shift_R;
                if (shift_key) {
                    set_shift_on (true);
                }

                if ((
                    modifier &
                    (
                        Gdk.ModifierType.CONTROL_MASK |
                        Gdk.ModifierType.ALT_MASK
                    )) != 0 || shift_key || (preferences_dialog != null && preferences_dialog.visible)) {
                    return false;
                }

                on_key_down (view_stack.visible_child_name, keyval);
                return false;
            });
            key_event_controller.key_released.connect ((keyval, _, modifier) => {
                var shift_key = keyval == Gdk.Key.Shift_L || keyval == Gdk.Key.Shift_R;
                if (shift_key) {
                    set_shift_on (false);
                }

                if ((
                    modifier &
                    (
                        Gdk.ModifierType.CONTROL_MASK |
                        Gdk.ModifierType.ALT_MASK
                    )) != 0 || shift_key || (preferences_dialog != null && preferences_dialog.visible)) {
                    return;
                }

                if (keyval == Gdk.Key.F8) {
                    on_change_mode ();
                    return;
                }

                on_key_up (view_stack.visible_child_name, keyval);
            });
            key_event_controller.set_propagation_phase (Gtk.PropagationPhase.CAPTURE);
            ((Gtk.Widget) this).add_controller (key_event_controller);
        }

        private void setup_memory_events () {
            scientific_view.on_memory_recall.connect ((global) => {
                return on_memory_recall (global ? "global" : "sci");
            });

            scientific_view.on_memory_clear.connect ((global) => {
                on_memory_clear (global ? "global" : "sci");
            });
        }

        private void load_settings () {
            switch (settings.global_angle_unit) {
                case DEG:
                    angle_mode.label_text = "DEG";
                    break;
                case RAD:
                    angle_mode.label_text = "RAD";
                    break;
                case GRAD:
                    angle_mode.label_text = "GRA";
                    break;
            }
        }

        protected void on_evaluation_completed (string data) {
            Idle.add (() => {
                spinner.spinning = false;
                var parser = new Json.Parser ();
                try {
                    parser.load_from_data (data, -1);

                    var root_object = parser.get_root ().get_object ();
                    var mode = root_object.get_string_member ("mode");
                    switch (mode) {
                        case "sci":
                            var result = root_object.get_string_member ("result");
                            scientific_view.show_result (result);
                            break;
                        default:
                        break;
                    }
                } catch (Error e) {
                    warning (e.message);
                }

                return false;
            });
        }

        protected void on_plot_ready (Gdk.Pixbuf figure) {
            statistics_view.plot (figure);
        }

        protected void on_memory_change (string context, bool present) {
            spinner.spinning = false;
            switch (context) {
                case "sci":
                    scientific_view.set_memory_present (present);
                    break;
                default:
                    scientific_view.set_global_memory_present (present);
                    break;
            }
        }

        protected void set_history (HistoryViewModel[] _history) {
            if (history == null) {
                history = new HistoryViewModel[_history.length];
            }

            history.resize (_history.length);

            for (int i = 0; i < _history.length; i++) {
                history[i] = _history[i];
            }

            history_changed (history);
        }

        private void set_shift_on (bool on) {
            scientific_view.send_shift_modifier (on);
        }

        [GtkCallback]
        protected void set_theme (Gtk.CheckButton button) {
            if (button.active) {
                settings.theme = button.name;
                setup_theme ();
            }
        }

        [GtkCallback]
        protected void on_change_mode () {
            switch (view_stack.visible_child_name) {
                case "sci":
                case "calc":
                case "graph":
                    switch (settings.global_angle_unit) {
                        case DEG:
                            settings.global_angle_unit = RAD;
                            angle_mode.label_text = "RAD";
                            break;
                        case RAD:
                            settings.global_angle_unit = GRAD;
                            angle_mode.label_text = "GRA";
                            break;
                        case GRAD:
                            settings.global_angle_unit = DEG;
                            angle_mode.label_text = "DEG";
                            break;
                    }
                    break;
            }
        }

        [GtkCallback]
        protected void on_import_dialog () {
            statistics_view.import_csv_file (this);
        }

        public void send_toast (string message) {
            toast_overlay.add_toast (new Adw.Toast (message));
        }
    }
}
