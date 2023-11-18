package ta.func;

import ta.func.Utility.UpperShadow;
import ta.func.Utility.LowerShadow;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleRange;
import ta.func.Utility.CandleColor;
import ta.func.Utility.TAIntMax;
import ta.Globals.CandleSettingType;

@:keep
function Cdl3StarsInSouth(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyLongPeriodTotal:Float,
        BodyShortPeriodTotal:Float,
        ShadowLongPeriodTotal:Float;
    var ShadowVeryShortPeriodTotal:Array<Float>;
    var i:Int,
        outIndex:Int,
        totIndex:Int,
        BodyLongTrailingIndex:Int,
        BodyShortTrailingIndex:Int,
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

    lookbackTotal = Cdl3StarsInSouthLookback();

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
    ShadowLongPeriodTotal = 0;
    ShadowLongTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowLong].avgPeriod;
    // ShadowVeryShortPeriodTotal[1] = 0;
    // ShadowVeryShortPeriodTotal[0] = 0;
    ShadowVeryShortPeriodTotal = [0,0];
    ShadowVeryShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod;
    BodyShortPeriodTotal = 0;
    BodyShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod;

    i = BodyLongTrailingIndex;
    while (i < startIndex) {
        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i - 2, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = ShadowLongTrailingIndex;
    while (i < startIndex) {
        ShadowLongPeriodTotal += CandleRange(CandleSettingType.ShadowLong, i - 2, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = ShadowVeryShortTrailingIndex;
    while (i < startIndex) {
        ShadowVeryShortPeriodTotal[1] += CandleRange(CandleSettingType.ShadowVeryShort, i - 1, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal[0] += CandleRange(CandleSettingType.ShadowVeryShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = BodyShortTrailingIndex;
    while (i < startIndex) {
        BodyShortPeriodTotal += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 2, inOpen, inClose) == -1
            && CandleColor(i - 1, inOpen, inClose) == -1
            && CandleColor(i, inOpen, inClose) == -1
            && RealBody(i - 2, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal, i - 2, inOpen, inHigh, inLow, inClose)
            && LowerShadow(i - 2, inOpen, inLow,
                inClose) > CandleAverage(CandleSettingType.ShadowLong, ShadowLongPeriodTotal, i - 2, inOpen, inHigh, inLow, inClose)

            && RealBody(i - 1, inOpen, inClose) < RealBody(i - 2, inOpen, inClose)
            && inOpen[i - 1] > inClose[i - 2]
            && inOpen[i - 1] <= inHigh[i - 2]
            && inLow[i - 1] < inClose[i - 2]
            && inLow[i - 1] >= inLow[i - 2]
            && LowerShadow(i - 1, inOpen, inLow,
                inClose) > CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && RealBody(i, inOpen, inClose) < CandleAverage(CandleSettingType.BodyShort, BodyShortPeriodTotal, i, inOpen, inHigh, inLow, inClose)

            && LowerShadow(i, inOpen, inLow,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[0], i, inOpen, inHigh, inLow, inClose)
            && UpperShadow(i, inOpen, inHigh,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[0], i, inOpen, inHigh, inLow, inClose)
            && inLow[i] > inLow[i - 1]
            && inHigh[i] < inHigh[i - 1]) {
            outInteger[outIndex++] = 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i - 2, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex - 2, inOpen, inHigh, inLow, inClose);
        ShadowLongPeriodTotal += CandleRange(CandleSettingType.ShadowLong, i - 2, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.ShadowLong, ShadowLongTrailingIndex - 2, inOpen, inHigh, inLow, inClose);

        totIndex = 1;
        while (totIndex >= 0) {
            ShadowVeryShortPeriodTotal[totIndex] += CandleRange(CandleSettingType.ShadowVeryShort, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(CandleSettingType.ShadowVeryShort, ShadowVeryShortTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);

            totIndex--;
        }
        BodyShortPeriodTotal += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyShort, BodyShortTrailingIndex, inOpen, inHigh, inLow, inClose);
        i++;
        BodyLongTrailingIndex++;
        ShadowLongTrailingIndex++;
        ShadowVeryShortTrailingIndex++;
        BodyShortTrailingIndex++;
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
function Cdl3StarsInSouthLookback():Int {
    return (TAIntMax(TAIntMax(Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod,
        Globals.candleSettings[CandleSettingType.ShadowLong].avgPeriod),
        TAIntMax(Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod, Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod))
        + 2);
}
