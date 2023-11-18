package ta.func;

import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;
import ta.func.Utility.TAIntMax;

@:keep
function CdlOnNeck(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var EqualPeriodTotal:Float, BodyLongPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        EqualTrailingIndex:Int,
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

    lookbackTotal = CdlOnNeckLookback();

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
    BodyLongPeriodTotal = 0;
    BodyLongTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod;

    i = EqualTrailingIndex;
    while (i < startIndex) {
        EqualPeriodTotal += CandleRange(CandleSettingType.Equal, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = BodyLongTrailingIndex;
    while (i < startIndex) {
        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 1, inOpen, inClose) == -1
            && RealBody(i - 1, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose)
            && CandleColor(i, inOpen, inClose) == 1
            && inOpen[i] < inLow[i - 1]
            && inClose[i] <= inLow[i - 1] + CandleAverage(CandleSettingType.Equal, EqualPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose)
            && inClose[i] >= inLow[i - 1] - CandleAverage(CandleSettingType.Equal, EqualPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose)) {
            outInteger[outIndex++] = -100;
        } else {
            outInteger[outIndex++] = 0;
        }

        EqualPeriodTotal += CandleRange(CandleSettingType.Equal, i - 1, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.Equal, EqualTrailingIndex - 1, inOpen, inHigh, inLow, inClose);
        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i - 1, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex - 1, inOpen, inHigh, inLow, inClose);
        i++;
        EqualTrailingIndex++;
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
function CdlOnNeckLookback():Int {
    return (TAIntMax(Globals.candleSettings[CandleSettingType.Equal].avgPeriod, Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod) + 1);
}
