package ta.func;

import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleColor;
import ta.func.Utility.RealBodyGapDown;
import ta.func.Utility.RealBodyGapUp;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;
import ta.func.Utility.TAIntMax;

@:keep
function CdlGapSideSideWhite(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var NearPeriodTotal:Float, EqualPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        NearTrailingIndex:Int,
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

    lookbackTotal = CdlGapSideSideWhiteLookback();

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
    EqualPeriodTotal = 0;
    NearTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.Near].avgPeriod;
    EqualTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.Equal].avgPeriod;

    i = NearTrailingIndex;
    while (i < startIndex) {
        NearPeriodTotal += CandleRange(CandleSettingType.Near, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = EqualTrailingIndex;
    while (i < startIndex) {
        EqualPeriodTotal += CandleRange(CandleSettingType.Equal, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (((RealBodyGapUp(i - 1, i - 2, inOpen, inClose) && RealBodyGapUp(i, i - 2, inOpen, inClose))
            || (RealBodyGapDown(i - 1, i - 2, inOpen, inClose) && RealBodyGapDown(i, i - 2, inOpen, inClose)))
            && CandleColor(i - 1, inOpen, inClose) == 1
            && CandleColor(i, inOpen, inClose) == 1
            && RealBody(i, inOpen, inClose) >= RealBody(i - 1, inOpen, inClose)
            - CandleAverage(CandleSettingType.Near, NearPeriodTotal, i - 1, inOpen, inHigh, inLow,
                inClose) && RealBody(i, inOpen, inClose) <= RealBody(i - 1, inOpen, inClose)
            + CandleAverage(CandleSettingType.Near, NearPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose) && inOpen[i] >= inOpen[i - 1]
            - CandleAverage(CandleSettingType.Equal, EqualPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose) && inOpen[i] <= inOpen[i - 1]
            + CandleAverage(CandleSettingType.Equal, EqualPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose)) {
            outInteger[outIndex++] = (RealBodyGapUp(i - 1, i - 2, inOpen, inClose) ? 100 : -100);
        } else {
            outInteger[outIndex++] = 0;
        }

        NearPeriodTotal += CandleRange(CandleSettingType.Near, i - 1, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.Near, NearTrailingIndex - 1, inOpen, inHigh, inLow, inClose);
        EqualPeriodTotal += CandleRange(CandleSettingType.Equal, i - 1, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.Equal, EqualTrailingIndex - 1, inOpen, inHigh, inLow, inClose);
        i++;
        NearTrailingIndex++;
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
function CdlGapSideSideWhiteLookback():Int {
    return (TAIntMax(Globals.candleSettings[CandleSettingType.Near].avgPeriod, Globals.candleSettings[CandleSettingType.Equal].avgPeriod) + 2);
}
