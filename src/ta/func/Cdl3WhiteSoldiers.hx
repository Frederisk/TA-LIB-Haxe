package ta.func;

import ta.func.Utility.RealBody;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.UpperShadow;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;
import ta.func.Utility.TAIntMax;

@:keep
function Cdl3WhiteSoldiers(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var ShadowVeryShortPeriodTotal:Array<Float>;
    var NearPeriodTotal:Array<Float>;
    var FarPeriodTotal:Array<Float>;
    var BodyShortPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        totIndex:Int,
        ShadowVeryShortTrailingIndex:Int,
        NearTrailingIndex:Int,
        FarTrailingIndex:Int,
        BodyShortTrailingIndex:Int,
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

    lookbackTotal = Cdl3WhiteSoldiersLookback();

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

    // ShadowVeryShortPeriodTotal[2] = 0;
    // ShadowVeryShortPeriodTotal[1] = 0;
    // ShadowVeryShortPeriodTotal[0] = 0;
    ShadowVeryShortPeriodTotal = [0, 0, 0];
    ShadowVeryShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod;
    // NearPeriodTotal[2] = 0;
    // NearPeriodTotal[1] = 0;
    // NearPeriodTotal[0] = 0;
    NearPeriodTotal = [0, 0, 0];
    NearTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.Near].avgPeriod;
    // FarPeriodTotal[2] = 0;
    // FarPeriodTotal[1] = 0;
    // FarPeriodTotal[0] = 0;
    FarPeriodTotal = [0, 0, 0];
    FarTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.Far].avgPeriod;
    BodyShortPeriodTotal = 0;
    BodyShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod;

    i = ShadowVeryShortTrailingIndex;
    while (i < startIndex) {
        ShadowVeryShortPeriodTotal[2] += CandleRange(CandleSettingType.ShadowVeryShort, i - 2, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal[1] += CandleRange(CandleSettingType.ShadowVeryShort, i - 1, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal[0] += CandleRange(CandleSettingType.ShadowVeryShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = NearTrailingIndex;
    while (i < startIndex) {
        NearPeriodTotal[2] += CandleRange(CandleSettingType.Near, i - 2, inOpen, inHigh, inLow, inClose);
        NearPeriodTotal[1] += CandleRange(CandleSettingType.Near, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = FarTrailingIndex;
    while (i < startIndex) {
        FarPeriodTotal[2] += CandleRange(CandleSettingType.Far, i - 2, inOpen, inHigh, inLow, inClose);
        FarPeriodTotal[1] += CandleRange(CandleSettingType.Far, i - 1, inOpen, inHigh, inLow, inClose);
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
        if (CandleColor(i - 2, inOpen, inClose) == 1
            && UpperShadow(i - 2, inOpen, inHigh,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && CandleColor(i - 1, inOpen, inClose) == 1
            && UpperShadow(i - 1, inOpen, inHigh,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && CandleColor(i, inOpen, inClose) == 1
            && UpperShadow(i, inOpen, inHigh,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[0], i, inOpen, inHigh, inLow, inClose)
            && inClose[i] > inClose[i - 1]
            && inClose[i - 1] > inClose[i - 2]
            && inOpen[i - 1] > inOpen[i - 2]
            && inOpen[i - 1] <= inClose[i - 2] + CandleAverage(CandleSettingType.Near, NearPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && inOpen[i] > inOpen[i - 1]
            && inOpen[i] <= inClose[i - 1] + CandleAverage(CandleSettingType.Near, NearPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && RealBody(i - 1, inOpen,
                inClose) > RealBody(i - 2, inOpen, inClose) - CandleAverage(CandleSettingType.Far, FarPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && RealBody(i, inOpen,
                inClose) > RealBody(i - 1, inOpen, inClose) - CandleAverage(CandleSettingType.Far, FarPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && RealBody(i, inOpen, inClose) > CandleAverage(CandleSettingType.BodyShort, BodyShortPeriodTotal, i, inOpen, inHigh, inLow, inClose)) {
            outInteger[outIndex++] = 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        totIndex = 2;
        while (totIndex >= 0) {
            ShadowVeryShortPeriodTotal[totIndex] += CandleRange(CandleSettingType.ShadowVeryShort, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(CandleSettingType.ShadowVeryShort, ShadowVeryShortTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);

            totIndex--;
        }

        totIndex = 2;
        while (totIndex >= 1) {
            FarPeriodTotal[totIndex] += CandleRange(CandleSettingType.Far, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(CandleSettingType.Far, FarTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);
            NearPeriodTotal[totIndex] += CandleRange(CandleSettingType.Near, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(CandleSettingType.Near, NearTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);

            totIndex--;
        }
        BodyShortPeriodTotal += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyShort, BodyShortTrailingIndex, inOpen, inHigh, inLow, inClose);
        i++;
        ShadowVeryShortTrailingIndex++;
        NearTrailingIndex++;
        FarTrailingIndex++;
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
function Cdl3WhiteSoldiersLookback():Int {
    return (TAIntMax(TAIntMax(Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod,
        Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod),
        TAIntMax(Globals.candleSettings[CandleSettingType.Near].avgPeriod, Globals.candleSettings[CandleSettingType.Far].avgPeriod))
        + 2);
}
