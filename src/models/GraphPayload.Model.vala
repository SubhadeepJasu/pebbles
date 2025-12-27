// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Subhadeep Jasu <subhadeep107@proton.me>

namespace Pebbles {
    public class GraphPayloadModel : Object {
        public EquationModel[] equations { get; set; }
        public GlobalAngleUnit angle_unit { get; set; }
        public double var_a { get; set; }
        public double var_b { get; set; }
        public double var_c { get; set; }
        public double var_m { get; set; }
        public double x_min { get; set; }
        public double x_max { get; set; }
        public double y_min { get; set; }
        public double y_max { get; set; }
        public GraphAxisScaling x_scaling { get; set; }
        public GraphAxisScaling y_scaling { get; set; }
        public int width { get; set; }
        public int height { get; set; }
        public double dpi { get; set; }
        public bool dark_mode { get; set; }

        public bool contains_equations () {
            return equations != null;
        }
    }
}
