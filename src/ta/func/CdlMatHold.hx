package ta.func;

import ta.func.Utility.RealBodyGapUp;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;
import ta.func.Utility.TAIntMax;

@:keep
function CdlMatHold(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>, optInPenetration:Float) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    // ARRAY_LOCAL(BodyPeriodTotal,5);
    var BodyPeriodTotal:Array<Float>; // 5
    var i:Int,
        outIndex:Int,
        totIndex:Int,
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
    //     optInPenetration = 5.000000e-1;
    // }
    if (optInPenetration < 0) {
        throw new TAException(BadParam);
    }

    lookbackTotal = CdlMatHoldLookback(optInPenetration);

    if (startIndex < lookbackTotal)
        startIndex = lookbackTotal;

    if (startIndex > endIndex) {
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outInteger: outInteger
        };
    }

    //    BodyPeriodTotal[4] = 0;
    //    BodyPeriodTotal[3] = 0;
    //    BodyPeriodTotal[2] = 0;
    //    BodyPeriodTotal[1] = 0;
    //    BodyPeriodTotal[0] = 0;
    BodyPeriodTotal = [0, 0, 0, 0, 0];
    BodyShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod;
    BodyLongTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod;

    i = BodyShortTrailingIndex;
    while (i < startIndex) {
        BodyPeriodTotal[3] += CandleRange(CandleSettingType.BodyShort, i - 3, inOpen, inHigh, inLow, inClose);
        BodyPeriodTotal[2] += CandleRange(CandleSettingType.BodyShort, i - 2, inOpen, inHigh, inLow, inClose);
        BodyPeriodTotal[1] += CandleRange(CandleSettingType.BodyShort, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = BodyLongTrailingIndex;
    while (i < startIndex) {
        BodyPeriodTotal[4] += CandleRange(CandleSettingType.BodyLong, i - 4, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (RealBody(i - 4, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyPeriodTotal[4], i - 4, inOpen, inHigh, inLow, inClose)
            && RealBody(i - 3, inOpen, inClose) < CandleAverage(CandleSettingType.BodyShort, BodyPeriodTotal[3], i - 3, inOpen, inHigh, inLow, inClose)
            && RealBody(i - 2, inOpen, inClose) < CandleAverage(CandleSettingType.BodyShort, BodyPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && RealBody(i - 1, inOpen, inClose) < CandleAverage(CandleSettingType.BodyShort, BodyPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && CandleColor(i - 4, inOpen, inClose) == 1
            && CandleColor(i - 3, inOpen, inClose) == -1
            && CandleColor(i, inOpen, inClose) == 1
            && RealBodyGapUp(i - 3, i - 4, inOpen, inClose)
            && Math.min(inOpen[i - 2], inClose[i - 2]) < inClose[i - 4]
            && Math.min(inOpen[i - 1], inClose[i - 1]) < inClose[i - 4]
            && Math.min(inOpen[i - 2], inClose[i - 2]) > inClose[i - 4] - RealBody(i - 4, inOpen, inClose) * optInPenetration
            && Math.min(inOpen[i - 1], inClose[i - 1]) > inClose[i - 4] - RealBody(i - 4, inOpen, inClose) * optInPenetration
            && Math.max(inClose[i - 2], inOpen[i - 2]) < inOpen[i - 3]
            && Math.max(inClose[i - 1], inOpen[i - 1]) < Math.max(inClose[i - 2], inOpen[i - 2])
            && inOpen[i] > inClose[i - 1]
            && inClose[i] > Math.max(Math.max(inHigh[i - 3], inHigh[i - 2]), inHigh[i - 1])) {
            outInteger[outIndex++] = 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        BodyPeriodTotal[4] += CandleRange(CandleSettingType.BodyLong, i - 4, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex - 4, inOpen, inHigh, inLow, inClose);

        totIndex = 3;
        while (totIndex >= 1) {
            BodyPeriodTotal[totIndex] += CandleRange(CandleSettingType.BodyShort, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(CandleSettingType.BodyShort, BodyShortTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);

            --
            totIndex;
        }
        i++;
        BodyShortTrailingIndex++;
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
function CdlMatHoldLookback(optInPenetration:Float):Int {
    // DEFAULT FLOAT
    // if (optInPenetration == null) {
    //     optInPenetration = 5.000000e-1;
    // }
    if (optInPenetration < 0) {
        return -1;
    }
    optInPenetration;
    return (TAIntMax(Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod, Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod) + 4);
}
