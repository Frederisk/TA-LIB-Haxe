package ta.func;

import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleRange;
import ta.func.Utility.TAIntMax;
import ta.Globals.CandleSettingType;

@:keep
function Cdl3Inside(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyShortPeriodTotal:Float, BodyLongPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        BodyShortTrailingIndex:Int,
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

    lookbackTotal = Cdl3InsideLookback();

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
    BodyShortPeriodTotal = 0;
    BodyLongTrailingIndex = startIndex - 2 - Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod;
    BodyShortTrailingIndex = startIndex - 1 - Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod;

    i = BodyLongTrailingIndex;
    while (i < startIndex - 2) {
        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = BodyShortTrailingIndex;
    while (i < startIndex - 1) {
        BodyShortPeriodTotal += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (RealBody(i - 2, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal, i - 2, inOpen, inHigh, inLow, inClose)
            && RealBody(i - 1, inOpen, inClose) <= CandleAverage(CandleSettingType.BodyShort, BodyShortPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose)
            && Math.max(inClose[i - 1], inOpen[i - 1]) < Math.max(inClose[i - 2], inOpen[i - 2])
            && Math.min(inClose[i - 1], inOpen[i - 1]) > Math.min(inClose[i - 2], inOpen[i - 2])
            && ((CandleColor(i - 2, inOpen, inClose) == 1 && CandleColor(i, inOpen, inClose) == -1 && inClose[i] < inOpen[i - 2])
                || (CandleColor(i - 2, inOpen, inClose) == -1 && CandleColor(i, inOpen, inClose) == 1 && inClose[i] > inOpen[i - 2]))) {
            outInteger[outIndex++] = -CandleColor(i - 2, inOpen, inClose) * 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i - 2, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex, inOpen, inHigh, inLow, inClose);
        BodyShortPeriodTotal += CandleRange(CandleSettingType.BodyShort, i - 1, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyShort, BodyShortTrailingIndex, inOpen, inHigh, inLow, inClose);
        i++;
        BodyLongTrailingIndex++;
        BodyShortTrailingIndex++;
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
function Cdl3InsideLookback() {
    return (TAIntMax(Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod, Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod) + 2);
}
