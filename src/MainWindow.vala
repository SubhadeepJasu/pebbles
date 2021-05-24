/*-
 * Copyright (c) 2017-2020 Subhadeep Jasu <subhajasu@gmail.com>
 * Copyright (c) 2017-2020 Saunak Biswas <saunakbis97@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 *              Saunak Biswas  <saunakbis97@gmail.com>
 */

namespace Pebbles {
    public class MainWindow : Gtk.Window {
        // Main Leaflet
        Hdy.Leaflet main_leaflet;

        Hdy.Deck main_deck;

        // CONTROLS
        Gtk.HeaderBar headerbar;
        Granite.ModeSwitch dark_mode_switch;
        Pebbles.Settings settings;
        Gtk.MenuButton app_menu;

        // Switchable Controls
        public Gtk.Stack header_switcher;

        // Header Widgets
        Gtk.Grid programmer_header_grid;
        Gtk.Grid scientific_header_grid;
        Gtk.Label null_switcher;
        Gtk.Label shift_label;
        public Gtk.Switch shift_switch;
        StyledButton angle_unit_button;
        StyledButton leaflet_back_button;
        Gtk.Button history_button;

        Gtk.Label date_age_label;
        Gtk.Label date_dur_label;
        public Gtk.Switch diff_mode_switch;
        Gtk.Label date_add_label;
        Gtk.Label date_sub_label;
        public Gtk.Switch add_mode_switch;
        public Gtk.Stack date_mode_stack;
        public Gtk.Grid date_diff_grid;
        public Gtk.Grid date_add_grid;

        Gtk.Button word_length_button;
        public Gtk.Switch shift_switch_prog;

        public Gtk.Button update_button;

        // VIEWS
        Granite.Widgets.SourceList item_list;
        Gtk.Stack common_view;
        Pebbles.ScientificView scientific_view;
        Pebbles.ProgrammerView programmer_view;
        Pebbles.CalculusView   calculus_view;
        Pebbles.DateView       date_view;
        Pebbles.StatisticsView statistics_view;

        Pebbles.ConvLengthView conv_length_view;
        Pebbles.ConvAreaView   conv_area_view;
        Pebbles.ConvVolumeView conv_volume_view;
        Pebbles.ConvTimeView   conv_time_view;
        Pebbles.ConvMassView   conv_mass_view;
        Pebbles.ConvPressView  conv_press_view;
        Pebbles.ConvEnergyView conv_energy_view;
        Pebbles.ConvTempView   conv_temp_view;
        Pebbles.ConvPowerView  conv_power_view;
        Pebbles.ConvSpeedView  conv_speed_view;
        Pebbles.ConvAngleView  conv_angle_view;
        Pebbles.ConvDataView   conv_data_view;
        Pebbles.ConvCurrView   conv_curr_view;

        // ITEMS
        Granite.Widgets.SourceList.Item programmer_item;
        Granite.Widgets.SourceList.Item date_item;
        Granite.Widgets.SourceList.Item stats_item;
        Granite.Widgets.SourceList.Item finance_item;
        Granite.Widgets.SourceList.Item conv_length_item;
        Granite.Widgets.SourceList.Item conv_area_item;
        Granite.Widgets.SourceList.Item conv_volume_item;
        Granite.Widgets.SourceList.Item conv_time_item;
        Granite.Widgets.SourceList.Item conv_angle_item;
        Granite.Widgets.SourceList.Item conv_speed_item;
        Granite.Widgets.SourceList.Item conv_mass_item;
        Granite.Widgets.SourceList.Item conv_press_item;
        Granite.Widgets.SourceList.Item conv_energy_item;
        Granite.Widgets.SourceList.Item conv_power_item;
        Granite.Widgets.SourceList.Item conv_temp_item;
        Granite.Widgets.SourceList.Item conv_data_item;
        Granite.Widgets.SourceList.Item conv_curr_item;

        // Switchable Items
        Granite.Widgets.SourceList.Item scientific_item;
        Granite.Widgets.SourceList.Item calculus_item;

        ControlsOverlay controls_modal;
        PreferencesOverlay preferences_modal;
        HistoryView     history_modal;

        // NOTIFICATION
        Notification desktop_notification;

        // History
        public HistoryManager history_manager;
        Gtk.MenuItem history_item;

        private bool currency_view_visited = false;

        // Keyboard Events
        Gdk.Keymap keymap;
        bool keyboard_shift_status;
        private bool ctrl_held = false;

        /// Initialized
        bool initialized = false;

        public MainWindow () {
            settings = Pebbles.Settings.get_default ();
            settings.notify["use-dark-theme"].connect (() => {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.use_dark_theme;
            });
            this.delete_event.connect (() => {
                save_settings ();
                return false;
            });
            history_manager = new HistoryManager ();

            keymap = Gdk.Keymap.get_for_display (Gdk.Display.get_default ());
            keymap.state_changed.connect (update_caps_status);
            this.configure_event.connect ((event) => {
                adjust_view (!initialized);
                if (!initialized) {
                    this.resize (settings.window_w, settings.window_h);
                }
                return false;
            });
            load_settings ();
            make_ui ();
            handle_focus ();
            Timeout.add (200, () => {
                if (main_leaflet.get_child_transition_running ()) {
                    return true;
                } else {
                    initialized = true;
                    adjust_view ();
                    return false;
                }
            });
        }

        public void make_ui () {
            // Create dark mode switcher
            dark_mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic");
            dark_mode_switch.primary_icon_tooltip_text = _("Light background");
            dark_mode_switch.secondary_icon_tooltip_text = _("Dark background");
            dark_mode_switch.valign = Gtk.Align.CENTER;
            dark_mode_switch.active = settings.use_dark_theme;
            dark_mode_switch.notify["active"].connect (() => {
                settings.use_dark_theme = dark_mode_switch.active;
            });

            // Make Scientific / Calculus View Controls ///////////////
            // Create back button
            leaflet_back_button = new StyledButton ("All Categories");
            leaflet_back_button.valign = Gtk.Align.CENTER;
            leaflet_back_button.set_image (new Gtk.Image.from_icon_name ("view-more-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
            leaflet_back_button.tooltip_text = "Pebbles Menu";
            leaflet_back_button.clicked.connect (() => {
                if (main_leaflet.get_visible_child () == common_view)
                    main_leaflet.set_visible_child (item_list);
                else
                    main_leaflet.set_visible_child (common_view);
            });
            // Create angle unit button
            angle_unit_button = new StyledButton ("DEG", "<b>" + _("Degrees") + "</b> \xE2\x86\x92" + _("Radians"), {"F8"});
            angle_unit_button.set_margin_end (7);
            angle_unit_button.width_request = 50;
            angle_unit_button.clicked.connect (() => {
                settings.switch_angle_unit ();
                angle_unit_button_label_update ();
            });

            // Create shift switcher
            scientific_header_grid = new Gtk.Grid ();
            shift_label = new Gtk.Label (_("Shift") + " ");
            shift_label.set_margin_start (2);
            shift_switch = new Gtk.Switch ();
            shift_switch.set_margin_top (4);
            shift_switch.set_margin_bottom (4);
            shift_switch.get_style_context ().add_class ("Pebbles_Header_Switch");
            shift_switch.notify["active"].connect (() => {
                scientific_view.hold_shift (shift_switch.active);
                calculus_view.hold_shift (shift_switch.active);
            });
            scientific_header_grid.attach (angle_unit_button, 0, 0, 1, 1);
            scientific_header_grid.attach (shift_label, 1, 0, 1, 1);
            scientific_header_grid.attach (shift_switch, 2, 0, 1, 1);
            scientific_header_grid.valign = Gtk.Align.CENTER;
            scientific_header_grid.column_spacing = 6;


            // Make Date Switcher ///////////////////////////////////////
            date_mode_stack = new Gtk.Stack ();
            date_age_label = new Gtk.Label ("AGE");
            date_dur_label = new Gtk.Label ("DUR");
            diff_mode_switch = new Gtk.Switch ();
            diff_mode_switch.get_style_context ().add_class ("mode-switch");
            date_diff_grid = new Gtk.Grid ();
            date_diff_grid.column_spacing = 6;
            date_diff_grid.attach (date_age_label, 0, 0, 1, 1);
            date_diff_grid.attach (diff_mode_switch, 1, 0, 1, 1);
            date_diff_grid.attach (date_dur_label, 2, 0, 1, 1);
            date_diff_grid.valign = Gtk.Align.CENTER;

            date_add_label = new Gtk.Label ("ADD");
            date_sub_label = new Gtk.Label ("SUB");
            add_mode_switch = new Gtk.Switch ();
            add_mode_switch.get_style_context ().add_class ("mode-switch");
            date_add_grid = new Gtk.Grid ();
            date_add_grid.column_spacing = 6;
            date_add_grid.attach (date_add_label, 0, 0, 1, 1);
            date_add_grid.attach (add_mode_switch, 1, 0, 1, 1);
            date_add_grid.attach (date_sub_label, 2, 0, 1, 1);
            date_add_grid.valign = Gtk.Align.CENTER;

            date_mode_stack.add_named (date_diff_grid, "Date_Diff");
            date_mode_stack.add_named (date_add_grid, "Date_Add");
            date_mode_stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);

            // Make Programmer Controls
            word_length_button = new Gtk.Button.with_label ("QWD");
            word_length_button.tooltip_text = "QWORD";
            word_length_button.set_margin_end (7);
            word_length_button.width_request = 50;
            word_length_button.clicked.connect (() => {
                settings.switch_word_length ();
                word_length_button_label_update ();
            });
            // Create shift switcher for programmer view
            programmer_header_grid = new Gtk.Grid ();
            var shift_label_prog = new Gtk.Label (_("Shift") + " ");
            shift_label_prog.set_margin_start (2);
            shift_switch_prog = new Gtk.Switch ();
            shift_switch_prog.set_margin_top (4);
            shift_switch_prog.set_margin_bottom (4);
            shift_switch_prog.get_style_context ().add_class ("Pebbles_Header_Switch");
            shift_switch_prog.notify["active"].connect (() => {
                programmer_view.hold_shift (shift_switch_prog.active);
            });
            programmer_header_grid.attach (word_length_button, 0, 0, 1, 1);
            programmer_header_grid.attach (shift_label_prog, 1, 0, 1, 1);
            programmer_header_grid.attach (shift_switch_prog, 2, 0, 1, 1);
            programmer_header_grid.valign = Gtk.Align.CENTER;
            programmer_header_grid.column_spacing = 6;


            // Make Conversion Switcher null
            null_switcher = new Gtk.Label ("");

            // Make currency update switcher
            update_button = new Gtk.Button.from_icon_name ("view-refresh-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            update_button.width_request = 10;
            update_button.halign = Gtk.Align.START;
            update_button.margin = 1;
            update_button.tooltip_markup = Granite.markup_accel_tooltip ({"R"}, "<b>" + _("Update Forex Data") + "</b>\n" + _("Updates automatically every 10 minutes") + _("\nLast updated on ") + settings.currency_update_date);

            // Create App Menu
            app_menu = new Gtk.MenuButton ();
            app_menu.valign = Gtk.Align.CENTER;
            app_menu.set_margin_top (8);
            app_menu.set_margin_bottom (8);
            app_menu.set_image (new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
            app_menu.tooltip_text = "Pebbles Menu";

            var settings_menu = new Gtk.Menu ();
            var controls_overlay_item = new Gtk.MenuItem();
            controls_overlay_item.add (new Granite.AccelLabel (_("Show Controls"), "F1"));
            var preferences_overlay_item = new Gtk.MenuItem ();
            preferences_overlay_item.add (new Granite.AccelLabel (_("Preferences"), "F2"));
            history_item = new Gtk.MenuItem ();
            history_item.add (new Granite.AccelLabel (_("History"), ""));

            settings_menu.append (controls_overlay_item);
            settings_menu.append (preferences_overlay_item);
            settings_menu.append (history_item);
            settings_menu.show_all();

            controls_overlay_item.activate.connect (() => {
                show_controls ();
            });

            preferences_overlay_item.activate.connect (() => {
                show_preferences ();
            });

            history_item.activate.connect (() => {
                show_history ();
            });

            app_menu.popup = settings_menu;

            // Create History Button
            history_button = new Gtk.Button ();
            history_button.valign = Gtk.Align.CENTER;
            history_button.set_image (new Gtk.Image.from_icon_name ("document-open-recent-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
            history_button.set_margin_end (4);
            history_button.tooltip_text = _("Show Calculation History");

            history_button.clicked.connect (() => {
                show_history ();
            });

            // Create Header Switcher
            header_switcher = new Gtk.Stack ();
            header_switcher.set_margin_top (7);
            header_switcher.set_margin_bottom (7);
            header_switcher.set_transition_type (Gtk.StackTransitionType.SLIDE_UP_DOWN);
            header_switcher.add_named (scientific_header_grid, "Scientific/Calculus Header Switch");
            header_switcher.add_named (programmer_header_grid, "Programmer Header Switch");
            header_switcher.add_named (date_mode_stack, "Date Mode Switch");
            header_switcher.add_named (null_switcher, "Converter");
            header_switcher.add_named (update_button, "Update Currency");



            // Create headerbar
            headerbar = new Gtk.HeaderBar ();
            headerbar.title = ("Pebbles");
            headerbar.get_style_context ().add_class ("default-decoration");
            headerbar.show_close_button = true;
            headerbar.height_request = 47;
            headerbar.pack_start (leaflet_back_button);
            headerbar.pack_start (header_switcher);
            headerbar.pack_end (history_button);
            headerbar.pack_end (app_menu);
            headerbar.pack_end (dark_mode_switch);// Uncomment to use dark mode switch
            this.set_titlebar (headerbar);

            // Create Item Pane
            scientific_item  = new Granite.Widgets.SourceList.Item (_("Scientific"));
            calculus_item    = new Granite.Widgets.SourceList.Item (_("Calculus"));
            programmer_item  = new Granite.Widgets.SourceList.Item (_("Programmer"));
            date_item        = new Granite.Widgets.SourceList.Item (_("Date"));
            stats_item       = new Granite.Widgets.SourceList.Item (_("Statistics"));
            var finance_item     = new Granite.Widgets.SourceList.Item (_("Financial"));
            conv_length_item = new Granite.Widgets.SourceList.Item (_("Length"));
            conv_area_item   = new Granite.Widgets.SourceList.Item (_("Area"));
            conv_volume_item = new Granite.Widgets.SourceList.Item (_("Volume"));
            conv_time_item   = new Granite.Widgets.SourceList.Item (_("Time"));
            conv_angle_item  = new Granite.Widgets.SourceList.Item (_("Angle"));
            conv_speed_item  = new Granite.Widgets.SourceList.Item (_("Speed"));
            conv_mass_item   = new Granite.Widgets.SourceList.Item (_("Mass"));
            conv_press_item  = new Granite.Widgets.SourceList.Item (_("Pressure"));
            conv_energy_item = new Granite.Widgets.SourceList.Item (_("Energy"));
            conv_power_item  = new Granite.Widgets.SourceList.Item (_("Power"));
            conv_temp_item   = new Granite.Widgets.SourceList.Item (_("Temperature"));
            conv_data_item   = new Granite.Widgets.SourceList.Item (_("Data"));
            conv_curr_item   = new Granite.Widgets.SourceList.Item (_("Currency"));

            // Calculators
            var calc_category = new Granite.Widgets.SourceList.ExpandableItem (_("Calculator"));
            calc_category.expand_all ();
            calc_category.add (scientific_item);
            calc_category.add (calculus_item);
            calc_category.add (programmer_item); // Will be added in a future update
            calc_category.add (date_item);
            calc_category.add (stats_item);
            //calc_category.add (finance_item);
            // Converters
            var conv_category = new Granite.Widgets.SourceList.ExpandableItem (_("Converter"));
            //conv_category.expand_all ();
            conv_category.add (conv_length_item);
            conv_category.add (conv_area_item);
            conv_category.add (conv_volume_item);
            conv_category.add (conv_time_item);
            conv_category.add (conv_angle_item);
            conv_category.add (conv_speed_item);
            conv_category.add (conv_mass_item);
            conv_category.add (conv_press_item);
            conv_category.add (conv_energy_item);
            conv_category.add (conv_power_item);
            conv_category.add (conv_temp_item);
            conv_category.add (conv_data_item);
            conv_category.add (conv_curr_item);

            item_list = new Granite.Widgets.SourceList ();
            item_list.get_style_context().add_class("sidebar-left");
            item_list.root.add (calc_category);
            item_list.root.add (conv_category);
            item_list.width_request = 180;
            item_list.hexpand = false;

            // Create Views
            scientific_view  = new Pebbles.ScientificView (this);
            programmer_view  = new Pebbles.ProgrammerView (this);
            calculus_view    = new Pebbles.CalculusView (this);
            date_view        = new Pebbles.DateView (this);
            statistics_view  = new Pebbles.StatisticsView ();
            conv_length_view = new Pebbles.ConvLengthView ();
            conv_area_view   = new Pebbles.ConvAreaView ();
            conv_volume_view = new Pebbles.ConvVolumeView ();
            conv_time_view   = new Pebbles.ConvTimeView ();
            conv_angle_view  = new Pebbles.ConvAngleView ();
            conv_speed_view  = new Pebbles.ConvSpeedView ();
            conv_mass_view   = new Pebbles.ConvMassView ();
            conv_press_view  = new Pebbles.ConvPressView ();
            conv_energy_view = new Pebbles.ConvEnergyView ();
            conv_power_view  = new Pebbles.ConvPowerView ();
            conv_temp_view   = new Pebbles.ConvTempView ();
            conv_data_view   = new Pebbles.ConvDataView ();
            conv_curr_view   = new Pebbles.ConvCurrView ();

            history_manager.history_updated.connect (() => {
                scientific_view.last_answer_button.set_sensitive (!history_manager.is_empty (EvaluationResult.ResultSource.SCIF));
                calculus_view.last_answer_button.set_sensitive (!history_manager.is_empty (EvaluationResult.ResultSource.CALC));
                programmer_view.ans_button.set_sensitive (!history_manager.is_empty (EvaluationResult.ResultSource.PROG));
            });
            scientific_view.last_answer_button.set_sensitive (!history_manager.is_empty (EvaluationResult.ResultSource.SCIF));
            calculus_view.last_answer_button.set_sensitive (!history_manager.is_empty (EvaluationResult.ResultSource.CALC));
            programmer_view.ans_button.set_sensitive (!history_manager.is_empty (EvaluationResult.ResultSource.PROG));

            update_button.clicked.connect (() => {
                conv_curr_view.update_currency_data ();
            });

            this.scientific_view.toolbar_angle_mode_button.clicked.connect (() => {
                settings.switch_angle_unit ();
                angle_unit_button_label_update ();
            });

            conv_curr_view.start_update.connect (() => {
                update_button.set_sensitive (false);
            });
            conv_curr_view.update_done_or_failed.connect (() => {
                update_button.set_sensitive (true);
            });

            Timeout.add_seconds (600, () => {
                if (update_button.get_sensitive ()) {
                    update_button.set_sensitive (false);
                    conv_curr_view.update_currency_data ();
                    currency_view_visited = true;
                }
                return true;
            });

            // Create Views Pane
            common_view = new Gtk.Stack ();
            common_view.valign = Gtk.Align.FILL;
            common_view.halign = Gtk.Align.FILL;
            common_view.add_named (scientific_view, "Scientific");
            common_view.add_named (calculus_view, "Calculus");
            //  common_view.add_named (programmer_view, "Programmer");
            //  common_view.add_named (date_view, "Date");
            //  common_view.add_named (statistics_view, "Statistics");
            //  common_view.add_named (conv_length_view, "Length");
            //  common_view.add_named (conv_area_view, "Area");
            //  common_view.add_named (conv_volume_view, "Volume");
            //  common_view.add_named (conv_time_view, "Time");
            //  common_view.add_named (conv_angle_view, "Angle");
            //  common_view.add_named (conv_speed_view, "Speed");
            //  common_view.add_named (conv_mass_view, "Mass");
            //  common_view.add_named (conv_press_view, "Pressure");
            //  common_view.add_named (conv_energy_view, "Energy");
            //  common_view.add_named (conv_power_view, "Power");
            //  common_view.add_named (conv_temp_view, "Temperature");
            //  common_view.add_named (conv_data_view, "Data");
            //  common_view.add_named (conv_curr_view, "Currency");

            //  //Create Panes
            //  var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            //  paned.position = 200;
            //  paned.position_set = true;
            //  paned.pack1 (item_list, false, false);
            //  paned.pack2 (common_view, false, false);

            main_leaflet = new Hdy.Leaflet ();
            main_leaflet.set_mode_transition_duration (250);
            main_leaflet.add (item_list);
            // main_leaflet.add (new Gtk.Separator (Gtk.Orientation.VERTICAL));
            main_leaflet.add (common_view);
            main_leaflet.set_can_swipe_back (true);
            main_leaflet.set_transition_type (Hdy.LeafletTransitionType.OVER);

            main_deck = new Hdy.Deck();
            //main_deck.can_swipe_back = true;
            main_deck.add (main_leaflet);

            // Create View Events
            item_list.item_selected.connect ((item) => {
                if (item == scientific_item) {
                    settings.view_index = 0;
                }
                else if (item == programmer_item) {
                    settings.view_index = 1;
                }
                else if (item == calculus_item) {
                    settings.view_index = 2;
                }
                else if (item == date_item) {
                    settings.view_index = 3;
                }
                else if (item == stats_item) {
                    settings.view_index = 4;
                }
                else if (item == conv_length_item) {
                    settings.view_index = 5;
                }
                else if (item == conv_area_item) {
                    settings.view_index = 6;
                }
                else if (item == conv_volume_item) {
                    settings.view_index = 7;
                }
                else if (item == conv_time_item) {
                    settings.view_index = 8;
                }
                else if (item == conv_angle_item) {
                    settings.view_index = 9;
                }
                else if (item == conv_speed_item) {
                    settings.view_index = 10;
                }
                else if (item == conv_mass_item) {
                    settings.view_index = 11;
                }
                else if (item == conv_press_item) {
                    settings.view_index = 12;
                }
                else if (item == conv_energy_item) {
                    settings.view_index = 13;
                }
                else if (item == conv_power_item) {
                    settings.view_index = 14;
                }
                else if (item == conv_temp_item) {
                    settings.view_index = 15;
                }
                else if (item == conv_data_item) {
                    settings.view_index = 16;
                }
                else if (item == conv_curr_item) {
                    settings.view_index = 17;
                }
                set_view ();
            });
            angle_unit_button_label_update ();
            word_length_button_label_update ();

            //  // Set up window attributes
            //  this.set_default_size (900, 600);
            //  this.set_size_request (900, 600);

            // Show all the stuff
            this.add (main_deck);
            this.show_all ();

            update_caps_status ();
            set_view ();
            common_view.set_transition_type (Gtk.StackTransitionType.SLIDE_UP_DOWN);
        }

        private void adjust_view (bool? pre_fold = false) {
            if ((this.common_view.get_visible_child () == this.scientific_view && this.scientific_view.button_leaflet.folded) ||
                (this.common_view.get_visible_child () == this.calculus_view && this.calculus_view.button_leaflet.folded) ||
                pre_fold) {
                header_switcher.set_visible (false);
                history_button.set_visible (false);
                history_item.set_visible (true);
            } else {
                header_switcher.set_visible (true);
                history_button.set_visible (true);
                history_item.set_visible (false);
            }
            if (main_leaflet.folded) {
                dark_mode_switch.set_visible (false);
                leaflet_back_button.set_visible (true);
            } else {
                dark_mode_switch.set_visible (true);
                leaflet_back_button.set_visible (false);
            }
            warning("adjusting");
        }

        private void set_view () {
            switch (settings.view_index) {
                case 0:
                common_view.set_visible_child (scientific_view);
                header_switcher.set_visible_child (scientific_header_grid);
                if (item_list.selected != scientific_item) {
                    item_list.selected = scientific_item;
                }
                break;
                case 1:
                common_view.set_visible_child (programmer_view);
                header_switcher.set_visible_child (programmer_header_grid);
                if (item_list.selected != programmer_item) {
                    item_list.selected = programmer_item;
                }
                break;
                case 2:
                common_view.set_visible_child (calculus_view);
                header_switcher.set_visible_child (scientific_header_grid);
                if (item_list.selected != calculus_item) {
                    item_list.selected = calculus_item;
                }
                break;
                case 3:
                common_view.set_visible_child (date_view);
                header_switcher.set_visible_child (date_mode_stack);
                if (item_list.selected != date_item) {
                    item_list.selected = date_item;
                }
                break;
                case 4:
                common_view.set_visible_child (statistics_view);
                header_switcher.set_visible_child (null_switcher);
                if (item_list.selected != stats_item) {
                    item_list.selected = stats_item;
                }
                break;
                case 5:
                common_view.set_visible_child (conv_length_view);
                header_switcher.set_visible_child (null_switcher);
                if (item_list.selected != conv_length_item) {
                    item_list.selected = conv_length_item;
                }
                break;
                case 6:
                common_view.set_visible_child (conv_area_view);
                header_switcher.set_visible_child (null_switcher);
                if (item_list.selected != conv_area_item) {
                    item_list.selected = conv_area_item;
                }
                break;
                case 7:
                common_view.set_visible_child (conv_volume_view);
                header_switcher.set_visible_child (null_switcher);
                if (item_list.selected != conv_volume_item) {
                    item_list.selected = conv_volume_item;
                }
                break;
                case 8:
                common_view.set_visible_child (conv_time_view);
                header_switcher.set_visible_child (null_switcher);
                if (item_list.selected != conv_time_item) {
                    item_list.selected = conv_time_item;
                }
                break;
                case 9:
                common_view.set_visible_child (conv_angle_view);
                header_switcher.set_visible_child (null_switcher);
                if (item_list.selected != conv_angle_item) {
                    item_list.selected = conv_angle_item;
                }
                break;
                case 10:
                common_view.set_visible_child (conv_speed_view);
                header_switcher.set_visible_child (null_switcher);
                if (item_list.selected != conv_speed_item) {
                    item_list.selected = conv_speed_item;
                }
                break;
                case 11:
                common_view.set_visible_child (conv_mass_view);
                header_switcher.set_visible_child (null_switcher);
                if (item_list.selected != conv_mass_item) {
                    item_list.selected = conv_mass_item;
                }
                break;
                case 12:
                common_view.set_visible_child (conv_press_view);
                header_switcher.set_visible_child (null_switcher);
                if (item_list.selected != conv_press_item) {
                    item_list.selected = conv_press_item;
                }
                break;
                case 13:
                common_view.set_visible_child (conv_energy_view);
                header_switcher.set_visible_child (null_switcher);
                if (item_list.selected != conv_energy_item) {
                    item_list.selected = conv_energy_item;
                }
                break;
                case 14:
                common_view.set_visible_child (conv_power_view);
                header_switcher.set_visible_child (null_switcher);
                if (item_list.selected != conv_power_item) {
                    item_list.selected = conv_power_item;
                }
                break;
                case 15:
                common_view.set_visible_child (conv_temp_view);
                header_switcher.set_visible_child (null_switcher);
                if (item_list.selected != conv_temp_item) {
                    item_list.selected = conv_temp_item;
                }
                break;
                case 16:
                common_view.set_visible_child (conv_data_view);
                header_switcher.set_visible_child (null_switcher);
                if (item_list.selected != conv_data_item) {
                    item_list.selected = conv_data_item;
                }
                break;
                case 17:
                common_view.set_visible_child (conv_curr_view);
                header_switcher.set_visible_child (update_button);
                if (!currency_view_visited) {
                    update_button.set_sensitive (false);
                    conv_curr_view.update_currency_data ();
                    currency_view_visited = true;
                }
                if (item_list.selected != conv_curr_item) {
                    item_list.selected = conv_curr_item;
                }
                break;
            }
            main_leaflet.set_visible_child (common_view);
            Timeout.add (200, () => {
                if (main_leaflet.get_child_transition_running ()) {
                    adjust_view (true);
                    return true;
                } else {
                    this.show_all ();
                    adjust_view ();
                    return false;
                }
            });
        }

        private void show_controls () {
            if (controls_modal == null) {
                controls_modal = new ControlsOverlay ();
                controls_modal.application = this.application;
                this.application.add_window (controls_modal);
                controls_modal.set_attached_to (this);

                controls_modal.set_transient_for (this);

                controls_modal.delete_event.connect (() => {
                    controls_modal = null;
                    return false;
                });
            }
            controls_modal.present ();
        }

        private void show_preferences () {
            if (preferences_modal == null) {
                preferences_modal = new PreferencesOverlay ();
                preferences_modal.application = this.application;
                this.application.add_window (preferences_modal);
                preferences_modal.set_attached_to (this);

                preferences_modal.set_transient_for (this);

                preferences_modal.delete_event.connect (() => {
                    preferences_modal = null;
                    return false;
                });

                preferences_modal.hide.connect (() => {
                    preferences_modal = null;
                });

                preferences_modal.update_settings.connect (() => {
                    scientific_view.load_constant_button_settings ();
                    calculus_view.load_constant_button_settings ();
                });
                preferences_modal.present ();
            }
        }

        private void show_history () {
            if (history_modal == null) {
                EvaluationResult.ResultSource result_source;
                print(settings.view_index.to_string());
                switch (settings.view_index) {
                    case 0:
                    result_source = EvaluationResult.ResultSource.SCIF;
                    break;
                    case 1:
                    result_source = EvaluationResult.ResultSource.PROG;
                    break;
                    case 2:
                    result_source = EvaluationResult.ResultSource.CALC;
                    break;
                    default:
                    result_source = EvaluationResult.ResultSource.SCIF;
                    break;
                }
                history_modal = new HistoryView (history_manager, result_source);
                history_modal.application = this.application;
                this.application.add_window (history_modal);
                history_modal.set_attached_to (this);

                history_modal.set_transient_for (this);

                history_modal.delete_event.connect (() => {
                    history_modal = null;
                    return false;
                });
                history_modal.clear.connect (() => {
                    settings.saved_history = "";
                    history_manager.clear_history ();
                    history_modal.close();
                    history_modal = null;
                });

                history_modal.select_eval_result.connect ((result) => {
                    settings = Pebbles.Settings.get_default ();
                    settings.global_angle_unit = result.angle_mode;
                    angle_unit_button_label_update ();

                    switch (result.result_source) {
                        case EvaluationResult.ResultSource.SCIF:
                        common_view.set_visible_child (scientific_view);
                        header_switcher.set_visible_child (scientific_header_grid);
                        settings.global_angle_unit = result.angle_mode;
                        angle_unit_button_label_update();
                        scientific_view.set_evaluation (result);
                        item_list.selected = scientific_item;
                        settings.view_index = 0;
                        break;
                        case EvaluationResult.ResultSource.CALC:
                        common_view.set_visible_child (calculus_view);
                        header_switcher.set_visible_child (scientific_header_grid);
                        item_list.selected = calculus_item;
                        settings.global_angle_unit = result.angle_mode;
                        angle_unit_button_label_update();
                        calculus_view.set_evaluation (result);
                        settings.view_index = 2;
                        break;
                        case EvaluationResult.ResultSource.PROG:
                        common_view.set_visible_child (programmer_view);
                        header_switcher.set_visible_child (programmer_header_grid);
                        item_list.selected = programmer_item;
                        settings.global_word_length = result.word_length;
                        word_length_button_label_update();
                        programmer_view.set_evaluation (result);
                        settings.view_index = 1;
                        break;
                    }
                });
                history_modal.insert_eval_result.connect ((result) => {
                    warning(result.result);
                    switch (settings.view_index) {
                        case 0:
                        scientific_view.insert_evaluation_result (result);
                        break;
                        case 1:
                        programmer_view.insert_evaluation_result (result);
                        break;
                        case 2:
                        calculus_view.insert_evaluation_result (result);
                        break;
                    }
                });
            }
            history_modal.present ();
        }

        private void angle_unit_button_label_update () {
            if (settings.global_angle_unit == Pebbles.GlobalAngleUnit.DEG) {
                angle_unit_button.update_label ("DEG", "<b>" + _("Degrees") + "</b> \xE2\x86\x92 " + _("Radians"), {"F8"});
                this.scientific_view.toolbar_angle_mode_button.update_label ("DEG", "<b>" + _("Degrees") + "</b> \xE2\x86\x92 " + _("Radians"), {"F8"});
                scientific_view.set_angle_mode_display (0);
                calculus_view.set_angle_mode_display (0);
            }
            else if (settings.global_angle_unit == Pebbles.GlobalAngleUnit.RAD) {
                angle_unit_button.update_label ("RAD", "<b>" + _("Radians") + "</b> \xE2\x86\x92 " + _("Gradians"), {"F8"});
                this.scientific_view.toolbar_angle_mode_button.update_label ("RAD", "<b>" + _("Radians") + "</b> \xE2\x86\x92 " + _("Gradians"), {"F8"});
                scientific_view.set_angle_mode_display (1);
                calculus_view.set_angle_mode_display (1);
            }
            else if (settings.global_angle_unit == Pebbles.GlobalAngleUnit.GRAD) {
                angle_unit_button.update_label ("GRA", "<b>" + _("Gradians") + "</b> \xE2\x86\x92 " + _("Degrees"), {"F8"});
                this.scientific_view.toolbar_angle_mode_button.update_label ("GRA", "<b>" + _("Gradians") + "</b> \xE2\x86\x92 " + _("Degrees"), {"F8"});
                scientific_view.set_angle_mode_display (2);
                calculus_view.set_angle_mode_display (2);
            }
            if (settings.view_index == 0) {
                this.scientific_view.display_unit.input_entry.grab_focus_without_selecting ();
            } else if (settings.view_index == 2) {
                this.calculus_view.display_unit.input_entry.grab_focus_without_selecting ();
            }
        }
        private void word_length_button_label_update () {
            if (settings.global_word_length == Pebbles.GlobalWordLength.QWD) {
                word_length_button.label = "QWD";
                word_length_button.tooltip_text = "QWORD";
                programmer_view.display_unit.set_word_length_status (0);
                programmer_view.bit_grid.set_bit_length_mode (3);
            }
            else if (settings.global_word_length == Pebbles.GlobalWordLength.DWD) {
                word_length_button.label = "DWD";
                word_length_button.tooltip_text = "DWORD";
                programmer_view.display_unit.set_word_length_status (1);
                programmer_view.bit_grid.set_bit_length_mode (2);
            }
            else if (settings.global_word_length == Pebbles.GlobalWordLength.WRD) {
                word_length_button.label = "WRD";
                word_length_button.tooltip_text = "WORD";
                programmer_view.display_unit.set_word_length_status (2);
                programmer_view.bit_grid.set_bit_length_mode (1);
            }
            else if (settings.global_word_length == Pebbles.GlobalWordLength.BYT) {
                word_length_button.label = "BYT";
                word_length_button.tooltip_text = "BYTE";
                programmer_view.display_unit.set_word_length_status (3);
                programmer_view.bit_grid.set_bit_length_mode (0);
            }
        }
        private void load_settings () {
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.use_dark_theme;
            if (settings.window_x < 0 || settings.window_y < 0 ) {
                this.window_position = Gtk.WindowPosition.CENTER;
            } else {
                this.move (settings.window_x, settings.window_y);
            }
            this.resize (settings.window_w, settings.window_h);
            if (settings.window_maximized) {
                this.maximize ();

            }
            if (settings.saved_history != "") {
                print("load\n");
                history_manager.load_from_csv (settings.saved_history);
                print("loaded\n");
            }
        }

        private void save_settings () {
            int x, y, w, h;
            this.get_position (out x, out y);
            settings.window_x = x;
            settings.window_y = y;

            this.get_size (out w, out h);
            settings.window_w = w;
            settings.window_h = h;

            settings.window_maximized = this.is_maximized;
            string history_csv = history_manager.to_csv ();
            settings.saved_history = history_csv;
        }

        private void handle_focus () {
            key_press_event.connect ((event) => {
                switch (settings.view_index) {
                    case 0:
                        scientific_view.key_pressed (event);
                        break;
                    case 1:
                        programmer_view.key_pressed (event);
                        break;
                    case 2:
                        calculus_view.key_pressed (event);
                        break;
                    case 3:
                        // TODO: Explicitly handle input in this mode
                        return false;
                    case 4:
                        statistics_view.key_pressed (event);
                        break;
                    case 5:
                        conv_length_view.key_press_event (event);
                        break;
                    case 6:
                        conv_area_view.key_press_event (event);
                        break;
                    case 7:
                        conv_volume_view.key_press_event (event);
                        break;
                    case 8:
                        conv_time_view.key_press_event (event);
                        break;
                    case 9:
                        conv_angle_view.key_press_event (event);
                        break;
                    case 10:
                        conv_speed_view.key_press_event (event);
                        break;
                    case 11:
                        conv_mass_view.key_press_event (event);
                        break;
                    case 12:
                        conv_press_view.key_press_event (event);
                        break;
                    case 13:
                        conv_energy_view.key_press_event (event);
                        break;
                    case 14:
                        conv_power_view.key_press_event (event);
                        break;
                    case 15:
                        conv_temp_view.key_press_event (event);
                        break;
                    case 16:
                        conv_data_view.key_press_event (event);
                        break;
                    case 17:
                        conv_curr_view.key_press_event (event);
                        break;
                }
                if (settings.view_index != 4 &&
                    (event.keyval == KeyboardHandler.KeyMap.NAV_LEFT ||
                    event.keyval == KeyboardHandler.KeyMap.NAV_RIGHT)
                ) {
                    return false;
                }
                if (event.keyval == 65505) {
                    keyboard_shift_status = true;
                }
                if (event.keyval == KeyboardHandler.KeyMap.F1) {
                    show_controls ();
                }
                if (event.keyval == KeyboardHandler.KeyMap.F2) {
                    show_preferences ();
                }
                if (event.keyval == KeyboardHandler.KeyMap.F8) {
                    if (settings.view_index == 0 || settings.view_index == 2) {
                        settings.switch_angle_unit ();
                        this.angle_unit_button_label_update ();
                    }
                }
                if (event.keyval == KeyboardHandler.KeyMap.CTRL) {
                    ctrl_held = true;
                }
                if(event.keyval == KeyboardHandler.KeyMap.V_LOWER || event.keyval == KeyboardHandler.KeyMap.V_UPPER) {
                    if (ctrl_held) {
                        return false;
                    }
                }
                return true;
            });
            key_release_event.connect ((event) => {
                switch (settings.view_index) {
                    case 0:
                        scientific_view.key_released (event);
                        break;
                    case 1:
                        programmer_view.key_released (event);
                        break;
                    case 2:
                        calculus_view.key_released (event);
                        break;
                    case 4:
                        statistics_view.key_released (event);
                        break;
                    case 5:
                        conv_length_view.key_release_event (event);
                        break;
                    case 6:
                        conv_area_view.key_release_event (event);
                        break;
                    case 7:
                        conv_volume_view.key_release_event (event);
                        break;
                    case 8:
                        conv_time_view.key_release_event (event);
                        break;
                    case 9:
                        conv_angle_view.key_release_event (event);
                        break;
                    case 10:
                        conv_speed_view.key_release_event (event);
                        break;
                    case 11:
                        conv_mass_view.key_release_event (event);
                        break;
                    case 12:
                        conv_press_view.key_release_event (event);
                        break;
                    case 13:
                        conv_energy_view.key_release_event (event);
                        break;
                    case 14:
                        conv_power_view.key_release_event (event);
                        break;
                    case 15:
                        conv_temp_view.key_release_event (event);
                        break;
                    case 16:
                        conv_data_view.key_release_event (event);
                        break;
                    case 17:
                        conv_curr_view.key_release_event (event);
                        break;
                }
                if (event.keyval == 65505) {
                    keyboard_shift_status = false;
                }
                if (event.keyval == KeyboardHandler.KeyMap.CTRL) {
                    ctrl_held = false;
                }
                return false;
            });
        }

        void update_caps_status () {
            bool caps_on = (keyboard_shift_status) ? !(keymap.get_caps_lock_state ()) : (keymap.get_caps_lock_state ());
            this.shift_switch.state_set (caps_on);
            this.shift_switch_prog.state_set (caps_on);
        }
    }
}
