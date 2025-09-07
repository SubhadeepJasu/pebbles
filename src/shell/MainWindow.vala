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
        private Button graph_angle_mode;
        private Button calculus_angle_mode;
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
        private unowned Gtk.ListBox nav_list_calc;
        [GtkChild]
        private unowned Gtk.ListBox nav_list_conv;
        [GtkChild]
        private unowned Gtk.Box main_view;
        [GtkChild]
        private unowned Adw.ViewStack view_stack;

        // Views
        [GtkChild]
        private unowned ScientificView scientific_view;
        [GtkChild]
        private unowned StatisticsView statistics_view;
        [GtkChild]
        private unowned GraphingView graphing_view;
        [GtkChild]
        private unowned ProgrammerView programmer_view;
        [GtkChild]
        private unowned CalculusView calculus_view;
        [GtkChild]
        private unowned ConvCurrencyView conv_currency_view;
        [GtkChild]
        private unowned DateView date_view;

        // Headers
        [GtkChild]
        private unowned Gtk.Stack header_stack;
        [GtkChild]
        private unowned Gtk.Box scientific_header_box;
        [GtkChild]
        private unowned Gtk.Box calculus_header_box;
        [GtkChild]
        private unowned Gtk.Box programmer_header_box;
        [GtkChild]
        private unowned Pebbles.Button wrd_length;
        [GtkChild]
        public unowned Gtk.ToggleButton bit_grid_toggle;
        [GtkChild]
        private unowned Gtk.Box statistics_header_box;
        [GtkChild]
        private unowned Gtk.Box graph_header_box;
        [GtkChild]
        private unowned Gtk.Box date_header_box;
        public Gtk.Stack date_header_box_stack;
        public Gtk.Switch diff_mode_switch;
        public Gtk.Switch add_mode_switch;
        [GtkChild]
        private unowned Gtk.Box currency_header_box;
        [GtkChild]
        private unowned Gtk.Button forex_reload_button;
        [GtkChild]
        private unowned Gtk.Box null_header_box;

        // Constant Bindings
        public string? context_scientific { get; default = Context.SCIENTIFIC; }
        public string? context_calculus { get; default = Context.CALCULUS; }
        public string? context_programmer { get; default = Context.PROGRAMMER; }
        public string? context_statistics { get; default = Context.STATISTICS; }
        public string? context_graphing { get; default = Context.GRAPHING; }
        public string? context_date { get; default = Context.DATE; }
        public string? context_conv_length { get; default = Context.CONV_LEN; }
        public string? context_conv_area { get; default = Context.CONV_AREA; }
        public string? context_conv_angle { get; default = Context.CONV_ANGLE; }
        public string? context_conv_data { get; default = Context.CONV_DATA; }
        public string? context_conv_energy { get; default = Context.CONV_ENERGY; }
        public string? context_conv_mass { get; default = Context.CONV_MASS; }
        public string? context_conv_power { get; default = Context.CONV_POWER; }
        public string? context_conv_pressure { get; default = Context.CONV_PRES; }
        public string? context_conv_speed { get; default = Context.CONV_SPEED; }
        public string? context_conv_temp { get; default = Context.CONV_TEMP; }
        public string? context_conv_time { get; default = Context.CONV_TIME; }
        public string? context_conv_volume { get; default = Context.CONV_VOL; }
        public string? context_conv_currency { get; default = Context.CONV_CURR; }

        // Instance variables
        private Gtk.EventControllerKey key_event_controller;
        private Pebbles.Settings settings;
        public HistoryModel[] op_history;
        private uint _background_ops;
        public uint background_ops {
            get {
                return _background_ops;
            }
            set {
                _background_ops = value;
                spinner.spinning = _background_ops > 0;
            }
        }

        private int loaded_table_length;
        private int loaded_max_series_length;

        protected signal void on_evaluate (string data);
        protected signal string on_memory_recall (string context);
        protected signal void on_memory_clear (string context);

        public signal bool on_key_down (string? context, uint keyval);
        public signal void on_key_up (string? context, uint keyval);
        public signal void on_all_clear (string? context);
        public signal void on_history_view (string context);
        public signal string on_history_copy (int id);
        public signal string on_history_insert (int id);
        public signal HistoryModel on_history_recall (int id);
        public signal string on_get_last_result (string context);
        public signal void on_stat_plot (double width, double height, StatPlotType plot_type, double dpi);
        public signal int on_stat_cell_update (double value, int index, int series_index);
        public signal string on_stat_cell_query (int index, int series_index);
        public signal void on_stat_export (string? path);
        public signal void on_render_graph (GraphPayloadModel payload);
        public signal void on_graph_export (string path);
        public signal string on_process_date_difference (DateTime from, DateTime to);
        public signal Date on_add_sub_date (DateTime start_date, int days, int month, int year, bool add);
        public signal string on_convert_value (string data);
        public signal string on_programmer_set_last_token (
            bool[] arr, GlobalWordLength wrd_length, NumberSystem number_system);
        public signal void on_programmer_populate_token_array (string exp, NumberSystem number_system);
        public signal string on_programmer_get_last_token ();
        public signal string on_programmer_convert_token (
            string exp, NumberSystem ns_a, NumberSystem ns_b, GlobalWordLength wrd_length, bool format_bin = false);
        public signal string on_programmer_str_to_bool_arr (string s, NumberSystem ns, GlobalWordLength wrd_length);
        public signal string on_programmer_change_exp_num_sys (string s, NumberSystem ns, GlobalWordLength wrd_length);

        construct {
            navigation_pane.add_css_class (Granite.STYLE_CLASS_SIDEBAR);

            settings = Pebbles.Settings.get_default ();

            build_ui ();
            setup_actions ();
            setup_evaluators ();
            setup_key_events ();
            setup_memory_events ();
            load_settings ();
        }

        private void build_ui () {
            var gtk_settings = Gtk.Settings.get_default ();
            var granite_settings = Granite.Settings.get_default ();
            var pebbles_settings = Pebbles.Settings.get_default ();

            if (!pebbles_settings.load_last_session) {
                pebbles_settings.reset_all ();
            }

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

            if (graph_header_box.get_first_child () == null) {
                graph_angle_mode = new Pebbles.Button () {
                    label_text = "DEG",
                    tooltip_desc = _("Switch angle mode"),
                    accel_markup = "F8",
                    width_request = 45,
                    focus_on_click = false,
                    can_focus = false
                };
                graph_header_box.append (graph_angle_mode);

                graph_angle_mode.clicked.connect (() => {
                    on_change_mode ();
                });

                var graph_mode_button = new Granite.ModeSwitch.from_icon_name (
                    "edit-symbolic",
                    "graphing-mode-symbolic"
                );
                graph_header_box.append (graph_mode_button);

                graph_mode_button.notify["active"].connect (() => {
                    if (graph_mode_button.active) {
                        graphing_view.show_graph_panel ();
                    } else {
                        graphing_view.show_equation_panel ();
                    }
                });

                graphing_view.panel_changed.connect ((showing_graphs) => {
                    graph_mode_button.active = showing_graphs;
                });
            }

            if (calculus_header_box.get_first_child () == null) {
                calculus_angle_mode = new Pebbles.Button () {
                    label_text = "DEG",
                    tooltip_desc = _("Switch angle mode"),
                    accel_markup = "F8",
                    width_request = 45,
                    focus_on_click = false,
                    can_focus = false
                };
                calculus_header_box.append (calculus_angle_mode);

                calculus_angle_mode.clicked.connect (() => {
                    on_change_mode ();
                });

                var calculus_mode_button = new Granite.ModeSwitch.from_icon_name (
                    "derivative-mode-symbolic",
                    "integral-mode-symbolic"
                );
                calculus_header_box.append (calculus_mode_button);

                calculus_mode_button.notify["active"].connect (() => {
                    calculus_view.integral_mode = calculus_mode_button.active;
                });
            }

            if (date_header_box.get_first_child () == null) {
                date_header_box_stack = new Gtk.Stack () {
                    transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
                };
                var date_age_label = new Gtk.Label (_("AGE"));
                var date_dur_label = new Gtk.Label (_("DUR"));
                diff_mode_switch = new Gtk.Switch ();
                diff_mode_switch.add_css_class ("mode-switch");
                var date_diff_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
                    valign = Gtk.Align.CENTER
                };
                diff_mode_switch.notify.connect ((pspec) => {
                    if (pspec.get_name () == "active") {
                        date_view.diff_mode_dur = diff_mode_switch.active;
                    }
                });
                date_diff_box.append (date_age_label);
                date_diff_box.append (diff_mode_switch);
                date_diff_box.append (date_dur_label);

                var date_add_label = new Gtk.Label (_("ADD"));
                var date_sub_label = new Gtk.Label (_("SUB"));
                add_mode_switch = new Gtk.Switch ();
                add_mode_switch.notify.connect ((pspec) => {
                    if (pspec.get_name () == "active") {
                        date_view.date_find_mode = add_mode_switch.active;
                    }
                });
                add_mode_switch.add_css_class ("mode-switch");
                var date_add_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
                    valign = Gtk.Align.CENTER
                };
                date_add_box.append (date_add_label);
                date_add_box.append (add_mode_switch);
                date_add_box.append (date_sub_label);

                date_header_box_stack.add_named (date_diff_box, "date-dur-view");
                date_header_box_stack.add_named (date_add_box, "date-add-view");
                date_header_box.append (date_header_box_stack);
            }

            bit_grid_toggle.remove_css_class ("image-button");
        }

        private void setup_actions () {
            nav_list_calc.select_row (nav_list_calc.get_row_at_index (0));
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
                show_view (Context.SCIENTIFIC, scientific_header_box);
            });
            add_action (enable_scientific_mode_action);

            var enable_calculus_mode_action = new SimpleAction ("open_calculus_mode", null);
            enable_calculus_mode_action.activate.connect (() => {
                show_view (Context.CALCULUS, calculus_header_box);
            });
            add_action (enable_calculus_mode_action);

            var enable_programmer_mode_action = new SimpleAction ("open_programmer_mode", null);
            enable_programmer_mode_action.activate.connect (() => {
                show_view (Context.PROGRAMMER, programmer_header_box);
            });
            add_action (enable_programmer_mode_action);

            var enable_statistics_mode_action = new SimpleAction ("open_statistics_mode", null);
            enable_statistics_mode_action.activate.connect (() => {
                show_view (Context.STATISTICS, statistics_header_box);
            });
            add_action (enable_statistics_mode_action);

            var enable_graphing_mode_action = new SimpleAction ("open_graphing_mode", null);
            enable_graphing_mode_action.activate.connect (() => {
                show_view (Context.GRAPHING, graph_header_box);
            });
            add_action (enable_graphing_mode_action);

            var enable_date_mode_action = new SimpleAction ("open_date_mode", null);
            enable_date_mode_action.activate.connect (() => {
                show_view (Context.DATE, date_header_box);
            });
            add_action (enable_date_mode_action);

            var enable_conv_length_mode_action = new SimpleAction ("open_conv_length_mode", null);
            enable_conv_length_mode_action.activate.connect (() => {
                show_view (Context.CONV_LEN, null_header_box);
            });
            add_action (enable_conv_length_mode_action);

            var enable_conv_area_mode_action = new SimpleAction ("open_conv_area_mode", null);
            enable_conv_area_mode_action.activate.connect (() => {
                show_view (Context.CONV_AREA, null_header_box);
            });
            add_action (enable_conv_area_mode_action);

            var enable_conv_angle_mode_action = new SimpleAction ("open_conv_angle_mode", null);
            enable_conv_angle_mode_action.activate.connect (() => {
                show_view (Context.CONV_ANGLE, null_header_box);
            });
            add_action (enable_conv_angle_mode_action);

            var enable_conv_data_mode_action = new SimpleAction ("open_conv_data_mode", null);
            enable_conv_data_mode_action.activate.connect (() => {
                show_view (Context.CONV_DATA, null_header_box);
            });
            add_action (enable_conv_data_mode_action);

            var enable_conv_energy_mode_action = new SimpleAction ("open_conv_energy_mode", null);
            enable_conv_energy_mode_action.activate.connect (() => {
                show_view (Context.CONV_ENERGY, null_header_box);
            });
            add_action (enable_conv_energy_mode_action);

            var enable_conv_mass_mode_action = new SimpleAction ("open_conv_mass_mode", null);
            enable_conv_mass_mode_action.activate.connect (() => {
                show_view (Context.CONV_MASS, null_header_box);
            });
            add_action (enable_conv_mass_mode_action);

            var enable_conv_power_mode_action = new SimpleAction ("open_conv_power_mode", null);
            enable_conv_power_mode_action.activate.connect (() => {
                show_view (Context.CONV_POWER, null_header_box);
            });
            add_action (enable_conv_power_mode_action);

            var enable_conv_pressure_mode_action = new SimpleAction ("open_conv_pressure_mode", null);
            enable_conv_pressure_mode_action.activate.connect (() => {
                show_view (Context.CONV_PRES, null_header_box);
            });
            add_action (enable_conv_pressure_mode_action);

            var enable_conv_speed_mode_action = new SimpleAction ("open_conv_speed_mode", null);
            enable_conv_speed_mode_action.activate.connect (() => {
                show_view (Context.CONV_SPEED, null_header_box);
            });
            add_action (enable_conv_speed_mode_action);

            var enable_conv_temp_mode_action = new SimpleAction ("open_conv_temp_mode", null);
            enable_conv_temp_mode_action.activate.connect (() => {
                show_view (Context.CONV_TEMP, null_header_box);
            });
            add_action (enable_conv_temp_mode_action);

            var enable_conv_time_mode_action = new SimpleAction ("open_conv_time_mode", null);
            enable_conv_time_mode_action.activate.connect (() => {
                show_view (Context.CONV_TIME, null_header_box);
            });
            add_action (enable_conv_time_mode_action);

            var enable_conv_volume_mode_action = new SimpleAction ("open_conv_volume_mode", null);
            enable_conv_volume_mode_action.activate.connect (() => {
                show_view (Context.CONV_VOL, null_header_box);
            });
            add_action (enable_conv_volume_mode_action);

            var enable_conv_currency_mode_action = new SimpleAction ("open_conv_currency_mode", null);
            enable_conv_currency_mode_action.activate.connect (() => {
                show_view (Context.CONV_CURR, currency_header_box);
                conv_currency_view.update_forex_data.begin ();
            });
            add_action (enable_conv_currency_mode_action);
        }

        private void show_view (string view_name, Gtk.Widget? header_box) {
            if (view_stack.visible_child_name != view_name) {
                view_stack.set_visible_child_name (view_name);
                ((View) view_stack.visible_child).fade_in ();
                header_stack.set_visible_child (header_box);
                Idle.add_once (() => {
                    ((View) view_stack.visible_child).focus_main ();
                });
            }

            split_view.show_content = true;
        }

        private void setup_evaluators () {
            scientific_view.on_evaluate.connect ((input, memory_op) => {
                var gen = new Json.Generator ();
                var root = new Json.Node (Json.NodeType.OBJECT);
                var object = new Json.Object ();
                root.set_object (object);
                gen.set_root (root);

                object.set_string_member ("context", Context.SCIENTIFIC);
                object.set_string_member ("input", input);
                object.set_int_member ("angleMode", (int) Pebbles.Settings.get_default ().global_angle_unit);
                object.set_int_member ("memoryOp", memory_op);

                size_t length;
                background_tasks_append ();
                string json = gen.to_data (out length);
                on_evaluate (json);
            });
            statistics_view.on_evaluate.connect ((op, options) => {
                var gen = new Json.Generator ();
                var root = new Json.Node (Json.NodeType.OBJECT);
                var object = new Json.Object ();
                root.set_object (object);
                gen.set_root (root);

                object.set_string_member ("context", Context.STATISTICS);
                object.set_int_member ("op", op);
                if (options != null) {
                    object.set_object_member ("options", options);
                }
                size_t length;
                string json = gen.to_data (out length);

                background_tasks_append ();
                on_evaluate (json);
            });
            calculus_view.on_evaluate.connect ((input, integral_mode, lim_a, lim_b, memory_op) => {
                var gen = new Json.Generator ();
                var root = new Json.Node (Json.NodeType.OBJECT);
                var object = new Json.Object ();
                root.set_object (object);
                gen.set_root (root);

                var __settings = Pebbles.Settings.get_default ();

                object.set_string_member ("context", Context.CALCULUS);
                object.set_string_member ("input", input);
                object.set_boolean_member ("integralMode", integral_mode);
                object.set_double_member ("limitA", lim_a);
                object.set_double_member ("limitB", lim_b);
                object.set_int_member ("angleMode", (int) __settings.global_angle_unit);
                object.set_int_member ("memoryOp", memory_op);
                object.set_int_member ("integralAccuracy", __settings.integration_resolution);
                object.set_int_member ("derivativeAccuracy", __settings.derivative_accuracy);

                size_t length;
                background_tasks_append ();
                string json = gen.to_data (out length);
                on_evaluate (json);
            });
            programmer_view.on_evaluate.connect ((input, number_system, word_length, memory_op) => {
                 var gen = new Json.Generator ();
                var root = new Json.Node (Json.NodeType.OBJECT);
                var object = new Json.Object ();
                root.set_object (object);
                gen.set_root (root);

                object.set_string_member ("context", Context.PROGRAMMER);
                object.set_string_member ("input", input);
                object.set_int_member ("numberSystem", (int) number_system);
                object.set_int_member ("wordLength", (int) word_length);
                object.set_int_member ("memoryOp", memory_op);

                size_t length;
                background_tasks_append ();
                string json = gen.to_data (out length);
                on_evaluate (json);
            });
        }

        private void setup_key_events () {
            key_event_controller = new Gtk.EventControllerKey ();
            key_event_controller.key_pressed.connect ((keyval, _, modifier) => {
                var shift_key = keyval == Gdk.Key.Shift_L || keyval == Gdk.Key.Shift_R;
                var lock_on = (modifier & Gdk.ModifierType.LOCK_MASK) != 0;
                var lock_key = keyval == Gdk.Key.Caps_Lock;
                if (shift_key) {
                    set_shift_on (!lock_on);
                }

                if (lock_key) {
                    set_shift_on (!lock_on);
                }

                if (keyval == Gdk.Key.BackSpace && (modifier & Gdk.ModifierType.SHIFT_MASK) != 0) {
                    on_all_clear (view_stack.visible_child_name);
                }

                if ((
                    modifier &
                    (
                        Gdk.ModifierType.CONTROL_MASK |
                        Gdk.ModifierType.ALT_MASK
                    )) != 0 || shift_key || (preferences_dialog != null && preferences_dialog.visible)) {
                    return Gdk.EVENT_PROPAGATE;
                }

                on_key_down (view_stack.visible_child_name, keyval);

                if (view_stack.visible_child_name == Context.STATISTICS) {
                    if (keyval == Gdk.Key.Tab || keyval == 65056) {
                        statistics_view.key_navigate ();
                        return Gdk.EVENT_STOP;
                    } else if (keyval == Gdk.Key.Home) {
                        statistics_view.key_extreme_navigate (true);
                        return Gdk.EVENT_STOP;
                    } else if (keyval == Gdk.Key.End) {
                        statistics_view.key_extreme_navigate (false);
                        return Gdk.EVENT_STOP;
                    }
                }

                return Gdk.EVENT_PROPAGATE;
            });
            key_event_controller.key_released.connect ((keyval, _, modifier) => {
                var shift_key = keyval == Gdk.Key.Shift_L || keyval == Gdk.Key.Shift_R;
                var lock_on = (modifier & Gdk.ModifierType.LOCK_MASK) != 0;
                if (shift_key) {
                    set_shift_on (lock_on);
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

                if (view_stack.visible_child_name == Context.STATISTICS && keyval == Gdk.Key.Tab) {
                    return;
                }
            });
            key_event_controller.set_propagation_phase (Gtk.PropagationPhase.CAPTURE);
            ((Gtk.Widget) this).add_controller (key_event_controller);
        }

        private void setup_memory_events () {
            scientific_view.on_memory_recall.connect ((global) => {
                return on_memory_recall (global ? "global" : Context.SCIENTIFIC);
            });

            scientific_view.on_memory_clear.connect ((global) => {
                on_memory_clear (global ? "global" : Context.SCIENTIFIC);
            });

            statistics_view.on_memory_recall.connect ((global) => {
                return on_memory_recall (global ? "global" : Context.STATISTICS);
            });

            statistics_view.on_memory_clear.connect ((global) => {
                on_memory_clear (global ? "global" : Context.STATISTICS);
            });

            graphing_view.on_memory_recall.connect (() => {
                return on_memory_recall ("global");
            });

            programmer_view.on_memory_recall.connect ((global) => {
                var mam_val = on_memory_recall (global ? "global" : Context.PROGRAMMER);
                mam_val = mam_val.split (".")[0];
                return mam_val;
            });

            programmer_view.on_memory_clear.connect ((global) => {
                on_memory_clear (global ? "global" : Context.PROGRAMMER);
            });
        }

        private void load_settings () {
            switch (settings.global_angle_unit) {
                case DEG:
                    angle_mode.label_text = "DEG";
                    graph_angle_mode.label_text = "DEG";
                    calculus_angle_mode.label_text = "DEG";
                    break;
                case RAD:
                    angle_mode.label_text = "RAD";
                    graph_angle_mode.label_text = "RAD";
                    calculus_angle_mode.label_text = "RAD";
                    break;
                case GRAD:
                    angle_mode.label_text = "GRA";
                    graph_angle_mode.label_text = "GRA";
                    calculus_angle_mode.label_text= "GRA";
                    break;
            }

            set_button_word_length ();

            settings.changed["global-word-length"].connect ((key) => {
                set_button_word_length ();
            });
        }

        private void set_button_word_length () {
            switch (settings.global_word_length) {
                case QWD:
                    wrd_length.label_text = "QWD";
                    break;
                case DWD:
                    wrd_length.label_text = "DWD";
                    break;
                case WRD:
                    wrd_length.label_text = "WRD";
                    break;
                case BYT:
                    wrd_length.label_text = "BYT";
                    break;
            }
        }

        protected void on_evaluation_completed (string data) {
            Idle.add (() => {
                background_tasks_remove ();
                var parser = new Json.Parser ();
                try {
                    parser.load_from_data (data, -1);

                    var root_object = parser.get_root ().get_object ();
                    var mode = root_object.get_string_member ("mode");
                    switch (mode) {
                        case Pebbles.Context.SCIENTIFIC:
                            var result = root_object.get_string_member ("result");
                            scientific_view.show_result (result);
                            break;
                        case Pebbles.Context.CALCULUS:
                            var result = root_object.get_string_member ("result");
                            calculus_view.show_result (result);
                            break;
                        case Pebbles.Context.STATISTICS:
                            if (root_object.has_member ("shape")) {
                                var shape_node = root_object.get_array_member ("shape");
                                loaded_table_length = (int) shape_node.get_int_element (0);
                                loaded_max_series_length = (int) shape_node.get_int_element (1);
                                debug (
                                    "Data loaded of shape (%d, %d)\n",
                                    loaded_table_length,
                                    loaded_max_series_length
                                );
                                Idle.add_once (() => {
                                    send_toast (_("Loaded dataset of size [%d, %d] from file")
                                    .printf (loaded_max_series_length, loaded_table_length));
                                    statistics_view.refresh (loaded_max_series_length);
                                });
                            } else if (root_object.has_member ("cleared")) {
                                Idle.add_once (() => {
                                    send_toast (_("Dataset cleared"));
                                    statistics_view.refresh (1);
                                    statistics_view.show_result ("0");
                                });
                            } else {
                                var result = root_object.get_string_member ("result");
                                statistics_view.show_result (result);
                            }
                            break;
                        case Pebbles.Context.PROGRAMMER:
                            var result = root_object.get_string_member ("result");
                            programmer_view.show_result (result);
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

        protected void on_plot_ready (Gdk.Pixbuf? figure, bool valid) {
            statistics_view.plot (figure, valid);
        }

        protected void on_render_ready (Gdk.Pixbuf? figure, bool valid) {
            graphing_view.render_graph (figure, valid);
        }

        protected void on_memory_change (string context, bool present) {
            background_tasks_remove ();
            switch (context) {
                case Context.SCIENTIFIC:
                    scientific_view.set_memory_present (present);
                    break;
                case Context.STATISTICS:
                    statistics_view.set_memory_present (present);
                    break;
                case Context.PROGRAMMER:
                    programmer_view.set_memory_present (present);
                    break;
                default:
                    scientific_view.set_global_memory_present (present);
                    statistics_view.set_global_memory_present (present);
                    graphing_view.set_global_memory_present (present);
                    programmer_view.set_global_memory_present (present);
                    break;
            }
        }

        protected void show_history (HistoryModel[] _history, string context) {
            switch (view_stack.visible_child_name) {
                case Context.SCIENTIFIC:
                    scientific_view.show_history (_history);
                    break;
                case Context.STATISTICS:
                    statistics_view.show_history (_history);
                    break;
                case Context.CALCULUS:
                    calculus_view.show_history (_history);
                    break;
                case Context.PROGRAMMER:
                    programmer_view.show_history (_history);
                    break;
            }
        }

        protected void history_recall (HistoryModel _history) {
            switch (_history.context) {
                case Context.SCIENTIFIC:
                case Context.CALCULUS:
                case Context.GRAPHING:
                    settings.global_angle_unit = (GlobalAngleUnit) _history.metadata.metadata_1;
                    switch (settings.global_angle_unit) {
                        case RAD:
                            angle_mode.label_text = "RAD";
                            graph_angle_mode.label_text = "RAD";
                            calculus_angle_mode.label_text = "RAD";
                            break;
                        case GRAD:
                            angle_mode.label_text = "GRA";
                            graph_angle_mode.label_text = "GRA";
                            calculus_angle_mode.label_text = "GRA";
                            break;
                        case DEG:
                            angle_mode.label_text = "DEG";
                            graph_angle_mode.label_text = "DEG";
                            calculus_angle_mode.label_text = "DEG";
                            break;
                    }
                    break;
                case Context.PROGRAMMER:
                    settings.global_word_length = (GlobalWordLength) _history.metadata.metadata_1;
                    switch (settings.global_word_length) {
                        case QWD:
                            wrd_length.label_text = "QWD";
                            break;
                        case DWD:
                            wrd_length.label_text = "DWD";
                            break;
                        case WRD:
                            wrd_length.label_text = "WRD";
                            break;
                        case BYT:
                            wrd_length.label_text = "BYT";
                            break;
                    }
                    break;
            }
        }

        protected void warn_table_change () {
            send_toast (_("Dataset not loaded. Creating one!"));
        }

        private void set_shift_on (bool on) {
            scientific_view.send_shift_modifier (on);
            statistics_view.send_shift_modifier (on);
            graphing_view.send_shift_modifier (on);
            calculus_view.send_shift_modifier (on);
            programmer_view.send_shift_modifier (on);
        }

        [GtkCallback]
        protected void set_theme (Gtk.CheckButton button) {
            if (button.active) {
                settings.theme = button.name;
                build_ui ();
            }
        }

        [GtkCallback]
        protected void on_change_mode () {
            switch (view_stack.visible_child_name) {
                case Context.SCIENTIFIC:
                case Context.CALCULUS:
                case Context.GRAPHING:
                    switch (settings.global_angle_unit) {
                        case DEG:
                            settings.global_angle_unit = RAD;
                            angle_mode.label_text = "RAD";
                            graph_angle_mode.label_text = "RAD";
                            calculus_angle_mode.label_text = "RAD";
                            break;
                        case RAD:
                            settings.global_angle_unit = GRAD;
                            angle_mode.label_text = "GRA";
                            graph_angle_mode.label_text = "GRA";
                            calculus_angle_mode.label_text = "GRA";
                            break;
                        case GRAD:
                            settings.global_angle_unit = DEG;
                            angle_mode.label_text = "DEG";
                            graph_angle_mode.label_text = "DEG";
                            calculus_angle_mode.label_text = "DEG";
                            break;
                    }
                    break;
                case Context.PROGRAMMER:
                    switch (settings.global_word_length) {
                        case QWD:
                            settings.global_word_length = DWD;
                            wrd_length.label_text = "DWD";
                            break;
                        case DWD:
                            settings.global_word_length = WRD;
                            wrd_length.label_text = "WRD";
                            break;
                        case WRD:
                            settings.global_word_length = BYT;
                            wrd_length.label_text = "BYT";
                            break;
                        case BYT:
                            settings.global_word_length = QWD;
                            wrd_length.label_text = "QWD";
                            break;
                    }
                    break;
            }
        }

        [GtkCallback]
        protected void on_import_dialog () {
            statistics_view.import_csv_file (this);
        }

        [GtkCallback]
        protected void on_save_csv () {
            statistics_view.save_csv (this);
        }

        [GtkCallback]
        protected void on_start_api_call () {
            forex_reload_button.sensitive = false;
            background_tasks_append ();
        }

        [GtkCallback]
        protected void on_end_api_call (Gtk.Widget widget, string message) {
            if (message.length > 0) {
                send_toast (message);
            }

            background_tasks_remove ();
            forex_reload_button.sensitive = true;
        }

        [GtkCallback]
        protected void force_refresh_forex_data () {
            conv_currency_view.update_forex_data.begin (true);
        }

        [GtkCallback]
        protected void show_bit_grid (Gtk.ToggleButton button) {
            if (button.active) {
                programmer_view.open_bit_grid ();
            } else {
                programmer_view.on_hide_bit_grid ();
            }
        }

        [GtkCallback]
        protected void on_list_select (Gtk.ListBox list_box, Gtk.ListBoxRow? row) {
            if (list_box == nav_list_conv) {
                nav_list_calc.unselect_all ();
            } else {
                nav_list_conv.unselect_all ();
            }

            if (row != null && !row.is_selected ()) {
                row.activate ();
            }
        }

        public void send_toast (string message) {
            toast_overlay.add_toast (new Adw.Toast (message));
        }

        public void background_tasks_append () {
            background_ops = background_ops + 1;
        }

        public void background_tasks_remove () {
            if (background_ops > 0) {
                background_ops = background_ops - 1;
            }
        }

        public string unit_converter_evaluate (
            string context,
            double[]? conversion_factors,
            string input,
            int unit1_index,
            int unit2_index
        ) {
            var gen = new Json.Generator ();
            var root = new Json.Node (Json.NodeType.OBJECT);
            var object = new Json.Object ();
            root.set_object (object);
            gen.set_root (root);

            object.set_string_member ("context", context);
            object.set_string_member ("input", input);
            object.set_int_member ("unit1", unit1_index);
            object.set_int_member ("unit2", unit2_index);

            var array = new Json.Array ();
            for (uint i = 0; i < conversion_factors.length; i++) {
                array.add_double_element (conversion_factors[i]);
            }

            object.set_array_member ("conversionFactors", array);

            size_t length;
            string json = gen.to_data (out length);
            return on_convert_value (json);
        }
    }
}
