package ta.func;

import ta.func.Utility.CandleRange;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.CandleColor;
import ta.func.Utility.RealBodyGapUp;
import ta.func.Utility.RealBody;
import ta.Globals.CandleSettingType;
import ta.func.Utility.TAIntMax;

@:keep
function CdlEveningDojiStar(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>,
        optInPenetration:Float) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyDojiPeriodTotal:Float,
        BodyLongPeriodTotal:Float,
        BodyShortPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        BodyDojiTrailingIndex:Int,
        BodyLongTrailingIndex:Int,
        BodyShortTrailingIndex:Int,
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

    lookbackTotal = CdlEveningDojiStarLookback(optInPenetration);

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
    BodyDojiPeriodTotal = 0;
    BodyShortPeriodTotal = 0;
    BodyLongTrailingIndex = startIndex - 2 - Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod;
    BodyDojiTrailingIndex = startIndex - 1 - Globals.candleSettings[CandleSettingType.BodyDoji].avgPeriod;
    BodyShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod;

    i = BodyLongTrailingIndex;
    while (i < startIndex - 2) {
        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = BodyDojiTrailingIndex;
    while (i < startIndex - 1) {
        BodyDojiPeriodTotal += CandleRange(CandleSettingType.BodyDoji, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = BodyShortTrailingIndex;
    while (i < startIndex) {
        BodyShortPeriodTotal += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (RealBody(i - 2, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal, i - 2, inOpen, inHigh, inLow, inClose)
            && CandleColor(i - 2, inOpen, inClose) == 1
            && RealBody(i - 1, inOpen, inClose) <= CandleAverage(CandleSettingType.BodyDoji, BodyDojiPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose)
            && RealBodyGapUp(i - 1, i - 2, inOpen, inClose)
            && RealBody(i, inOpen, inClose) > CandleAverage(CandleSettingType.BodyShort, BodyShortPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && CandleColor(i, inOpen, inClose) == -1
            && inClose[i] < inClose[i - 2] - RealBody(i - 2, inOpen, inClose) * optInPenetration) {
            outInteger[outIndex++] = -100;
        } else {
            outInteger[outIndex++] = 0;
        }
        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i - 2, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex, inOpen, inHigh, inLow, inClose);
        BodyDojiPeriodTotal += CandleRange(CandleSettingType.BodyDoji, i - 1, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyDoji, BodyDojiTrailingIndex, inOpen, inHigh, inLow, inClose);
        BodyShortPeriodTotal += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyShort, BodyShortTrailingIndex, inOpen, inHigh, inLow, inClose);
        i++;
        BodyLongTrailingIndex++;
        BodyDojiTrailingIndex++;
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
function CdlEveningDojiStarLookback(optInPenetration:Float) {
    // DEFAULT FLOAT
    // if (optInPenetration == null) {
    //     optInPenetration = 3.000000e-1;
    // }
    if (optInPenetration < 0) {
        return -1;
    }

    optInPenetration;
    return (TAIntMax(TAIntMax(Globals.candleSettings[CandleSettingType.BodyDoji].avgPeriod, Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod),
        Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod)
        + 2);
}
