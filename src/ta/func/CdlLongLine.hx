package ta.func;

import ta.func.Utility.CandleColor;
import ta.func.Utility.LowerShadow;
import ta.func.Utility.UpperShadow;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;
import ta.func.Utility.TAIntMax;

@:keep
function CdlLongLine(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyPeriodTotal:Float, ShadowPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        BodyTrailingIndex:Int,
        ShadowTrailingIndex:Int,
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

    lookbackTotal = CdlLongLineLookback();

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
    BodyTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod;
    ShadowPeriodTotal = 0;
    ShadowTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowShort].avgPeriod;

    i = BodyTrailingIndex;
    while (i < startIndex) {
        BodyPeriodTotal += CandleRange(CandleSettingType.BodyLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = ShadowTrailingIndex;
    while (i < startIndex) {
        ShadowPeriodTotal += CandleRange(CandleSettingType.ShadowShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }

    outIndex = 0;
    do {
        if (RealBody(i, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && UpperShadow(i, inOpen, inHigh, inClose) < CandleAverage(CandleSettingType.ShadowShort, ShadowPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && LowerShadow(i, inOpen, inLow, inClose) < CandleAverage(CandleSettingType.ShadowShort, ShadowPeriodTotal, i, inOpen, inHigh, inLow, inClose)) {
            outInteger[outIndex++] = CandleColor(i, inOpen, inClose) * 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        BodyPeriodTotal += CandleRange(CandleSettingType.BodyLong, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyLong, BodyTrailingIndex, inOpen, inHigh, inLow, inClose);
        ShadowPeriodTotal += CandleRange(CandleSettingType.ShadowShort, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.ShadowShort, ShadowTrailingIndex, inOpen, inHigh, inLow, inClose);
        i++;
        BodyTrailingIndex++;
        ShadowTrailingIndex++;
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
function CdlLongLineLookback() {
    return TAIntMax(Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod, Globals.candleSettings[CandleSettingType.ShadowShort].avgPeriod);
}
