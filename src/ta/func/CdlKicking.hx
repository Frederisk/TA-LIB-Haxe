package ta.func;

import ta.func.Utility.CandleRange;
import ta.func.Utility.UpperShadow;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.CandleGapUp;
import ta.func.Utility.CandleGapDown;
import ta.func.Utility.LowerShadow;
import ta.func.Utility.RealBody;
import ta.Globals.CandleSettingType;
import ta.func.Utility.CandleColor;
import ta.func.Utility.TAIntMax;

@:keep
function CdlKicking(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var ShadowVeryShortPeriodTotal:Array<Float>; // 2
    var BodyLongPeriodTotal:Array<Float>; // 2

    var i:Int,
        outIndex:Int,
        totIndex:Int,
        ShadowVeryShortTrailingIndex:Int,
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

    lookbackTotal = CdlKickingLookback();

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

    // ShadowVeryShortPeriodTotal[1] = 0;
    // ShadowVeryShortPeriodTotal[0] = 0;
    ShadowVeryShortPeriodTotal = [0, 0];
    ShadowVeryShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod;
    // BodyLongPeriodTotal[1] = 0;
    // BodyLongPeriodTotal[0] = 0;
    BodyLongPeriodTotal = [0, 0];
    BodyLongTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod;

    i = ShadowVeryShortTrailingIndex;
    while (i < startIndex) {
        ShadowVeryShortPeriodTotal[1] += CandleRange(CandleSettingType.ShadowVeryShort, i - 1, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal[0] += CandleRange(CandleSettingType.ShadowVeryShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = BodyLongTrailingIndex;
    while (i < startIndex) {
        BodyLongPeriodTotal[1] += CandleRange(CandleSettingType.BodyLong, i - 1, inOpen, inHigh, inLow, inClose);
        BodyLongPeriodTotal[0] += CandleRange(CandleSettingType.BodyLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 1, inOpen, inClose) == -CandleColor(i, inOpen, inClose)
            && RealBody(i - 1, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && UpperShadow(i - 1, inOpen, inHigh,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && LowerShadow(i - 1, inOpen, inLow,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[1], i - 1, inOpen, inHigh, inLow, inClose)
            && RealBody(i, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal[0], i, inOpen, inHigh, inLow, inClose)
            && UpperShadow(i, inOpen, inHigh,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[0], i, inOpen, inHigh, inLow, inClose)
            && LowerShadow(i, inOpen, inLow,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal[0], i, inOpen, inHigh, inLow, inClose)
            && ((CandleColor(i - 1, inOpen, inClose) == -1 && CandleGapUp(i, i - 1, inHigh, inLow))
                || (CandleColor(i - 1, inOpen, inClose) == 1 && CandleGapDown(i, i - 1, inHigh, inLow)))) {
            outInteger[outIndex++] = CandleColor(i, inOpen, inClose) * 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        totIndex = 1;
        while (totIndex >= 0) {
            BodyLongPeriodTotal[totIndex] += CandleRange(CandleSettingType.BodyLong, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);
            ShadowVeryShortPeriodTotal[totIndex] += CandleRange(CandleSettingType.ShadowVeryShort, i - totIndex, inOpen, inHigh, inLow, inClose)
                - CandleRange(CandleSettingType.ShadowVeryShort, ShadowVeryShortTrailingIndex - totIndex, inOpen, inHigh, inLow, inClose);

            --
            totIndex;
        }
        i++;
        ShadowVeryShortTrailingIndex++;
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
function CdlKickingLookback() {
    return (TAIntMax(Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod, Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod) + 1);
}
