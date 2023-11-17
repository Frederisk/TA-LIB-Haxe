package ta.func;

import ta.func.Utility.TAIntMax;
import ta.func.Utility.UpperShadow;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.LowerShadow;
import ta.func.Utility.CandleColor;
import ta.Globals.CandleSettingType;
import ta.func.Utility.CandleRange;

@:keep
function CdlSeparatingLines(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var ShadowVeryShortPeriodTotal:Float,
        BodyLongPeriodTotal:Float,
        EqualPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        ShadowVeryShortTrailingIndex:Int,
        BodyLongTrailingIndex:Int,
        EqualTrailingIndex:Int,
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

    lookbackTotal = CdlSeparatingLinesLookback();

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

    ShadowVeryShortPeriodTotal = 0;
    ShadowVeryShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod;
    BodyLongPeriodTotal = 0;
    BodyLongTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod;
    EqualPeriodTotal = 0;
    EqualTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.Equal].avgPeriod;

    i = ShadowVeryShortTrailingIndex;
    while (i < startIndex) {
        ShadowVeryShortPeriodTotal += CandleRange(CandleSettingType.ShadowVeryShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = BodyLongTrailingIndex;
    while (i < startIndex) {
        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = EqualTrailingIndex;
    while (i < startIndex) {
        EqualPeriodTotal += CandleRange(CandleSettingType.Equal, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 1, inOpen, inClose) == -CandleColor(i, inOpen, inClose)
            && inOpen[i] <= inOpen[i - 1] + CandleAverage(CandleSettingType.Equal, EqualPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose)
            && inOpen[i] >= inOpen[i - 1] - CandleAverage(CandleSettingType.Equal, EqualPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose)
            && RealBody(i, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && ((CandleColor(i, inOpen, inClose) == 1
                && LowerShadow(i, inOpen, inLow,
                    inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal, i, inOpen, inHigh, inLow, inClose))
                || (CandleColor(i, inOpen, inClose) == -1
                    && UpperShadow(i, inOpen, inHigh,
                        inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal, i, inOpen, inHigh, inLow, inClose)))) {
            outInteger[outIndex++] = CandleColor(i, inOpen, inClose) * 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        ShadowVeryShortPeriodTotal += CandleRange(CandleSettingType.ShadowVeryShort, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.ShadowVeryShort, ShadowVeryShortTrailingIndex, inOpen, inHigh, inLow, inClose);
        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex, inOpen, inHigh, inLow, inClose);
        EqualPeriodTotal += CandleRange(CandleSettingType.Equal, i - 1, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.Equal, EqualTrailingIndex - 1, inOpen, inHigh, inLow, inClose);
        i++;
        ShadowVeryShortTrailingIndex++;
        BodyLongTrailingIndex++;
        EqualTrailingIndex++;
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
function CdlSeparatingLinesLookback():Int {
    return (TAIntMax(TAIntMax(Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod,
        Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod),
        Globals.candleSettings[CandleSettingType.Equal].avgPeriod)
        + 1);
}
