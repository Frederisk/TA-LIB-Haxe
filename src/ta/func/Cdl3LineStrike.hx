package ta.func;

import ta.func.Utility.CandleAverage;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;

@:keep
function Cdl3LineStrike(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var NearPeriodTotal:Array<Float>;
    var i:Int,
        outIndex:Int,
        totIndex:Int,
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

    lookbackTotal = Cdl3LineStrikeLookback();

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

    // NearPeriodTotal[3] = 0;
    // NearPeriodTotal[2] = 0;
    NearPeriodTotal = [0, 0, 0, 0];
    NearTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.Near].avgPeriod;

    i = NearTrailingIndex;
    while (i < startIndex) {
        NearPeriodTotal[3] += CandleRange(CandleSettingType.Near, i - 3, inOpen, inHigh, inLow, inClose);
        NearPeriodTotal[2] += CandleRange(CandleSettingType.Near, i - 2, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 3, inOpen, inClose) == CandleColor(i - 2, inOpen, inClose)
            && CandleColor(i - 2, inOpen, inClose) == CandleColor(i - 1, inOpen, inClose)
            && CandleColor(i, inOpen, inClose) == -CandleColor(i - 1, inOpen, inClose)
            && inOpen[i - 2] >= Math.min(inOpen[i - 3],
                inClose[i - 3]) - CandleAverage(CandleSettingType.Near, NearPeriodTotal[3], i - 3, inOpen, inHigh, inLow, inClose)
            && inOpen[i - 2] <= Math.max(inOpen[i - 3],
                inClose[i - 3]) + CandleAverage(CandleSettingType.Near, NearPeriodTotal[3], i - 3, inOpen, inHigh, inLow, inClose)
            && inOpen[i - 1] >= Math.min(inOpen[i - 2],
                inClose[i - 2]) - CandleAverage(CandleSettingType.Near, NearPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && inOpen[i - 1] <= Math.max(inOpen[i - 2],
                inClose[i - 2]) + CandleAverage(CandleSettingType.Near, NearPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && ((CandleColor(i - 1, inOpen, inClose) == 1
                && inClose[i - 1] > inClose[i - 2]
                && inClose[i - 2] > inClose[i - 3]
                && inOpen[i] > inClose[i - 1]
                && inClose[i] < inOpen[i - 3])
                || (CandleColor(i - 1, inOpen, inClose) == -1
                    && inClose[i - 1] < inClose[i - 2]
                    && inClose[i - 2] < inClose[i - 3]
                    && inOpen[i] < inClose[i - 1]
                    && inClose[i] > inOpen[i - 3]))) {
            outInteger[outIndex++] = CandleColor(i - 1, inOpen, inClose) * 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        totIndex = 3;
        while (totIndex >= 2) {
            NearPeriodTotal[totIndex] += CandleRange(CandleSettingType.Near, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(CandleSettingType.Near, NearTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);

            totIndex--;
        }
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
function Cdl3LineStrikeLookback():Int {
    return Globals.candleSettings[CandleSettingType.Near].avgPeriod;
}
