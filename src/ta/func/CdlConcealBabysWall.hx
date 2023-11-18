package ta.func;

import ta.func.Utility.CandleAverage;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleRange;
import ta.func.Utility.LowerShadow;
import ta.func.Utility.RealBody;
import ta.func.Utility.RealBodyGapDown;
import ta.func.Utility.UpperShadow;
import ta.Globals.CandleSettingType;

@:keep
function CdlConcealBabysWall(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var ShadowVeryShortPeriodTotal:Array<Float>; // 4
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

    lookbackTotal = CdlConcealBabysWallLookback();

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

    // [0] unused
    ShadowVeryShortPeriodTotal = [0,0,0,0];
    ShadowVeryShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowVeryLong].avgPeriod;

    i = ShadowVeryShortTrailingIndex;
    while (i < startIndex) {
        ShadowVeryShortPeriodTotal[3] += CandleRange(CandleSettingType.ShadowVeryShort, i - 3, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal[2] += CandleRange(CandleSettingType.ShadowVeryShort, i - 2, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal[1] += CandleRange(CandleSettingType.ShadowVeryShort, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 3, inOpen, inClose) == -1
            && CandleColor(i - 2, inOpen, inClose) == -1
            && CandleColor(i - 1, inOpen, inClose) == -1
            && CandleColor(i, inOpen, inClose) == -1
            && LowerShadow(i - 3, inOpen, inLow, inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[3], i - 3, inOpen, inHigh, inLow, inClose)
            && UpperShadow(i - 3, inOpen, inHigh, inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[3], i - 3, inOpen, inHigh, inLow, inClose)
            && LowerShadow(i - 2, inOpen, inLow, inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && UpperShadow(i - 2, inOpen, inHigh, inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && RealBodyGapDown(i - 1, i - 2, inOpen, inClose)
            && UpperShadow(i - 1, inOpen, inHigh, inClose) > CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && inHigh[i - 1] > inClose[i - 2]
            && inHigh[i] > inHigh[i - 1]
            && inLow[i] < inLow[i - 1]) {
            outInteger[outIndex++] = 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        totIndex = 3;
        while (
        totIndex >= 1
    )
        {ShadowVeryShortPeriodTotal[totIndex] += CandleRange(CandleSettingType.ShadowVeryShort, i - totIndex, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.ShadowVeryShort, ShadowVeryShortTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);

            --totIndex;
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
function CdlConcealBabysWallLookback():Int {
    return (Globals.candleSettings[CandleSettingType.ShadowVeryLong].avgPeriod + 3);
}
