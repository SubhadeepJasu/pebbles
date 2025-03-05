namespace Pebbles {
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
        public const string CONV_LEN = "conv.len";
        public const string CONV_AREA = "conv.area";
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
}
