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

// HILBERT_VARIABLES(varName) :
// var #_Odd:Array<Float> = [0.0, 0.0, 0.0]; // size: 3
// var #_Even:Array<Float> = [0.0, 0.0, 0.0]; // size: 3
// var #:Float;
// var prev_#_Odd:Float;
// var prev_#_Even:Float;
// var prev_#_input_Odd:Float;
// var prev_#_input_Even:Float;

// INIT_HILBERT_VARIABLES(varName) :
// #_Odd[0] = 0.0;
// #_Odd[1] = 0.0;
// #_Odd[2] = 0.0;
// #_Even[0] = 0.0;
// #_Even[1] = 0.0;
// #_Even[2] = 0.0;
// # = 0.0;
// prev_#_Odd = 0.0;
// prev_#_Even = 0.0;
// prev_#_input_Odd  = 0.0;
// prev_#_input_Even = 0.0;

// DO_HILBERT_TRANSFORM(varName,input,OddOrEvenId) :
// hilbertTempReal = a *#2#;
// #1# = -#1#_#3#[hilbertIdx];
// #1#_#3#[hilbertIdx] = hilbertTempReal;
// #1#+= hilbertTempReal;
// #1#-= prev_#1#_#3#;
// prev_#1#_#3# = b * prev_#1#_input_#3#;
// #1#+= prev_#1#_#3#;
// prev_#1#_input_#3# =#2#;
// #1#*= adjustedPrevPeriod;

// DO_HILBERT_ODD(varName,input)  DO_HILBERT_TRANSFORM(varName,input,Odd)
// DO_HILBERT_EVEN(varName,input) DO_HILBERT_TRANSFORM(varName,input,Even)

inline function PerToK(per:Float) {
    return (2.0 / (per + 1));
}


// private function

inline function TrueRange(th:Float, tl:Float, yc:Float) {
    var out = th - tl;
    var tempReal2 = Math.abs(th - yc);
    if (tempReal2 > out) {
        out = tempReal2;
    }
    tempReal2 = Math.abs(tl - yc);
    if (tempReal2 > out) {
        out = tempReal2;
    }
    return out;
}
