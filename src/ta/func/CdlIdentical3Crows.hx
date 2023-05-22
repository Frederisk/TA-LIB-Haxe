package ta.func;

import ta.func.Utility.CandleAverage;
import ta.func.Utility.LowerShadow;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;
import ta.func.Utility.TAIntMax;

@:keep
function CdlIdentical3Crows(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var ShadowVeryShortPeriodTotal:Array<Float>; // 3
    var EqualPeriodTotal:Array<Float>; // 3
    var i:Int,
        outIndex:Int,
        totIndex:Int,
        ShadowVeryShortTrailingIndex:Int,
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

    lookbackTotal = CdlIdentical3CrowsLookback();

    /* Move up the start index if there is not
     * enough initial data.
     */
    if (startIndex < lookbackTotal)
        startIndex = lookbackTotal;

    /* Make sure there is still something to evaluate. */
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
    // EqualPeriodTotal[2] = 0;
    // EqualPeriodTotal[1] = 0;
    // EqualPeriodTotal[0] = 0;
    EqualPeriodTotal = [0, 0, 0];
    EqualTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.Equal].avgPeriod;

    i = ShadowVeryShortTrailingIndex;
    while (i < startIndex) {
        ShadowVeryShortPeriodTotal[2] += CandleRange(CandleSettingType.ShadowVeryShort, i - 2, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal[1] += CandleRange(CandleSettingType.ShadowVeryShort, i - 1, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal[0] += CandleRange(CandleSettingType.ShadowVeryShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = EqualTrailingIndex;
    while (i < startIndex) {
        EqualPeriodTotal[2] += CandleRange(CandleSettingType.Equal, i - 2, inOpen, inHigh, inLow, inClose);
        EqualPeriodTotal[1] += CandleRange(CandleSettingType.Equal, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    /* Proceed with the calculation for the requested range.
     * Must have:
     * - three consecutive and declining black candlesticks
     * - each candle must have no or very short lower shadow
     * - each candle after the first must open at or very close to the prior candle's close
     * The meaning of "very short" is specified with TA_SetCandleSettings;
     * the meaning of "very close" is specified with TA_SetCandleSettings (CandleSettingType.Equal);
     * outInteger is negative (-1 to -100): identical three crows is always bearish;
     * the user should consider that identical 3 crows is significant when it appears after a mature advance or at high levels,
     * while this function does not consider it
     */
    outIndex = 0;
    do {
        if (CandleColor(i - 2, inOpen, inClose) == -1
            && // 1st black
            // very short lower shadow
            LowerShadow(i - 2, inOpen, inLow,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && CandleColor(i - 1, inOpen, inClose) == -1
            && // 2nd black
            // very short lower shadow
            LowerShadow(i - 1, inOpen, inLow,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && CandleColor(i, inOpen, inClose) == -1
            && // 3rd black
            // very short lower shadow
            LowerShadow(i, inOpen, inLow,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[0], i, inOpen, inHigh, inLow, inClose)
            && inClose[i - 2] > inClose[i - 1]
            && inClose[i - 1] > inClose[i]
            && inOpen[i - 1] <= inClose[i - 2] + CandleAverage(CandleSettingType.Equal, EqualPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && inOpen[i - 1] >= inClose[i - 2] - CandleAverage(CandleSettingType.Equal, EqualPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && inOpen[i] <= inClose[i - 1] + CandleAverage(CandleSettingType.Equal, EqualPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && inOpen[i] >= inClose[i - 1] - CandleAverage(CandleSettingType.Equal, EqualPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)) {
            outInteger[outIndex++] = -100;
        } else {
            outInteger[outIndex++] = 0;
        }

        totIndex = 2;
        while (totIndex >= 0) {
            ShadowVeryShortPeriodTotal[totIndex] += CandleRange(CandleSettingType.ShadowVeryShort, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(CandleSettingType.ShadowVeryShort, ShadowVeryShortTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);

            --
            totIndex;
        }

        totIndex = 2;
        while (totIndex >= 1) {
            EqualPeriodTotal[totIndex] += CandleRange(CandleSettingType.Equal, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(CandleSettingType.Equal, EqualTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);

            --
            totIndex;
        }
        i++;
        ShadowVeryShortTrailingIndex++;
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
function CdlIdentical3CrowsLookback() {
    return (TAIntMax(Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod, Globals.candleSettings[CandleSettingType.Equal].avgPeriod) + 2);
}
