package ta.func;

import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBodyGapDown;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleColor;
import ta.func.Utility.RealBodyGapUp;
import ta.Globals.CandleSettingType;
import ta.func.Utility.CandleRange;

@:keep
function CdlTasukiGap(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var NearPeriodTotal:Float;
    var i:Int, outIndex:Int, NearTrailingIndex:Int, lookbackTotal:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inOpen == null || inHigh == null || inLow == null || inClose == null) {
        throw new TAException(BadParam);
    }

    lookbackTotal = CdlTasukiGapLookback();

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

    NearPeriodTotal = 0;
    NearTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.Near].avgPeriod;

    i = NearTrailingIndex;
    while (i < startIndex) {
        NearPeriodTotal += CandleRange(CandleSettingType.Near, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if ((RealBodyGapUp(i - 1, i - 2, inOpen, inClose)
            && CandleColor(i - 1, inOpen, inClose) == 1
            && CandleColor(i, inOpen, inClose) == -1
            && inOpen[i] < inClose[i - 1]
            && inOpen[i] > inOpen[i - 1]
            && inClose[i] < inOpen[i - 1]
            && inClose[i] > Math.max(inClose[i - 2], inOpen[i - 2])
            && Math.abs(RealBody(i - 1, inOpen,
                inClose) - RealBody(i, inOpen, inClose)) < CandleAverage(CandleSettingType.Near, NearPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose))
            || (RealBodyGapDown(i - 1, i - 2, inOpen, inClose)
                && CandleColor(i - 1, inOpen, inClose) == -1
                && CandleColor(i, inOpen, inClose) == 1
                && inOpen[i] < inOpen[i - 1]
                && inOpen[i] > inClose[i - 1]
                && inClose[i] > inOpen[i - 1]
                && inClose[i] < Math.min(inClose[i - 2], inOpen[i - 2])
                && Math.abs(RealBody(i - 1, inOpen,
                    inClose) - RealBody(i, inOpen, inClose)) < CandleAverage(CandleSettingType.Near, NearPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose))) {
            outInteger[outIndex++] = CandleColor(i - 1, inOpen, inClose) * 100;
        } else {
            outInteger[outIndex++] = 0;
        }
        NearPeriodTotal += CandleRange(CandleSettingType.Near, i - 1, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.Near, NearTrailingIndex - 1, inOpen, inHigh, inLow, inClose);
        i++;
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
function CdlTasukiGapLookback():Int {
    return (Globals.candleSettings[CandleSettingType.Near].avgPeriod + 2);
}
