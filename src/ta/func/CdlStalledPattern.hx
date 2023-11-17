package ta.func;

import ta.func.Utility.TAIntMax;
import ta.func.Utility.CandleColor;
import ta.func.Utility.UpperShadow;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;

@:keep
function CdlStalledPattern(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    // ARRAY_LOCAL(BodyLongPeriodTotal,3);
    // ARRAY_LOCAL(NearPeriodTotal,3);
    var BodyLongPeriodTotal:Array<Float>;
    var NearPeriodTotal:Array<Float>;
    var BodyShortPeriodTotal:Float, ShadowVeryShortPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        totIndex:Int,
        BodyLongTrailingIndex:Int,
        BodyShortTrailingIndex:Int,
        ShadowVeryShortTrailingIndex:Int,
        NearTrailingIndex:Int,
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

    lookbackTotal = CdlStalledPatternLookback();

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

    // BodyLongPeriodTotal[2] = 0;
    // BodyLongPeriodTotal[1] = 0;
    // BodyLongPeriodTotal[0] = 0;
    BodyLongPeriodTotal = [0, 0, 0];
    BodyLongTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod;
    BodyShortPeriodTotal = 0;
    BodyShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod;
    ShadowVeryShortPeriodTotal = 0;
    ShadowVeryShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod;
    // NearPeriodTotal[2] = 0;
    // NearPeriodTotal[1] = 0;
    // NearPeriodTotal[0] = 0;
    NearPeriodTotal = [0, 0, 0];
    NearTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.Near].avgPeriod;

    i = BodyLongTrailingIndex;
    while (i < startIndex) {
        BodyLongPeriodTotal[2] += CandleRange(CandleSettingType.BodyLong, i - 2, inOpen, inHigh, inLow, inClose);
        BodyLongPeriodTotal[1] += CandleRange(CandleSettingType.BodyLong, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = BodyShortTrailingIndex;
    while (i < startIndex) {
        BodyShortPeriodTotal += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = ShadowVeryShortTrailingIndex;
    while (i < startIndex) {
        ShadowVeryShortPeriodTotal += CandleRange(CandleSettingType.ShadowVeryShort, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = NearTrailingIndex;
    while (i < startIndex) {
        NearPeriodTotal[2] += CandleRange(CandleSettingType.Near, i - 2, inOpen, inHigh, inLow, inClose);
        NearPeriodTotal[1] += CandleRange(CandleSettingType.Near, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 2, inOpen, inClose) == 1
            && CandleColor(i - 1, inOpen, inClose) == 1
            && CandleColor(i, inOpen, inClose) == 1
            && inClose[i] > inClose[i - 1]
            && inClose[i - 1] > inClose[i - 2]
            && RealBody(i - 2, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && RealBody(i - 1, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && UpperShadow(i - 1, inOpen, inHigh,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose)
            && inOpen[i - 1] > inOpen[i - 2]
            && inOpen[i - 1] <= inClose[i - 2] + CandleAverage(CandleSettingType.Near, NearPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && RealBody(i, inOpen, inClose) < CandleAverage(CandleSettingType.BodyShort, BodyShortPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && inOpen[i] >= inClose[i - 1] - RealBody(i, inOpen,
                inClose) - CandleAverage(CandleSettingType.Near, NearPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)) {
            outInteger[outIndex++] = -100;
        } else {
            outInteger[outIndex++] = 0;
        }
        totIndex = 2;
        while (totIndex >= 1) {

            BodyLongPeriodTotal[totIndex] += CandleRange(CandleSettingType.BodyLong, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);
            NearPeriodTotal[totIndex] += CandleRange(CandleSettingType.Near, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(CandleSettingType.Near, NearTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);

            --
            totIndex;
        }
        BodyShortPeriodTotal += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyShort, BodyShortTrailingIndex, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal += CandleRange(CandleSettingType.ShadowVeryShort, i - 1, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.ShadowVeryShort, ShadowVeryShortTrailingIndex - 1, inOpen, inHigh, inLow, inClose);
        i++;
        BodyLongTrailingIndex++;
        BodyShortTrailingIndex++;
        ShadowVeryShortTrailingIndex++;
        NearTrailingIndex++;
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
function CdlStalledPatternLookback():Int {
    return (TAIntMax(TAIntMax(Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod, Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod),
        TAIntMax(Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod, Globals.candleSettings[CandleSettingType.Near].avgPeriod))
        + 2);
}
