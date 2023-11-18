package ta.func;

import ta.Globals.CandleSettingType;
import ta.func.Utility.RealBodyGapUp;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleRange;
import ta.func.Utility.TAIntMax;

@:keep
function CdlEveningStar(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>,
        optInPenetration:Float) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyShortPeriodTotal:Float,
        BodyLongPeriodTotal:Float,
        BodyShortPeriodTotal2:Float;
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
    // DEFAULT FLOAT
    // if (optInPenetration == null) {
    //     optInPenetration = 3.000000e-1;
    // }
    if (optInPenetration < 0) {
        throw new TAException(BadParam);
    }

    lookbackTotal = CdlEveningStarLookback(optInPenetration);

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
    BodyShortPeriodTotal2 = 0;
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
        BodyShortPeriodTotal2 += CandleRange(CandleSettingType.BodyShort, i + 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (RealBody(i - 2, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal, i - 2, inOpen, inHigh, inLow, inClose)
            && CandleColor(i - 2, inOpen, inClose) == 1
            && RealBody(i - 1, inOpen, inClose) <= CandleAverage(CandleSettingType.BodyShort, BodyShortPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose)
            && RealBodyGapUp(i - 1, i - 2, inOpen, inClose)
            && RealBody(i, inOpen, inClose) > CandleAverage(CandleSettingType.BodyShort, BodyShortPeriodTotal2, i, inOpen, inHigh, inLow, inClose)
            && CandleColor(i, inOpen, inClose) == -1
            && inClose[i] < inClose[i - 2] - RealBody(i - 2, inOpen, inClose) * optInPenetration) {
            outInteger[outIndex++] = -100;
        } else {
            outInteger[outIndex++] = 0;
        }

        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i - 2, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex, inOpen, inHigh, inLow, inClose);
        BodyShortPeriodTotal += CandleRange(CandleSettingType.BodyShort, i - 1, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyShort, BodyShortTrailingIndex, inOpen, inHigh, inLow, inClose);
        BodyShortPeriodTotal2 += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyShort, BodyShortTrailingIndex + 1, inOpen, inHigh, inLow, inClose);
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
function CdlEveningStarLookback(optInPenetration:Float):Int {
    // DEFAULT FLOAT
    // if (optInPenetration == null) {
    //     optInPenetration = 3.000000e-1;
    // }
    if (optInPenetration < 0) {
        return -1;
    }
    optInPenetration;
    return (TAIntMax(Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod, Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod) + 2);
}
