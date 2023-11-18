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

    outIndex = 0;
    do {
        if (CandleColor(i - 2, inOpen, inClose) == -1
            && LowerShadow(i - 2, inOpen, inLow,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && CandleColor(i - 1, inOpen, inClose) == -1
            && LowerShadow(i - 1, inOpen, inLow,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && CandleColor(i, inOpen, inClose) == -1
            && LowerShadow(i, inOpen, inLow,
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
function CdlIdentical3CrowsLookback():Int {
    return (TAIntMax(Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod, Globals.candleSettings[CandleSettingType.Equal].avgPeriod) + 2);
}
