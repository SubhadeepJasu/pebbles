namespace Pebbles {
    [GtkTemplate (ui = "/com/github/subhadeepjasu/pebbles/ui/graphing_view.ui")]
    public class GraphingView : View {
        [GtkChild]
        private unowned Gtk.Stack graphing_stack;
        [GtkChild]
        private unowned Adw.NavigationSplitView graph_nav_split_view;
        [GtkChild]
        private unowned Gtk.Box equation_panel;
        [GtkChild]
        private unowned Gtk.Overlay graphing_panel;
        [GtkChild]
        private unowned EquationDisplay display;
        [GtkChild]
        private unowned GraphViewport viewport;
        [GtkChild]
        private unowned Gtk.Box variables_panel;
        [GtkChild]
        private unowned Pebbles.Button variable_button;
        [GtkChild]
        private unowned Gtk.ToggleButton shift_button;
        [GtkChild]
        private unowned Button pow_root_button;
        [GtkChild]
        private unowned Button expo_power_button;
        [GtkChild]
        private unowned Button sin_button;
        [GtkChild]
        private unowned Button sinh_button;
        [GtkChild]
        private unowned Button log_cont_base_button;
        [GtkChild]
        private unowned Button cos_button;
        [GtkChild]
        private unowned Button cosh_button;
        [GtkChild]
        private unowned Button log_mod_button;
        [GtkChild]
        private unowned Button tan_button;
        [GtkChild]
        private unowned Button tanh_button;
        [GtkChild]
        private unowned Pebbles.Button var_a_button;
        [GtkChild]
        private unowned Pebbles.Button var_m_button;
        [GtkChild]
        private unowned Gtk.SpinButton a_spinbutton;
        [GtkChild]
        private unowned Gtk.SpinButton b_spinbutton;
        [GtkChild]
        private unowned Gtk.SpinButton m_spinbutton;
        [GtkChild]
        private unowned Gtk.SpinButton c_spinbutton;

        protected string constant_label { get; private set; default = "C"; }
        protected string constant_desc { get; private set; default = ""; }
        protected Gtk.Adjustment var_a_adjustment { get; set; }
        protected Gtk.Adjustment var_b_adjustment { get; set; }
        protected Gtk.Adjustment var_c_adjustment { get; set; }
        protected Gtk.Adjustment var_m_adjustment { get; set; }

        public bool collapsed { get; set; }
        private bool variable_panel_showing = false;

        public signal void panel_changed (bool showing_graphs);
        public signal string on_memory_recall ();

        construct {
            load_constant_button ();
            Settings.get_default ().changed.connect ((key) => {
                if (key == "constant-key-value1" || key == "constant-key-value2") {
                    load_constant_button ();
                }
            });

            var_a_adjustment = new Gtk.Adjustment (0, -double.MAX, double.MAX, 0.01, 0.1, 0);
            var_b_adjustment = new Gtk.Adjustment (0, -double.MAX, double.MAX, 0.01, 0.1, 0);
            var_c_adjustment = new Gtk.Adjustment (0, -double.MAX, double.MAX, 0.01, 0.1, 0);
            var_m_adjustment = new Gtk.Adjustment (0, -double.MAX, double.MAX, 0.01, 0.1, 0);
        }

        public void render_graph (Gdk.Pixbuf? pixbuf, bool valid) {
            viewport.show_graph (pixbuf, valid);
        }

        public void send_shift_modifier (bool shifted) {
            shift_button.active = shifted;
            on_shift ();
        }

        [GtkCallback]
        protected void on_expand_fx () {
            graph_nav_split_view.show_content= true;
        }

        [GtkCallback]
        protected void on_collapse_fx () {
            graph_nav_split_view.show_content = false;
        }

        [GtkCallback]
        public void change_mode_handler (bool radial_mode) {
            if (radial_mode) {
                variable_button.label_text = "θ";
                variable_button.tooltip_desc = "Variable θ";
            } else {
                variable_button.label_text = "<i>X</i>";
                variable_button.tooltip_desc = "Variable x";
            }
        }

        [GtkCallback]
        public void show_graph_panel () {
            if (graphing_stack.visible_child != graphing_panel) {
                graphing_stack.visible_child = graphing_panel;
                panel_changed (true);
                Idle.add (() => {
                    if (!graphing_stack.transition_running) {
                        viewport.render (display.equations);
                        return false;
                    }

                    return true;
                });
            }
        }

        [GtkCallback]
        public void show_equation_panel () {
            if (graphing_stack.visible_child != equation_panel) {
                graphing_stack.visible_child = equation_panel;
                panel_changed (false);
            }
        }

        [GtkCallback]
        protected void add_equation () {
            display.add_equation ();
        }

        [GtkCallback]
        protected void toggle_variable_panel (Gtk.Widget widget) {
            variable_panel_showing = ((Gtk.ToggleButton) widget).active;
            if (variable_panel_showing) {
                variables_panel.add_css_class ("show");
                variables_panel.can_target = true;
            } else {
                variables_panel.remove_css_class ("show");
                variables_panel.can_target = false;
            }
        }

        [GtkCallback]
        protected void on_all_clear () {
            display.all_clear ();
        }

        [GtkCallback]
        protected void on_backspace () {
            display.backspace ();
        }

        [GtkCallback]
        protected void on_click_button (Gtk.Button btn) {
            display.write (btn.name);
        }

        [GtkCallback]
        protected void on_click_function (Gtk.Button btn) {
            display.write (shift_button.active ? btn.name.up () : btn.name);
        }

        [GtkCallback]
        protected void on_shift () {
            pow_root_button.label_text = shift_button.active ? "<sup>n</sup>√" : "x<sup>y</sup>";
            pow_root_button.tooltip_desc = shift_button.active
            ? _("Square root over number") : _("x raised to the power y");
            expo_power_button.label_text = shift_button.active ? "e<sup>x</sup>" : "10<sup>x</sup>";
            expo_power_button.tooltip_desc = shift_button.active
            ? _("e raised to the power x") : _("10 raised to the power x");
            sin_button.label_text = shift_button.active ? "sin<sup>-1</sup>" : "sin";
            sin_button.tooltip_desc = shift_button.active ? _("Inverse Sine") : _("Sine");
            cos_button.label_text = shift_button.active ? "cos<sup>-1</sup>" : "cos";
            cos_button.tooltip_desc = shift_button.active ? _("Inverse Cosine") : _("Cosine");
            tan_button.label_text = shift_button.active ? "tan<sup>-1</sup>" : "tan";
            tan_button.tooltip_desc = shift_button.active ? _("Inverse Tangent") : _("Tangent");
            sinh_button.label_text = shift_button.active ? "sinh<sup>-1</sup>" : "sinh";
            sinh_button.tooltip_desc = shift_button.active ? _("Inverse Hyperbolic Sine") : _("Hyperbolic Sine");
            cosh_button.label_text = shift_button.active ? "cosh<sup>-1</sup>" : "cosh";
            cosh_button.tooltip_desc = shift_button.active ? _("Inverse Hyperbolic Cosine") : _("Hyperbolic Cosine");
            tanh_button.label_text = shift_button.active ? "tanh<sup>-1</sup>" : "tan";
            tanh_button.tooltip_desc = shift_button.active ? _("Inverse Hyperbolic Tangent") : _("Hyperbolic Tangent");
            log_mod_button.label_text = shift_button.active ? "log<sub>x</sub>y" : "mod";
            log_mod_button.tooltip_desc = shift_button.active ? _("Log Base x") : _("Modulus");
            log_cont_base_button.label_text = shift_button.active ? "ln x" : "log x";
            log_cont_base_button.tooltip_desc = shift_button.active ? _("Natural Logarithm") : _("Log Base 10");
            var_a_button.label_text = shift_button.active ? "<i>b</i>" : "<i>a</i>";
            var_a_button.tooltip_desc = shift_button.active ? _("Variable b") : _("Variable a");
            var_m_button.label_text = shift_button.active ? "<i>c</i>" : "<i>m</i>";
            var_m_button.tooltip_desc = shift_button.active ? _("Variable c") : _("Variable m");

            load_constant_button ();
        }

        private void load_constant_button () {
            var settings = Pebbles.Settings.get_default ();

            var key = shift_button.active ? settings.constant_key_value2 : settings.constant_key_value1;
            switch (key) {
                case ARCHIMEDES:
                    constant_label = "π";
                    constant_desc = _("Archimedes' constant (pi)");
                    break;
                case IMAGINARY:
                    constant_label = "j";
                    constant_desc = _("Imaginary Number (√-1)");
                    break;
                case GOLDEN_RATIO:
                    constant_label = "\xCF\x86";
                    constant_desc = _("Golden ratio (phi)");
                    break;
                case EULER_MASCH:
                    constant_label = "\xF0\x9D\x9B\xBE";
                    constant_desc = _("Euler–Mascheroni constant (gamma)");
                    break;
                case CONWAY:
                    constant_label = "\xCE\xBB";
                    constant_desc = _("Conway's constant (lambda)");
                    break;
                case KHINCHIN:
                    constant_label = "K";
                    constant_desc = _("Khinchin's constant");
                    break;
                case FEIGEN_ALPHA:
                    constant_label = "\xCE\xB1";
                    constant_desc = _("The Feigenbaum constant alpha");
                    break;
                case FEIGEN_DELTA:
                    constant_label = "\xCE\xB4";
                    constant_desc = _("The Feigenbaum constant delta");
                    break;
                case APERY:
                    constant_label = "\xF0\x9D\x9B\x87(3)";
                    constant_desc = _("Apery's constant");
                    break;
                default:
                    constant_label = "e";
                    constant_desc = _("Euler's constant (exponential)");
                    break;
            }
        }

        public void set_global_memory_present (bool present) {
            display.set_global_memory_present (present);
        }

        [GtkCallback]
        protected void on_click_var_button_a () {
            display.write (shift_button.active ? "b" : "a", true);
        }

        [GtkCallback]
        protected void on_click_var_button_m () {
            display.write (shift_button.active ? "c" : "m", true);
        }

        [GtkCallback]
        protected void on_update_var_a () {
            viewport.var_a = a_spinbutton.value;
        }

        [GtkCallback]
        protected void on_update_var_b () {
            viewport.var_b = b_spinbutton.value;
        }

        [GtkCallback]
        protected void on_update_var_m () {
            viewport.var_m = m_spinbutton.value;
        }

        [GtkCallback]
        protected void on_update_var_c () {
            viewport.var_c = c_spinbutton.value;
        }

        [GtkCallback]
        protected void on_click_add_button () {
            display.write ("+");
        }

        [GtkCallback]
        protected void on_click_sub_button () {
            display.write ("-");
        }

        [GtkCallback]
        protected void on_click_mul_button () {
            display.write ("*");
        }

        [GtkCallback]
        protected void on_click_div_button () {
            display.write ("/");
        }

        [GtkCallback]
        protected void on_click_fraction_point () {
            display.write (_("."));
        }

        [GtkCallback]
        protected void on_click_constant (Gtk.Button button) {
            display.write (((Button) button).label_text);
        }

        [GtkCallback]
        protected void on_click_last_ans () {
            display.write ("Gans");
        }

        [GtkCallback]
        protected void navigate_up () {
            display.navigate (true);
        }

        [GtkCallback]
        protected void navigate_down () {
            display.navigate (false);
        }

        [GtkCallback]
        public void on_click_memory_recall () {
            var text = on_memory_recall ();
            display.write (text);
        }

        [GtkCallback]
        protected void export_image () {
            var main_window = (MainWindow) get_ancestor (typeof (MainWindow));

            var png_file_filter = new Gtk.FileFilter () {
                name = _("PNG Files"),
            };
            png_file_filter.add_mime_type ("image/png");

            var filter_model = new ListStore (typeof (Gtk.FileFilter));
            filter_model.append (png_file_filter);

            var file_dialog = new Gtk.FileDialog () {
                accept_label = _("Export"),
                default_filter = png_file_filter,
                filters = filter_model,
                modal = true,
                title = _("Export as PNG")
            };

            file_dialog.save.begin (main_window, null, (obj, result) => {
                try {
                    var file = file_dialog.save.end (result);
                    if (file != null) {
                        string? file_path = file.get_path ();
                        if (file_path != null) {
                            main_window.on_graph_export (file_path);  // Call Python to save PNG
                            main_window.send_toast (_("Exported graph as image!"));
                        }
                    }
                } catch (Error e) {
                    print ("Failed to save file: %s\n", e.message);
                }
            });
        }

        public override void focus_main () {

        }
    }
}
