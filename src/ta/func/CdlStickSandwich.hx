package ta.func;

import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleAverage;
import ta.Globals.CandleSettingType;
import ta.func.Utility.CandleRange;

@:keep
function CdlStickSandwich(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var EqualPeriodTotal:Float;
    var i:Int, outIndex:Int, EqualTrailingIndex:Int, lookbackTotal:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inOpen == null || inHigh == null || inLow == null || inClose == null) {
        throw new TAException(BadParam);
    }

    lookbackTotal = CdlStickSandwichLookback();

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

    EqualPeriodTotal = 0;
    EqualTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.Equal].avgPeriod;

    i = EqualTrailingIndex;
    while (i < startIndex) {
        EqualPeriodTotal += CandleRange(CandleSettingType.Equal, i - 2, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 2, inOpen, inClose) == -1
            && CandleColor(i - 1, inOpen, inClose) == 1
            && CandleColor(i, inOpen, inClose) == -1
            && inLow[i - 1] > inClose[i - 2]
            && inClose[i] <= inClose[i - 2] + CandleAverage(CandleSettingType.Equal, EqualPeriodTotal, i - 2, inOpen, inHigh, inLow, inClose)
            && inClose[i] >= inClose[i - 2] - CandleAverage(CandleSettingType.Equal, EqualPeriodTotal, i - 2, inOpen, inHigh, inLow, inClose)) {
            outInteger[outIndex++] = 100;
        } else {
            outInteger[outIndex++] = 0;
        }
        EqualPeriodTotal += CandleRange(CandleSettingType.Equal, i - 2, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.Equal, EqualTrailingIndex - 2, inOpen, inHigh, inLow, inClose);
        i++;
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
function CdlStickSandwichLookback():Int {
    return (Globals.candleSettings[CandleSettingType.Equal].avgPeriod + 2);
}

