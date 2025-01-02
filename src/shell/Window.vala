// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2024 Subhadeep Jasu <subhadeep107@proton.me>, 2020 Saunak Biswas <saunakbis97@gmail.com>

namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        private unowned Adw.ToastOverlay toast_overlay;
        [GtkChild]
        private unowned Adw.NavigationSplitView split_view;

        [GtkChild]
        private unowned Adw.HeaderBar main_headerbar;
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

        private Gtk.EventControllerKey key_event_controller;


        protected signal void on_evaluate (string data);
        protected signal string on_memory_recall (string mode);
        protected signal void on_memory_clear (string mode);

        construct {
            navigation_pane.add_css_class (Granite.STYLE_CLASS_SIDEBAR);

            setup_theme ();
            setup_actions ();
            setup_evaluators ();
            setup_key_events ();
            setup_memory_events ();
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
            var enable_scientific_mode_action = new SimpleAction ("open_scientific_mode", null);
            enable_scientific_mode_action.activate.connect (() => {
                view_stack.set_visible_child_name ("sci");
                split_view.show_content = true;
            });
            add_action (enable_scientific_mode_action);
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
                object.set_int_member ("angleMode", 0);
                object.set_int_member ("memoryOp", memory_op);

                size_t length;
                string json = gen.to_data (out length);
                print (json + "\n");
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
                    )) != 0 || shift_key) {
                    return false;
                }

                if (view_stack.visible_child == scientific_view) {
                    scientific_view.send_key_down (keyval);
                }

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
                    )) != 0 || shift_key) {
                    return;
                }

                if (view_stack.visible_child == scientific_view) {
                    scientific_view.send_key_up (keyval);
                }
            });
            key_event_controller.set_propagation_phase (Gtk.PropagationPhase.CAPTURE);
            ((Gtk.Widget) this).add_controller (key_event_controller);
        }

        private void setup_memory_events () {
            scientific_view.on_memory_recall.connect ((global) => {
                return on_memory_recall (global ? "global" : "sci");
            });
        }

        protected void on_evaluation_completed (string data) {
            Idle.add (() => {
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

        protected void on_memory_change (string context, bool present) {
            switch (context) {
                case "sci":
                    scientific_view.set_memory_present (present);
                    break;
                default:
                    scientific_view.set_global_memory_present (present);
                    break;
            }
        }

        private void set_shift_on (bool on) {
            scientific_view.send_shift_modifier (on);
        }

        [GtkCallback]
        protected void set_theme (Gtk.CheckButton button) {
            if (button.active) {
                Pebbles.Settings.get_default ().theme = button.name;
                setup_theme ();
            }
        }
    }
}
