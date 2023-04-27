package ta.func;

import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.UpperShadow;
import ta.func.Utility.LowerShadow;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;
import ta.func.Utility.TAIntMax;

@:keep
function CdlBeltHold(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyLongPeriodTotal:Float, ShadowVeryShortPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        BodyLongTrailingIndex:Int,
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

    lookbackTotal = CdlBeltHoldLookback();

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

    BodyLongPeriodTotal = 0;
    BodyLongTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod;
    ShadowVeryShortPeriodTotal = 0;
    ShadowVeryShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod;

    i = BodyLongTrailingIndex;
    while (i < startIndex) {
        BodyLongPeriodTotal += CandleRange(BodyLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = ShadowVeryShortTrailingIndex;
    while (i < startIndex) {
        ShadowVeryShortPeriodTotal += CandleRange(ShadowVeryShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }

    outIndex = 0;
    do {
        if (RealBody(i, inOpen, inClose) > CandleAverage(BodyLong, BodyLongPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && ((CandleColor(i, inOpen, inClose) == 1
                && LowerShadow(i, inOpen, inLow, inClose) < CandleAverage(ShadowVeryShort, ShadowVeryShortPeriodTotal, i, inOpen, inHigh, inLow, inClose))
                || (CandleColor(i, inOpen, inClose) == -1
                    && UpperShadow(i, inOpen, inHigh,
                        inClose) < CandleAverage(ShadowVeryShort, ShadowVeryShortPeriodTotal, i, inOpen, inHigh, inLow, inClose)))) {
            outInteger[outIndex++] = CandleColor(i, inOpen, inClose) * 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        BodyLongPeriodTotal += CandleRange(BodyLong, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(BodyLong, BodyLongTrailingIndex, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal += CandleRange(ShadowVeryShort, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(ShadowVeryShort, ShadowVeryShortTrailingIndex, inOpen, inHigh, inLow, inClose);
        i++;
        BodyLongTrailingIndex++;
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
function CdlBeltHoldLookback() {
    return TAIntMax(Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod, Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod);
}
