/*
 * SPDX-FileCopyrightText: Copyright 2019-2025 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Pebbles {
    /**
     * Actions that can be performed in the application.
     */
    public class Actions {
        public const string PREFIX = "win.";
        public const string COPY = "copy";
        public const string PASTE = "paste";
        public const string CONTROLS = "controls";
        public const string PREFERENCES = "preferences";
        public const string SCIENTIFIC = "scientific";
        public const string CALCULUS = "calculus";
        public const string PROGRAMMER = "programmer";
        public const string STATISTICS = "statistics";
        public const string GRAPHING = "graphing";
        public const string DATE = "date";
        public const string CONV_LENGTH = "conv_length";
        public const string CONV_AREA = "conv_area";
        public const string CONV_VOLUME = "conv_volume";
        public const string CONV_TIME = "conv_time";
        public const string CONV_ANGLE = "conv_angle";
        public const string CONV_SPEED = "conv_speed";
        public const string CONV_MASS = "conv_mass";
        public const string CONV_PRESSURE = "conv_pressure";
        public const string CONV_ENERGY = "conv_energy";
        public const string CONV_POWER = "conv_power";
        public const string CONV_TEMP = "conv_temp";
        public const string CONV_DATA = "conv_data";
        public const string CONV_CURRENCY = "conv_currency";
    }

    public errordomain EnumError {
        UNKNOWN_VALUE
    }

    /**
     * The context or mode a calculation is performed in.
     */
    public class Context {
        public const string GLOBAL = "global";
        public const string SCIENTIFIC = "sci";
        public const string CALCULUS = "calc";
        public const string PROGRAMMER = "prog";
        public const string STATISTICS = "stat";
        public const string GRAPHING = "graph";
        public const string DATE = "date";
        public const string CONV_LEN = "conv.length";
        public const string CONV_AREA = "conv.area";
        public const string CONV_VOL = "conv.volume";
        public const string CONV_TIME = "conv.time";
        public const string CONV_ANGLE = "conv.angle";
        public const string CONV_SPEED = "conv.speed";
        public const string CONV_MASS = "conv.mass";
        public const string CONV_PRES = "conv.pressure";
        public const string CONV_ENERGY = "conv.energy";
        public const string CONV_POWER = "conv.power";
        public const string CONV_TEMP = "conv.temperature";
        public const string CONV_DATA = "conv.data";
        public const string CONV_CURR = "conv.currency";
    }

    /**
     * Statistical Operation.
     */
    public enum StatOp {
        LOAD_DATASET,
        CLEAR_DATASET,
        CLEAR_SERIES,
        SHAPE,
        MEDIAN,
        MODE,
        SUM,
        SUM_SQUARED,
        MEAN,
        MEAN_SQUARED,
        GEOMETRIC_MEAN,
        SAMPLE_VAR,
        POPULATION_VAR,
        SAMPLE_SD,
        POPULATION_SD,
        TREND;

        public static bool try_parse_name (string name, out StatOp result = null) {
            EnumClass enumc = (EnumClass) typeof (StatOp).class_ref ();
            unowned EnumValue? eval = enumc.get_value_by_name ("PEBBLES_STAT_OP_" + name);
            if (eval == null) {
                result = StatOp.SHAPE;
                return false;
            }

            result = (StatOp) eval.value;
            return true;
        }
    }

    /**
     * Convert statistical operation to human-readable expression.
     *
     * @param op The statistical operation.
     * @return The human-readable expression.
     */
    public static string stat_op_to_exp (StatOp op) {
        var exp = "";
        switch (op) {
            case SHAPE:
                exp = _("Dataset Shape");
                break;
            case MEDIAN:
                exp = _("Median");
                break;
            case MODE:
                exp = _("Mode");
                break;
            case SUM:
                exp = _("Sum");
                break;
            case SUM_SQUARED:
                exp = _("Sum of Squared Values");
                break;
            case MEAN:
                exp = _("Mean");
                break;
            case MEAN_SQUARED:
                exp = _("Mean of Squared Values");
                break;
            case GEOMETRIC_MEAN:
                exp = _("Geometric Mean");
                break;
            case SAMPLE_VAR:
                exp = _("Sample Variance");
                break;
            case POPULATION_VAR:
                exp = _("Population Variance");
                break;
            case SAMPLE_SD:
                exp = _("Standard Deviation");
                break;
            case POPULATION_SD:
                exp = _("Population Standard Deviation");
                break;
            case TREND:
                exp = _("Estimate Trend");
                break;
            default:
                exp = _("Unknown");
                break;
        }

        return exp;
    }

    /**
     * Memory append operation.
     */
    public enum MemAppendOp {
        SUBTRACT_GLOBAL = -2,
        SUBTRACT = -1,
        NONE = 0,
        ADD = 1,
        ADD_GLOBAL = 2
    }

    /** Specify angle unit to use (degrees, radians or gradient).
     *  Its used in the upper left corner of the app.
     */
    public enum GlobalAngleUnit {
        DEG,
        RAD,
        GRAD
    }

    /** Specify the word length to use (qword, dword, word or byte)
     *  Its used in the upper left corner of the app.
     */
    public enum GlobalWordLength {
        QWD,
        DWD,
        WRD,
        BYT
    }

    /** Specify the number system to use
     *  Its used in programmer mode
     */
    public enum NumberSystem {
        BINARY,
        OCTAL,
        DECIMAL,
        HEXADECIMAL
    }

    /** Specify the variable constant key's
     *  both normal and alternative values.
     */
    public enum ConstantKeyIndex {
        EULER,
        ARCHIMEDES,
        GOLDEN_RATIO,
        IMAGINARY,
        EULER_MASCH,
        CONWAY,
        KHINCHIN,
        FEIGEN_ALPHA,
        FEIGEN_DELTA,
        APERY
    }

    /**
     * Specify the kind of plot to query from
     * matplotlib for Statistics mode.
     */
    public enum StatPlotType {
        LINE = 0,
        PIE = 1,
        BAR = 2,
        SCATTER = 3
    }

    /**
     * Color palette for graph plotting.
     */
    public const string[] PALETTE = {
        "#272863", "#3689e6", "#c6262e", "#3a9104", "#d48e15", "#f37329",
        "#bc245d", "#7239b3", "#b6802e", "#57392d", "#485a6c", "#333333"
    };

    /**
     * Dark color palette for graph plotting.
     */
    public const string[] PALETTE_DARK = {
        "#FFFFFF", "#3689e6", "#c6262e", "#3a9104", "#d48e15", "#f37329",
        "#bc245d", "#7239b3", "#b6802e", "#57392d", "#485a6c", "#333333"
    };

    /**
     * Get color palette for graph plotting.
     * @param dark Whether to return dark palette or not
     */
    public static string[] get_palette (bool dark = false) {
        return dark ? PALETTE_DARK : PALETTE;
    }

    /**
     * Graph Axis Scaling.
     */
    public enum GraphAxisScaling {
        LINEAR,
        LOGARITHMIC
    }

    /**
     * Get the local radix symbol or decimal point symbol.
     */
    public static unowned string get_local_radix_symbol () {
        return Posix.nl_langinfo (Posix.NLItem.RADIXCHAR);
    }

    /**
     * Get the local large number separator symbol.
     */
    public static unowned string get_local_separator_symbol () {
        return Posix.nl_langinfo (Posix.NLItem.THOUSEP);
    }

    /**
     * Remove leading zeroes from a string representing a number.
     *
     * @param text The input string.
     * @return The string without leading zeroes.
     */
    public static string remove_leading_zeroes (string text) {
        if (text == "0") {
            return "0";
        }
        int n = -1;
        for (int i = 0; i < text.length; i++) {
            if (text.get_char (i) != '0') {
                n = i;
                break;
            }
        }
        return text.substring (n);
    }

    /**
     * Insert separator symbol in large numbers
     */
    public static string insert_separator_symbol (string text) {
        StringBuilder output_builder = new StringBuilder (text);
        var decimal_pos = text.last_index_of (get_local_radix_symbol ());
        if (decimal_pos == -1) {
            decimal_pos = text.length;
        }
        int end_position = 0;

        // Take care of minus sign at the beginning of string, if any
        if (text.has_prefix ("-")) {
            end_position = 1;
        }

        for (int i = decimal_pos - 3; i > end_position; i -= 3) {
            output_builder.insert (i, get_local_separator_symbol ());
        }

        return output_builder.str;
    }
}
