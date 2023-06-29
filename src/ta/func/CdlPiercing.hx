package ta.func;

import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;

@:keep
function CdlPiercing(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyLongPeriodTotal:Array<Float>; // 2
    var i:Int,
        outIndex:Int,
        totIndex:Int,
        BodyLongTrailingIndex:Int,
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

    lookbackTotal = CdlPiercingLookback();

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

    BodyLongPeriodTotal[1] = 0;
    BodyLongPeriodTotal[0] = 0;
    BodyLongTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod;

    i = BodyLongTrailingIndex;
    while (i < startIndex) {
        BodyLongPeriodTotal[1] += CandleRange(CandleSettingType.BodyLong, i - 1, inOpen, inHigh, inLow, inClose);
        BodyLongPeriodTotal[0] += CandleRange(CandleSettingType.BodyLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 1, inOpen, inClose) == -1
            && RealBody(i - 1, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && CandleColor(i, inOpen, inClose) == 1
            && RealBody(i, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal[0], i, inOpen, inHigh, inLow, inClose)
            && inOpen[i] < inLow[i - 1]
            && inClose[i] < inOpen[i - 1]
            && inClose[i] > inClose[i - 1] + RealBody(i - 1, inOpen, inClose) * 0.5) {
            outInteger[outIndex++] = 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        totIndex = 1;
        while (totIndex >= 0) {
            BodyLongPeriodTotal[totIndex] += CandleRange(CandleSettingType.BodyLong, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);
            --
            totIndex;
        }
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
function CdlPiercingLookback() {
    return (Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod + 1);
}
