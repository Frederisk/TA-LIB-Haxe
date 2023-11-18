package ta.func;

import ta.func.Utility.CandleAverage;
import ta.func.Utility.LowerShadow;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;

@:keep
function Cdl3BlackCrows(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var ShadowVeryShortPeriodTotal:Array<Float>;
    var i:Int,
        outIndex:Int,
        totIndex:Int,
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

    lookbackTotal = Cdl3BlackCrowsLookback();

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
    ShadowVeryShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowVeryLong].avgPeriod;

    i = ShadowVeryShortTrailingIndex;
    while (i < startIndex) {
        ShadowVeryShortPeriodTotal[2] += CandleRange(CandleSettingType.ShadowVeryShort, i - 2, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal[1] += CandleRange(CandleSettingType.ShadowVeryShort, i - 1, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal[0] += CandleRange(CandleSettingType.ShadowVeryShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 3, inOpen, inClose) == 1
            && CandleColor(i - 2, inOpen, inClose) == -1
            && LowerShadow(i - 2, inOpen, inLow,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && CandleColor(i - 1, inOpen, inClose) == -1
            && LowerShadow(i - 1, inOpen, inLow,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && CandleColor(i, inOpen, inClose) == -1
            && LowerShadow(i, inOpen, inLow,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[0], i, inOpen, inHigh, inLow, inClose)
            && inOpen[i - 1] < inOpen[i - 2]
            && inOpen[i - 1] > inClose[i - 2]
            && inOpen[i] < inOpen[i - 1]
            && inOpen[i] > inClose[i - 1]
            && inHigh[i - 3] > inClose[i - 2]
            && inClose[i - 2] > inClose[i - 1]
            && inClose[i - 1] > inClose[i]) {
            outInteger[outIndex++] = -100;
        } else {
            outInteger[outIndex++] = 0;
        }

        totIndex = 2;
        while (totIndex >= 0) {
            ShadowVeryShortPeriodTotal[totIndex] += CandleRange(CandleSettingType.ShadowVeryShort, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(CandleSettingType.ShadowVeryShort, ShadowVeryShortTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);

            totIndex--;
        }
        i++;
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
function Cdl3BlackCrowsLookback():Int {
    return (Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod + 3);
}
