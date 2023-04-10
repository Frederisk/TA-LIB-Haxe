package ta;

final class Globals {
    // TA_LibcPriv
    // public static final magicNb:UInt = 0;
    // public static final moduleControl:Array<ModuleControl> = [].length = 3;
    // public static final traceEnabled:UInt = 0;
    // public static final stdioEnabled:Uint = 0;
    // public static final stdioFile:File = null;
    // public static final localCachePath:String = null;
    public static var compatibility:Compatibility = Compatibility.Default;

    /**
     * Notice: `final` Array is NOT readonly.
     */
    public static final unstablePeriod:Array<FuncUnstId> = [
        for (_ in 0...FuncUnstId.FuncUnstAll)
            FuncUnstId.Adx
    ];

    public static final candleSettings:Array<CandleSetting> = getCandleDefaultSettings();

    private inline static function getCandleDefaultSettings():Array<CandleSetting> {
        return [
            {
                settingType: CandleSettingType.BodyLong,
                rangeType: RangeType.RealBody,
                avgPeriod: 10,
                factor: 1.0
            },
            {
                settingType: CandleSettingType.BodyVeryLong,
                rangeType: RangeType.RealBody,
                avgPeriod: 10,
                factor: 3.0
            },
            {
                settingType: CandleSettingType.BodyShort,
                rangeType: RangeType.RealBody,
                avgPeriod: 10,
                factor: 1.0
            },
            {
                settingType: CandleSettingType.BodyDoji,
                rangeType: RangeType.HighLow,
                avgPeriod: 10,
                factor: 0.1
            },
            {
                settingType: CandleSettingType.ShadowLong,
                rangeType: RangeType.RealBody,
                avgPeriod: 0,
                factor: 1.0
            },
            {
                settingType: CandleSettingType.ShadowVeryLong,
                rangeType: RangeType.RealBody,
                avgPeriod: 0,
                factor: 2.0
            },
            {
                settingType: CandleSettingType.ShadowShort,
                rangeType: RangeType.Shadows,
                avgPeriod: 10,
                factor: 1.0
            },
            {
                settingType: CandleSettingType.ShadowVeryShort,
                rangeType: RangeType.HighLow,
                avgPeriod: 10,
                factor: 0.1
            },
            {
                settingType: CandleSettingType.Near,
                rangeType: RangeType.HighLow,
                avgPeriod: 5,
                factor: 0.2
            },
            {
                settingType: CandleSettingType.Far,
                rangeType: RangeType.HighLow,
                avgPeriod: 5,
                factor: 0.6
            },
            {
                settingType: CandleSettingType.Equal,
                rangeType: RangeType.HighLow,
                avgPeriod: 5,
                factor: 0.05
            }
        ]; // 11
    }

    public static function RestoreCandleDefaultSettings(settingType:CandleSettingType):Void {
        var CandleDefaultSettings:Array<CandleSetting> = getCandleDefaultSettings();
        if (settingType == CandleSettingType.AllCandleSettings) {
            var i:Int = 0;
            var all:Int = CandleSettingType.AllCandleSettings;
            while (i < all) {
                candleSettings[i] = CandleDefaultSettings[i];
                i++;
            }
        } else {
            candleSettings[settingType] = CandleDefaultSettings[settingType];
        }
    }
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

@:nativeGen
enum Compatibility {
    Default;
    Metastock;
}

@:nativeGen
enum MAType {
    Sma;
    Ema;
    Wma;
    Dema;
    Tema;
    Trima;
    Kama;
    Mama;
    T3;
}

@:struct
@:structInit
class CandleSetting {
    public var settingType:CandleSettingType;
    public var rangeType:RangeType;
    public var avgPeriod:Int;
    public var factor:Float;
}

enum abstract CandleSettingType(Int) to Int {
    var BodyLong;
    var BodyVeryLong;
    var BodyShort;
    var BodyDoji;
    var ShadowLong;
    var ShadowVeryLong;
    var ShadowShort;
    var ShadowVeryShort;
    var Near;
    var Far;
    var Equal;
    var AllCandleSettings; // = 11;
}

enum RangeType {
    RealBody;
    HighLow;
    Shadows;
}

/**
 * The base class of enumeration like object.
 *
 * You can extend it to your class and implement the correct `private override function new(value:T)` (usually, just call the `super(value:T)`).
 *
 * `T` for base type, use it as `abstract` base type.
 *
 * For enumeration members, use `public static final` variables and initialize them immediately.
 *
 * Example:
 * ```haxe
 * class MyEnum: TAEnumeration<String> {
 *   public static final ValueOne = new MyEnum("This is 1.");
 *   public static final ValueTwo = new MyEnum("This is 2.");
 *
 *   private override function new(value:String) {
 *     super(value);
 *   }
 * }
 * ```
 */
abstract class TAEnumeration<T> {
    // private overload function new (){}
    private function new(value:T) {
        this._true_value = value;
    }

    private var _true_value:T;

    public function getValue():T {
        return this._true_value;
    }

    // Unfortunately, until Haxe 4, it was not possible to override operators in classes, you could only override them in abstract.

    // private abstract function getType();
    // @:op(A == B) public function Equals(obj:Dynamic):Bool {
    //    if (Std.isOfType(obj, TAEnumeration)) {
    //        if (Type.getClass(this) == Type.getClass(obj)) {
    //            if (this._true_value == obj._true_value) {
    //                return true;
    //             }
    //         }
    //     }
    //  return false;
    // }
}
