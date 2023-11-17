package ta.func;

import ta.func.Utility.TAIntMax;
import ta.func.Utility.RealBodyGapUp;
import ta.func.Utility.LowerShadow;
import ta.func.Utility.UpperShadow;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;

@:keep
function CdlShootingStar(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyPeriodTotal:Float,
        ShadowLongPeriodTotal:Float,
        ShadowVeryShortPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        BodyTrailingIndex:Int,
        ShadowLongTrailingIndex:Int,
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

    lookbackTotal = CdlShootingStarLookback();

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

    BodyPeriodTotal = 0;
    BodyTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod;
    ShadowLongPeriodTotal = 0;
    ShadowLongTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowLong].avgPeriod;
    ShadowVeryShortPeriodTotal = 0;
    ShadowVeryShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod;

    i = BodyTrailingIndex;
    while (i < startIndex) {
        BodyPeriodTotal += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = ShadowLongTrailingIndex;
    while (i < startIndex) {
        ShadowLongPeriodTotal += CandleRange(CandleSettingType.ShadowLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = ShadowVeryShortTrailingIndex;
    while (i < startIndex) {
        ShadowVeryShortPeriodTotal += CandleRange(CandleSettingType.ShadowVeryShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }

    outIndex = 0;
    do {
        if (RealBody(i, inOpen, inClose) < CandleAverage(CandleSettingType.BodyShort, BodyPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && UpperShadow(i, inOpen, inHigh, inClose) > CandleAverage(CandleSettingType.ShadowLong, ShadowLongPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && LowerShadow(i, inOpen, inLow,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && RealBodyGapUp(i, i - 1, inOpen, inClose)) {
            outInteger[outIndex++] = -100;
        } else {
            outInteger[outIndex++] = 0;
        }

        BodyPeriodTotal += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyShort, BodyTrailingIndex, inOpen, inHigh, inLow, inClose);
        ShadowLongPeriodTotal += CandleRange(CandleSettingType.ShadowLong, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.ShadowLong, ShadowLongTrailingIndex, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal += CandleRange(CandleSettingType.ShadowVeryShort, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.ShadowVeryShort, ShadowVeryShortTrailingIndex, inOpen, inHigh, inLow, inClose);
        i++;
        BodyTrailingIndex++;
        ShadowLongTrailingIndex++;
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
function CdlShootingStarLookback():Int {
    return (TAIntMax(TAIntMax(Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod, Globals.candleSettings[CandleSettingType.ShadowLong].avgPeriod),
        Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod)
        + 1);
}
