package ta.func;

import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBodyGapUp;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;

@:keep
function Cdl2Crows(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyLongPeriodTotal:Float;
    var i:Int, outIndex:Int, BodyLongTrailingIndex:Int, lookbackTotal:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inOpen == null || inHigh == null || inLow == null || inClose == null) {
        throw new TAException(BadParam);
    }

    lookbackTotal = Cdl2CrowsLookback();

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

    BodyLongPeriodTotal = 0;
    BodyLongTrailingIndex = startIndex - 2 - Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod;
    // TA_CANDLEAVGPERIOD(BodyLong);
    // (TA_Globals->candleSettings[TA_BodyLong].avgPeriod)

    i = BodyLongTrailingIndex;
    while (i < startIndex - 2) {
        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 2, inOpen, inClose) == 1
            && RealBody(i - 2, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal, i - 2, inOpen, inHigh, inLow, inClose)
            && CandleColor(i - 1, inOpen, inClose) == -1
            && RealBodyGapUp(i - 1, i - 2, inOpen, inClose)
            && CandleColor(i, inOpen, inClose) == -1
            && inOpen[i] < inOpen[i - 1]
            && inOpen[i] > inClose[i - 1]
            && inClose[i] > inOpen[i - 2]
            && inClose[i] < inClose[i - 2]) {
            outInteger[outIndex++] = -100;
        } else {
            outInteger[outIndex++] = 0;
        }
        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i - 2, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex, inOpen, inHigh, inLow, inClose);
        i++;
        BodyLongTrailingIndex++;
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
function Cdl2CrowsLookback():Int {
    return (Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod + 2);
}
