package ta.func;

inline function RoundPos(x:Float):Float {
    return (Math.ffloor((x) + 0.5));
}

inline function RoundNeg(x:Float):Float {
    return (Math.fceil((x) - 0.5));
}

inline function RoundPos2(x:Float):Float {
    return ((Math.ffloor((x * 100.0) + 0.5)) / 100.0);
}

inline function RoundNeg2(x:Float):Float {
    return ((Math.fceil((x * 100.0) - 0.5)) / 100.0);
}

// inline function RealEQ() {}

inline function IsZero(v:Float):Bool {
    return (((-0.00000001) < v) && (v < 0.00000001));
}

inline function IsZeroOrNeg(v:Float):Bool {
    return (v < 0.00000001);
}
