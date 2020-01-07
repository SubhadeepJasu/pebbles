/*-
 * Copyright (c) 2017-2018 Subhadeep Jasu <subhajasu@gmail.com>
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
        // CONTROLS
        Gtk.HeaderBar headerbar;
        Granite.ModeSwitch dark_mode_switch;
        Pebbles.Settings settings;
        Gtk.MenuButton app_menu;
        
        // Switchable Controls
        public Gtk.Stack header_switcher;
        
        Gtk.Grid scientific_header_grid;
        Gtk.Label shift_label;
        public Gtk.Switch shift_switch;
        Gtk.Button angle_unit_button;
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


        ControlsOverlay controls_modal;
        // Active View Index
        private int view_index = 0;
        
        // NOTIFICATION
        Notification desktop_notification;
        
        // History
        public List<string> history_stack;
        private bool currency_view_visited = false;

        public MainWindow () {
            load_settings ();
            make_ui ();
            handle_focus ();
        }

        construct {
            settings = Pebbles.Settings.get_default ();
            settings.notify["use-dark-theme"].connect (() => {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = settings.use_dark_theme;
            });
            this.delete_event.connect (() => {
                save_settings ();
            });
            history_stack = new List<string> ();
        }
        
        public void make_ui () {
            // Create dark mode switcher
            dark_mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic");
            dark_mode_switch.primary_icon_tooltip_text = ("Light background");
            dark_mode_switch.secondary_icon_tooltip_text = ("Dark background");
            dark_mode_switch.valign = Gtk.Align.CENTER;
            dark_mode_switch.active = settings.use_dark_theme;
            dark_mode_switch.notify["active"].connect (() => {
                settings.use_dark_theme = dark_mode_switch.active;
            });
            
            // Make Scientific / Calculus View Controls ///////////////
            // Create angle unit button
            angle_unit_button = new Gtk.Button.with_label ("DEG");
            angle_unit_button.tooltip_text = "Degrees";
            angle_unit_button.set_margin_end (7);
            angle_unit_button.width_request = 50;
            angle_unit_button.clicked.connect (() => {
                settings.switch_angle_unit ();
                angle_unit_button_label_update ();
            });
            
            // Create shift switcher
            scientific_header_grid = new Gtk.Grid ();
            shift_label = new Gtk.Label ("Shift ");
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
            var programmer_header_grid = new Gtk.Grid ();
            var shift_label_prog = new Gtk.Label ("Shift ");
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
            var null_switcher = new Gtk.Label ("");
            
            // Make currency update switcher
            update_button = new Gtk.Button.from_icon_name ("view-refresh-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            update_button.width_request = 10;
            update_button.halign = Gtk.Align.START;
            update_button.margin = 1;
            update_button.set_tooltip_markup ("<b>Update Currency Data</b>\nUpdates automatically every 10 minutes");
            
            // Create App Menu
            app_menu = new Gtk.MenuButton ();
            app_menu.valign = Gtk.Align.CENTER;
            app_menu.set_image (new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
            
            var settings_menu = new Gtk.Menu ();
            var menu_item_constants_item = new Gtk.MenuItem.with_label ("Configure Constant Button");
            var controls_overlay_item = new Gtk.MenuItem.with_label ("Show Controls");

            settings_menu.append (menu_item_constants_item);
            settings_menu.append (controls_overlay_item);
            settings_menu.show_all();

            controls_overlay_item.activate.connect (() => {
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
                
            });
            
            app_menu.popup = settings_menu;
            
            // Create History Button
            history_button = new Gtk.Button ();
            history_button.valign = Gtk.Align.CENTER;
            history_button.set_image (new Gtk.Image.from_icon_name ("document-open-recent-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
            history_button.set_margin_end (4);
            
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
            //headerbar.pack_start (angle_unit_button);
            headerbar.pack_start (header_switcher);
            headerbar.pack_end (history_button);
            headerbar.pack_end (app_menu);
            headerbar.pack_end (dark_mode_switch);// Uncomment to use dark mode switch
            this.set_titlebar (headerbar);
            
            // Create Item Pane
            var scientific_item  = new Granite.Widgets.SourceList.Item ("Scientific");
            var calculus_item    = new Granite.Widgets.SourceList.Item ("Calculus");
            var programmer_item  = new Granite.Widgets.SourceList.Item ("Programmer");
            var date_item        = new Granite.Widgets.SourceList.Item ("Date");
            var stats_item       = new Granite.Widgets.SourceList.Item ("Statistics");
            var finance_item     = new Granite.Widgets.SourceList.Item ("Financial");
            var conv_length_item = new Granite.Widgets.SourceList.Item ("Length");
            var conv_area_item   = new Granite.Widgets.SourceList.Item ("Area");
            var conv_volume_item = new Granite.Widgets.SourceList.Item ("Volume");
            var conv_time_item   = new Granite.Widgets.SourceList.Item ("Time");
            var conv_angle_item  = new Granite.Widgets.SourceList.Item ("Angle");
            var conv_speed_item  = new Granite.Widgets.SourceList.Item ("Speed");
            var conv_mass_item   = new Granite.Widgets.SourceList.Item ("Mass");
            var conv_press_item  = new Granite.Widgets.SourceList.Item ("Pressure");
            var conv_energy_item = new Granite.Widgets.SourceList.Item ("Energy");
            var conv_power_item  = new Granite.Widgets.SourceList.Item ("Power");
            var conv_temp_item   = new Granite.Widgets.SourceList.Item ("Temperature");
            var conv_data_item   = new Granite.Widgets.SourceList.Item ("Data");
            var conv_curr_item   = new Granite.Widgets.SourceList.Item ("Currency");
            
            // Calculators
            var calc_category = new Granite.Widgets.SourceList.ExpandableItem ("Calculator");
            calc_category.expand_all ();
            calc_category.add (scientific_item);
            calc_category.add (calculus_item);
            calc_category.add (programmer_item);
            calc_category.add (date_item);
            calc_category.add (stats_item);
            //calc_category.add (finance_item);
            // Converters
            var conv_category = new Granite.Widgets.SourceList.ExpandableItem ("Converter");
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

            var item_list = new Granite.Widgets.SourceList ();
            item_list.root.add (calc_category);
            item_list.root.add (conv_category);
            item_list.width_request = 170;
            
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
            
            update_button.clicked.connect (() => {
                update_button.set_sensitive (false);
                conv_curr_view.update_currency_data ();
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
            var common_view = new Gtk.Stack ();
            common_view.valign = Gtk.Align.CENTER;
            common_view.halign = Gtk.Align.CENTER;
            common_view.add_named (scientific_view, "Scientific");
            common_view.add_named (calculus_view, "Calculus");
            common_view.add_named (programmer_view, "Programmer");
            common_view.add_named (date_view, "Date");
            common_view.add_named (statistics_view, "Statistics");
            common_view.add_named (conv_length_view, "Length");
            common_view.add_named (conv_area_view, "Area");
            common_view.add_named (conv_volume_view, "Volume");
            common_view.add_named (conv_time_view, "Time");
            common_view.add_named (conv_angle_view, "Angle");
            common_view.add_named (conv_speed_view, "Speed");
            common_view.add_named (conv_mass_view, "Mass");
            common_view.add_named (conv_press_view, "Pressure");
            common_view.add_named (conv_energy_view, "Energy");
            common_view.add_named (conv_power_view, "Power");
            common_view.add_named (conv_temp_view, "Temperature");
            common_view.add_named (conv_data_view, "Data");
            common_view.add_named (conv_curr_view, "Currency");
            
            common_view.set_transition_type (Gtk.StackTransitionType.SLIDE_UP_DOWN);
            
            //Create Panes
            var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            paned.position = 200;
            paned.position_set = true;
            paned.pack1 (item_list, false, false);
            paned.pack2 (common_view, false, false);

            // Create View Events
            item_list.item_selected.connect ((item) => {
                if (item == scientific_item) {
                    common_view.set_visible_child (scientific_view);
                    header_switcher.set_visible_child (scientific_header_grid);
                    view_index = 0;
                }
                else if (item == programmer_item) {
                    common_view.set_visible_child (programmer_view);
                    header_switcher.set_visible_child (programmer_header_grid);
                    view_index = 1;
                }
                else if (item == calculus_item) {
                    common_view.set_visible_child (calculus_view);
                    header_switcher.set_visible_child (scientific_header_grid);
                    view_index = 2;
                }
                else if (item == date_item) {
                    common_view.set_visible_child (date_view);
                    header_switcher.set_visible_child (date_mode_stack);
                    view_index = 3;
                }
                else if (item == stats_item) {
                    common_view.set_visible_child (statistics_view);
                    header_switcher.set_visible_child (null_switcher);
                    view_index = 4;
                }
                else if (item == conv_length_item) {
                    common_view.set_visible_child (conv_length_view);
                    header_switcher.set_visible_child (null_switcher);
                    view_index = 5;
                }
                else if (item == conv_area_item) {
                    common_view.set_visible_child (conv_area_view);
                    header_switcher.set_visible_child (null_switcher);
                    view_index = 6;
                }
                else if (item == conv_volume_item) {
                    common_view.set_visible_child (conv_volume_view);
                    header_switcher.set_visible_child (null_switcher);
                    view_index = 7;
                }
                else if (item == conv_time_item) {
                    common_view.set_visible_child (conv_time_view);
                    header_switcher.set_visible_child (null_switcher);
                    view_index = 8;
                }
                else if (item == conv_angle_item) {
                    common_view.set_visible_child (conv_angle_view);
                    header_switcher.set_visible_child (null_switcher);
                    view_index = 9;
                }
                else if (item == conv_speed_item) {
                    common_view.set_visible_child (conv_speed_view);
                    header_switcher.set_visible_child (null_switcher);
                    view_index = 10;
                }
                else if (item == conv_mass_item) {
                    common_view.set_visible_child (conv_mass_view);
                    header_switcher.set_visible_child (null_switcher);
                    view_index = 11;
                }
                else if (item == conv_press_item) {
                    common_view.set_visible_child (conv_press_view);
                    header_switcher.set_visible_child (null_switcher);
                    view_index = 12;
                }
                else if (item == conv_energy_item) {
                    common_view.set_visible_child (conv_energy_view);
                    header_switcher.set_visible_child (null_switcher);
                    view_index = 13;
                }
                else if (item == conv_power_item) {
                    common_view.set_visible_child (conv_power_view);
                    header_switcher.set_visible_child (null_switcher);
                    view_index = 14;
                }
                else if (item == conv_temp_item) {
                    common_view.set_visible_child (conv_temp_view);
                    header_switcher.set_visible_child (null_switcher);
                    view_index = 15;
                }
                else if (item == conv_data_item) {
                    common_view.set_visible_child (conv_data_view);
                    header_switcher.set_visible_child (null_switcher);
                    view_index = 16;
                }
                else if (item == conv_curr_item) {
                    common_view.set_visible_child (conv_curr_view);
                    header_switcher.set_visible_child (update_button);
                    view_index = 17;
                    if (!currency_view_visited) {
                        update_button.set_sensitive (false);
                        conv_curr_view.update_currency_data ();
                        currency_view_visited = true;
                    }
                }
                this.show_all ();
            });
            angle_unit_button_label_update ();
            word_length_button_label_update ();
            item_list.selected = scientific_item;

            // Set up window attributes
            this.set_default_size (900, 600);
            this.set_size_request (900, 600);

            // Show all the stuff
            this.add (paned);
            this.set_resizable (false);
            this.show_all ();
        }

        public void answer_notify () {
            if (desktop_notification == null) {
                desktop_notification = new Notification ("");
            }
            if (history_stack.length () > 0) {
                unowned List<string>? last_answer = history_stack.last ();
                desktop_notification.set_title ("Copied to Clipboard");
                desktop_notification.set_body (last_answer.data);
                this.application.send_notification (PebblesApp.instance.application_id, desktop_notification);

                stdout.printf ("[STATUS]  Pebbles: Notification sent\n");
                
                // Manage clipboard
                Gdk.Display display = this.get_display ();
                Gtk.Clipboard clipboard = Gtk.Clipboard.get_for_display (display, Gdk.SELECTION_CLIPBOARD);
                clipboard.set_text (last_answer.data, -1);
            }
            else {
                desktop_notification.set_title ("History Empty!");
                desktop_notification.set_body ("Nothing has been calculated yet");
                this.application.send_notification (PebblesApp.instance.application_id, desktop_notification);

                stdout.printf ("[WARNING] Pebbles: History is empty\n");
            }
        }
        private void angle_unit_button_label_update () {
            if (settings.global_angle_unit == Pebbles.GlobalAngleUnit.DEG) {
                angle_unit_button.label = "DEG";
                angle_unit_button.tooltip_text = "Degrees";
                scientific_view.set_angle_mode_display (0);
                calculus_view.set_angle_mode_display (0);
            }
            else if (settings.global_angle_unit == Pebbles.GlobalAngleUnit.RAD) {
                angle_unit_button.label = "RAD";
                angle_unit_button.tooltip_text = "Radians";
                scientific_view.set_angle_mode_display (1);
                calculus_view.set_angle_mode_display (1);
            }
            else if (settings.global_angle_unit == Pebbles.GlobalAngleUnit.GRAD) {
                angle_unit_button.label = "GRA";
                angle_unit_button.tooltip_text = "Gradians";
                scientific_view.set_angle_mode_display (2);
                calculus_view.set_angle_mode_display (2);
            }
        }
        private void word_length_button_label_update () {
            if (settings.global_word_length == Pebbles.GlobalAngleUnit.QWD) {
                word_length_button.label = "QWD";
                word_length_button.tooltip_text = "QWORD";
                programmer_view.display_unit.set_word_length_status (0);
                programmer_view.bit_grid.set_bit_length_mode (3);
            }
            else if (settings.global_word_length == Pebbles.GlobalAngleUnit.DWD) {
                word_length_button.label = "DWD";
                word_length_button.tooltip_text = "DWORD";
                programmer_view.display_unit.set_word_length_status (1);
                programmer_view.bit_grid.set_bit_length_mode (2);
            }
            else if (settings.global_word_length == Pebbles.GlobalAngleUnit.WRD) {
                word_length_button.label = "WRD";
                word_length_button.tooltip_text = "WORD";
                programmer_view.display_unit.set_word_length_status (2);
                programmer_view.bit_grid.set_bit_length_mode (1);
            }
            else if (settings.global_word_length == Pebbles.GlobalAngleUnit.BYT) {
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
        }

        private void save_settings () {
            int x, y;
            this.get_position (out x, out y);
            settings.window_x = x;
            settings.window_y = y;
        }

        private void handle_focus () {
            key_press_event.connect ((event) => {
                switch (view_index) {
                    case 0: 
                        scientific_view.display_unit.input_entry.grab_focus_without_selecting ();
                        if (scientific_view.display_unit.input_entry.get_text () == "0" && scientific_view.display_unit.input_entry.cursor_position == 0)
                            scientific_view.display_unit.input_entry.move_cursor (Gtk.MovementStep.DISPLAY_LINE_ENDS, 0, false);
                        break;
                    case 4:
                        statistics_view.grab_focus ();
                        statistics_view.key_pressed (event);
                        break;
                    case 5:
                        conv_length_view.key_press_event (event);
                        break;
                }
                return true;
            });
            key_release_event.connect ((event) => {
                switch (view_index) {
                    case 4:
                        statistics_view.key_released ();
                        break;
                }
                return false;
            });
        }

    }
}
