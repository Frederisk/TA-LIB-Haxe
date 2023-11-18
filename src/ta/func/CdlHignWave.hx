package ta.func;

import ta.func.Utility.LowerShadow;
import ta.func.Utility.CandleRange;
import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.UpperShadow;
import ta.func.Utility.RealBody;
import ta.Globals.CandleSettingType;
import ta.func.Utility.TAIntMax;

@:keep
function CdlHignWave(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyPeriodTotal:Float, ShadowPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        BodyTrailingIndex:Int,
        ShadowTrailingIndex:Int,
        lookbackTotal:Int;

    lookbackTotal = CdlHignWaveLookback();

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
    ShadowPeriodTotal = 0;
    ShadowTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowVeryLong].avgPeriod;

    i = BodyTrailingIndex;
    while (i < startIndex) {
        BodyPeriodTotal += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = ShadowTrailingIndex;
    while (i < startIndex) {
        ShadowPeriodTotal += CandleRange(CandleSettingType.ShadowVeryLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }

    outIndex = 0;
    do {
        if (RealBody(i, inOpen, inClose) < CandleAverage(CandleSettingType.BodyShort, BodyPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && UpperShadow(i, inOpen, inHigh, inClose) > CandleAverage(CandleSettingType.ShadowVeryLong, ShadowPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && LowerShadow(i, inOpen, inLow,
                inClose) > CandleAverage(CandleSettingType.ShadowVeryLong, ShadowPeriodTotal, i, inOpen, inHigh, inLow, inClose)) {
            outInteger[outIndex++] = CandleColor(i, inOpen, inClose) * 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        BodyPeriodTotal += CandleRange(CandleSettingType.BodyShort, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyShort, BodyTrailingIndex, inOpen, inHigh, inLow, inClose);
        ShadowPeriodTotal += CandleRange(CandleSettingType.ShadowVeryLong, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.ShadowVeryLong, ShadowTrailingIndex, inOpen, inHigh, inLow, inClose);
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
function CdlHignWaveLookback():Int {
    return TAIntMax(Globals.candleSettings[CandleSettingType.BodyShort].avgPeriod, Globals.candleSettings[CandleSettingType.ShadowVeryLong].avgPeriod);
}
