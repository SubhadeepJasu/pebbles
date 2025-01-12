namespace Pebbles {
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
}
