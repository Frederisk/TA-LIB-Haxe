package ta.func;

import ta.func.Utility.UpperShadow;
import ta.func.Utility.LowerShadow;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;
import ta.func.Utility.TAIntMax;

@:keep
function CdlHangingMan(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyPeriodTotal:Float,
        ShadowLongPeriodTotal:Float,
        ShadowVeryShortPeriodTotal:Float,
        NearPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        BodyTrailingIndex:Int,
        ShadowLongTrailingIndex:Int,
        ShadowVeryShortTrailingIndex:Int,
        NearTrailingIndex:Int,
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

    lookbackTotal = CdlHangingManLookback();

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

    BodyPeriodTotal = 0;
    BodyTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod;
    ShadowLongPeriodTotal = 0;
    ShadowLongTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowLong].avgPeriod;
    ShadowVeryShortPeriodTotal = 0;
    ShadowVeryShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod;
    NearPeriodTotal = 0;
    NearTrailingIndex = startIndex - 1 - Globals.candleSettings[CandleSettingType.Near].avgPeriod;

    i = BodyTrailingIndex;
    while (i < startIndex) {
        BodyPeriodTotal += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = ShadowLongTrailingIndex;
    while (i < startIndex) {
        ShadowLongPeriodTotal += CandleRange(CandleSettingType.ShadowLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = ShadowVeryShortTrailingIndex;
    while (i < startIndex) {
        ShadowVeryShortPeriodTotal += CandleRange(CandleSettingType.ShadowVeryShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = NearTrailingIndex;
    while (i < startIndex - 1) {
        NearPeriodTotal += CandleRange(CandleSettingType.Near, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (RealBody(i, inOpen, inClose) < CandleAverage(CandleSettingType.BodyShort, BodyPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && LowerShadow(i, inOpen, inLow, inClose) > CandleAverage(CandleSettingType.ShadowLong, ShadowLongPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && UpperShadow(i, inOpen, inHigh,
                inClose) < CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && Math.min(inClose[i],
                inOpen[i]) >= inHigh[i - 1] - CandleAverage(CandleSettingType.Near, NearPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose)) {
            outInteger[outIndex++] = -100;
        } else {
            outInteger[outIndex++] = 0;
        }

        BodyPeriodTotal += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyShort, BodyTrailingIndex, inOpen, inHigh, inLow, inClose);
        ShadowLongPeriodTotal += CandleRange(CandleSettingType.ShadowLong, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.ShadowLong, ShadowLongTrailingIndex, inOpen, inHigh, inLow, inClose);
        ShadowVeryShortPeriodTotal += CandleRange(CandleSettingType.ShadowVeryShort, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.ShadowVeryShort, ShadowVeryShortTrailingIndex, inOpen, inHigh, inLow, inClose);
        NearPeriodTotal += CandleRange(CandleSettingType.Near, i - 1, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.Near, NearTrailingIndex, inOpen, inHigh, inLow, inClose);
        i++;
        BodyTrailingIndex++;
        ShadowLongTrailingIndex++;
        ShadowVeryShortTrailingIndex++;
        NearTrailingIndex++;
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
function CdlHangingManLookback() {
    return (TAIntMax(TAIntMax(TAIntMax(Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod,
        Globals.candleSettings[CandleSettingType.ShadowLong].avgPeriod),
        Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod),
        Globals.candleSettings[CandleSettingType.Near].avgPeriod)
        + 1);
}
