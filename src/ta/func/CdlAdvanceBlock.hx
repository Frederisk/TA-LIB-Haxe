package ta.func;

import ta.Globals.CandleSettingType;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleRange;
import ta.func.Utility.RealBody;
import ta.func.Utility.TAIntMax;
import ta.func.Utility.UpperShadow;

@:keep
function CdlAdvanceBlock(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var ShadowShortPeriodTotal:Array<Float>; // 3
    var ShadowLongPeriodTotal:Array<Float>; // 2
    var NearPeriodTotal:Array<Float>; // 3
    var FarPeriodTotal:Array<Float>; // 3
    var BodyLongPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        totIndex:Int,
        BodyLongTrailingIndex:Int,
        ShadowShortTrailingIndex:Int,
        ShadowLongTrailingIndex:Int,
        NearTrailingIndex:Int,
        FarTrailingIndex:Int,
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

    lookbackTotal = CdlAdvanceBlockLookback();

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

    ShadowShortPeriodTotal = [0, 0, 0];
    ShadowShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowShort].avgPeriod;
    ShadowLongPeriodTotal = [0, 0];
    ShadowLongTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowLong].avgPeriod;
    NearPeriodTotal = [0, 0, 0];
    NearTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.Near].avgPeriod;
    FarPeriodTotal = [0, 0, 0];
    FarTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.Far].avgPeriod;
    BodyLongPeriodTotal = 0;
    BodyLongTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod;

    i = ShadowShortTrailingIndex;
    while (i < startIndex) {
        ShadowShortPeriodTotal[2] += CandleRange(ShadowShort, i - 2, inOpen, inHigh, inLow, inClose);
        ShadowShortPeriodTotal[1] += CandleRange(ShadowShort, i - 1, inOpen, inHigh, inLow, inClose);
        ShadowShortPeriodTotal[0] += CandleRange(ShadowShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = ShadowLongTrailingIndex;
    while (i < startIndex) {
        ShadowLongPeriodTotal[1] += CandleRange(ShadowLong, i - 1, inOpen, inHigh, inLow, inClose);
        ShadowLongPeriodTotal[0] += CandleRange(ShadowLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = NearTrailingIndex;
    while (i < startIndex) {
        NearPeriodTotal[2] += CandleRange(Near, i - 2, inOpen, inHigh, inLow, inClose);
        NearPeriodTotal[1] += CandleRange(Near, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = FarTrailingIndex;
    while (i < startIndex) {
        FarPeriodTotal[2] += CandleRange(Far, i - 2, inOpen, inHigh, inLow, inClose);
        FarPeriodTotal[1] += CandleRange(Far, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = BodyLongTrailingIndex;
    while (i < startIndex) {
        BodyLongPeriodTotal += CandleRange(BodyLong, i - 2, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 2, inOpen, inClose) == 1
            && CandleColor(i - 1, inOpen, inClose) == 1
            && CandleColor(i, inOpen, inClose) == 1
            && inClose[i] > inClose[i - 1]
            && inClose[i - 1] > inClose[i - 2]
            && inOpen[i - 1] > inOpen[i - 2]
            && inOpen[i - 1] <= inClose[i - 2] + CandleAverage(Near, NearPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && inOpen[i] > inOpen[i - 1]
            && inOpen[i] <= inClose[i - 1] + CandleAverage(Near, NearPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && RealBody(i - 2, inOpen, inClose) > CandleAverage(BodyLong, BodyLongPeriodTotal, i - 2, inOpen, inHigh, inLow, inClose)
            && UpperShadow(i - 2, inOpen, inHigh, inClose) < CandleAverage(ShadowShort, ShadowShortPeriodTotal[2], i - 2, inOpen, inHigh, inLow, inClose)
            && ((RealBody(i - 1, inOpen, inClose) < RealBody(i - 2, inOpen, inClose)
                - CandleAverage(Far, FarPeriodTotal[2], i - 2, inOpen, inHigh, inLow,
                    inClose) && RealBody(i, inOpen, inClose) < RealBody(i - 1, inOpen, inClose)
                + CandleAverage(Near, NearPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose))
                || (RealBody(i, inOpen, inClose) < RealBody(i - 1, inOpen, inClose)
                    - CandleAverage(Far, FarPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose))
                || (RealBody(i, inOpen, inClose) < RealBody(i - 1, inOpen, inClose)
                    && RealBody(i - 1, inOpen, inClose) < RealBody(i - 2, inOpen, inClose)
                    && (UpperShadow(i, inOpen, inHigh, inClose) > CandleAverage(ShadowShort, ShadowShortPeriodTotal[0], i, inOpen, inHigh, inLow, inClose)
                        || UpperShadow(i - 1, inOpen, inHigh,
                            inClose) > CandleAverage(ShadowShort, ShadowShortPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)))
                || (RealBody(i, inOpen, inClose) < RealBody(i - 1, inOpen, inClose)
                    && UpperShadow(i, inOpen, inHigh, inClose) > CandleAverage(ShadowLong, ShadowLongPeriodTotal[0], i, inOpen, inHigh, inLow, inClose)))) {
            outInteger[outIndex++] = -100;
        } else {
            outInteger[outIndex++] = 0;
        }
        totIndex = 2;
        while (totIndex >= 0) {
            ShadowShortPeriodTotal[totIndex] += CandleRange(ShadowShort, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(ShadowShort, ShadowShortTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);

            --
            totIndex;
        }

        totIndex = 1;
        while (totIndex >= 0) {
            ShadowLongPeriodTotal[totIndex] += CandleRange(ShadowLong, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(ShadowLong, ShadowLongTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);

            --
            totIndex;
        }

        totIndex = 2;
        while (totIndex >= 1) {
            FarPeriodTotal[totIndex] += CandleRange(Far, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(Far, FarTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);
            NearPeriodTotal[totIndex] += CandleRange(Near, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(Near, NearTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);

            --
            totIndex;
        }
        BodyLongPeriodTotal += CandleRange(BodyLong, i - 2, inOpen, inHigh, inLow, inClose)
            - CandleRange(BodyLong, BodyLongTrailingIndex - 2, inOpen, inHigh, inLow, inClose);
        i++;
        ShadowShortTrailingIndex++;
        ShadowLongTrailingIndex++;
        NearTrailingIndex++;
        FarTrailingIndex++;
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
function CdlAdvanceBlockLookback():Int {
    return (TAIntMax(TAIntMax(TAIntMax(Globals.candleSettings[CandleSettingType.ShadowLong].avgPeriod,
        Globals.candleSettings[CandleSettingType.ShadowShort].avgPeriod),
        TAIntMax(Globals.candleSettings[CandleSettingType.Far].avgPeriod, Globals.candleSettings[CandleSettingType.Near].avgPeriod)),
        Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod)
        + 2);
}
