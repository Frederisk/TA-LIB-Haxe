package ta.func;

import ta.func.Utility.CandleAverage;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleRange;
import ta.func.Utility.RealBody;
import ta.func.Utility.RealBodyGapDown;
import ta.func.Utility.RealBodyGapUp;
import ta.Globals.CandleSettingType;

@:keep
function CdlBreakaway(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
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

    lookbackTotal = CdlBreakawayLookback();

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
    BodyLongTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod;

    i = BodyLongTrailingIndex;
    while (i < startIndex) {
        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i - 4, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (RealBody(i - 4, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal, i - 4, inOpen, inHigh, inLow, inClose)
            && CandleColor(i - 4, inOpen, inClose) == CandleColor(i - 3, inOpen, inClose)
            && CandleColor(i - 3, inOpen, inClose) == CandleColor(i - 1, inOpen, inClose)
            && CandleColor(i - 1, inOpen, inClose) == -CandleColor(i, inOpen, inClose)
            && ((CandleColor(i - 4, inOpen, inClose) == -1
                && RealBodyGapDown(i - 3, i - 4, inOpen, inClose)
                && inHigh[i - 2] < inHigh[i - 3]
                && inLow[i - 2] < inLow[i - 3]
                && inHigh[i - 1] < inHigh[i - 2]
                && inLow[i - 1] < inLow[i - 2]
                && inClose[i] > inOpen[i - 3]
                && inClose[i] < inClose[i - 4])
                || (CandleColor(i - 4, inOpen, inClose) == 1
                    && RealBodyGapUp(i - 3, i - 4, inOpen, inClose)
                    && inHigh[i - 2] > inHigh[i - 3]
                    && inLow[i - 2] > inLow[i - 3]
                    && inHigh[i - 1] > inHigh[i - 2]
                    && inLow[i - 1] > inLow[i - 2]
                    && inClose[i] < inOpen[i - 3]
                    && inClose[i] > inClose[i - 4]))) {
            outInteger[outIndex++] = CandleColor(i, inOpen, inClose) * 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i - 4, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex - 4, inOpen, inHigh, inLow, inClose);
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
function CdlBreakawayLookback():Int {
    return (Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod + 4);
}
