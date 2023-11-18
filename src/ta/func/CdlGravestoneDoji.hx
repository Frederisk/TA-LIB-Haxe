package ta.func;

import ta.func.Utility.UpperShadow;
import ta.func.Utility.LowerShadow;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;
import ta.func.Utility.TAIntMax;

@:keep
function CdlGravestoneDoji(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyDojiPeriodTotal:Float, ShadowVeryShortPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        BodyDojiTrailingIndex:Int,
        ShadowVeryShortTrailingIndex:Int,
        lookbackTotal:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inOpen == null || inHigh == null || inLow == null || inClose == null) {
        throw new TAException(BadParam);
    }

    lookbackTotal = CdlGravestoneDojiLookback();

    if (startIndex < lookbackTotal) {
        startIndex = lookbackTotal;
    }

    if (startIndex > endIndex) {
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outInteger: outInteger
        };
    }

    BodyDojiPeriodTotal = 0;
    BodyDojiTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyDoji].avgPeriod;
    ShadowVeryShortPeriodTotal = 0;
    ShadowVeryShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod;

    i = BodyDojiTrailingIndex;
    while (i < startIndex) {
        BodyDojiPeriodTotal += CandleRange(CandleSettingType.BodyDoji, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = ShadowVeryShortTrailingIndex;
    while (i < startIndex) {
        ShadowVeryShortPeriodTotal += CandleRange(CandleSettingType.ShadowVeryShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }

    outIndex = 0;
    do {
        if (RealBody(i, inOpen, inClose) <= CandleAverage(CandleSettingType.BodyDoji, BodyDojiPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && LowerShadow(i, inOpen, inLow,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && UpperShadow(i, inOpen, inHigh,
                inClose) > CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal, i, inOpen, inHigh, inLow, inClose)) {
            outInteger[outIndex++] = 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        BodyDojiPeriodTotal += CandleRange(CandleSettingType.BodyDoji, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyDoji, BodyDojiTrailingIndex, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal += CandleRange(CandleSettingType.ShadowVeryShort, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.ShadowVeryShort, ShadowVeryShortTrailingIndex, inOpen, inHigh, inLow, inClose);
        i++;
        BodyDojiTrailingIndex++;
        ShadowVeryShortTrailingIndex++;
    } while (i <= endIndex);

    outNBElement = outIndex;
    outBegIndex = startIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outInteger: outInteger
    };
}

@:keep
function CdlGravestoneDojiLookback():Int {
    return TAIntMax(Globals.candleSettings[CandleSettingType.BodyDoji].avgPeriod, Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod);
}
