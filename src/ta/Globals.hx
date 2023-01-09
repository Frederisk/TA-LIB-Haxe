package ta;

final class Globals { // TA_LibcPriv
    // public static final magicNb:UInt = 0;
    // public static final moduleControl:Array<ModuleControl> = [].length = 3;
    // public static final traceEnabled:UInt = 0;
    // public static final stdioEnabled:Uint = 0;
    // public static final stdioFile:File = null;
    // public static final localCachePath:String = null;
    // public static final compatibility:Compatibility = 0;
    public static final unstablePeriod = [for (_ in 0...FuncUnstId.FuncUnstAll) 0];
    // public static final candleSettings = []; //11
}

enum abstract FuncUnstId(Int) to Int {
    var Adx = 0;
    var Adxr = 1;
    var Atr = 2;
    var Cmo = 3;
    var Dx = 4;
    var Ema = 5;
    var HtDcPeriod = 6;
    var HtDcPhase = 7;
    var HtPhasor = 8;
    var HtSine = 9;
    var HtTrendline = 10;
    var HtTrendMode = 11;
    var Kama = 12;
    var Mama = 13;
    var Mfi = 14;
    var MinusDI = 15;
    var MinusDM = 16;
    var Natr = 17;
    var PlusDI = 18;
    var PlusDM = 19;
    var Rsi = 20;
    var StochRsi = 21;
    var T3 = 22;
    var FuncUnstAll = 23;
    var FuncUnstNone = -1;
}

// class ModuleControl {
//     var initialize: UInt;
//     // var
// }

// class GlobalControl {
//     //
// }