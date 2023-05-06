package ta.func;

import ta.func.Utility.RealBody;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;

@:keep
function CdlDarkCloudCover(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>,
        optInPenetration:Float) {
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
    // DEFAULT FLOAT
    // if (optInPenetration == null) {
    //     optInPenetration = 5.000000e-1;
    // }
    if (optInPenetration < 0) {
        throw new TAException(BadParam);
    }

    lookbackTotal = CdlDarkCloudCoverLookback(optInPenetration);

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
        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 1, inOpen, inClose) == 1
            && RealBody(i - 1, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose)
            && CandleColor(i, inOpen, inClose) == -1
            && inOpen[i] > inHigh[i - 1]
            && inClose[i] > inOpen[i - 1]
            && inClose[i] < inClose[i - 1] - RealBody(i - 1, inOpen, inClose) * optInPenetration) {
            outInteger[outIndex++] = -100;
        } else {
            outInteger[outIndex++] = 0;
        }
        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i - 1, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex - 1, inOpen, inHigh, inLow, inClose);
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
function CdlDarkCloudCoverLookback(optInPenetration:Float) {
    // DEFAULT FLOAT
    // if (optInPenetration == null) {
    //     optInPenetration = 5.000000e-1;
    // }
    if (optInPenetration < 0) {
        return -1;
    }

    optInPenetration;
    return (Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod + 1);
}
