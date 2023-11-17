package ta.func;

import ta.func.Utility.TAIntMax;
import ta.func.Utility.CandleColor;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;

@:keep
function CdlRiseFall3Methods(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    // ARRAY_LOCAL(BodyPeriodTotal, 5);
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

    lookbackTotal = CdlRiseFall3MethodsLookback();

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

    // BodyPeriodTotal[4] = 0;
    // BodyPeriodTotal[3] = 0;
    // BodyPeriodTotal[2] = 0;
    // BodyPeriodTotal[1] = 0;
    // BodyPeriodTotal[0] = 0;
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
        BodyPeriodTotal[0] += CandleRange(CandleSettingType.BodyLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (RealBody(i - 4, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyPeriodTotal[4], i - 4, inOpen, inHigh, inLow, inClose)
            && RealBody(i - 3, inOpen, inClose) < CandleAverage(CandleSettingType.BodyShort, BodyPeriodTotal[3], i - 3, inOpen, inHigh, inLow, inClose)
            && RealBody(i - 2, inOpen, inClose) < CandleAverage(CandleSettingType.BodyShort, BodyPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && RealBody(i - 1, inOpen, inClose) < CandleAverage(CandleSettingType.BodyShort, BodyPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && RealBody(i, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyPeriodTotal[0], i, inOpen, inHigh, inLow, inClose)
            && CandleColor(i - 4, inOpen, inClose) == -CandleColor(i - 3, inOpen, inClose)
            && CandleColor(i - 3, inOpen, inClose) == CandleColor(i - 2, inOpen, inClose)
            && CandleColor(i - 2, inOpen, inClose) == CandleColor(i - 1, inOpen, inClose)
            && CandleColor(i - 1, inOpen, inClose) == -CandleColor(i, inOpen, inClose)
            && Math.min(inOpen[i - 3], inClose[i - 3]) < inHigh[i - 4]
            && Math.max(inOpen[i - 3], inClose[i - 3]) > inLow[i - 4]
            && Math.min(inOpen[i - 2], inClose[i - 2]) < inHigh[i - 4]
            && Math.max(inOpen[i - 2], inClose[i - 2]) > inLow[i - 4]
            && Math.min(inOpen[i - 1], inClose[i - 1]) < inHigh[i - 4]
            && Math.max(inOpen[i - 1], inClose[i - 1]) > inLow[i - 4]
            && inClose[i - 2] * CandleColor(i - 4, inOpen, inClose) < inClose[i - 3] * CandleColor(i - 4, inOpen, inClose)
            && inClose[i - 1] * CandleColor(i - 4, inOpen, inClose) < inClose[i - 2] * CandleColor(i - 4, inOpen, inClose)
            && inOpen[i] * CandleColor(i - 4, inOpen, inClose) > inClose[i - 1] * CandleColor(i - 4, inOpen, inClose)
            && inClose[i] * CandleColor(i - 4, inOpen, inClose) > inClose[i - 4] * CandleColor(i - 4, inOpen, inClose)) {
            outInteger[outIndex++] = 100 * CandleColor(i - 4, inOpen, inClose);
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
        BodyPeriodTotal[0] += CandleRange(CandleSettingType.BodyLong, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex, inOpen, inHigh, inLow, inClose);
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
function CdlRiseFall3MethodsLookback():Int {
    return (TAIntMax(Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod, Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod) + 4);
}
