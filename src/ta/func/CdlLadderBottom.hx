package ta.func;

import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.UpperShadow;
import ta.func.Utility.CandleColor;

@:keep
function CdlLadderBottom(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var ShadowVeryShortPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        ShadowVeryShortTrailingIndex:Int,
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

    lookbackTotal = CdlLadderBottomLookback();

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

    ShadowVeryShortPeriodTotal = 0;
    ShadowVeryShortTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod;

    i = ShadowVeryShortTrailingIndex;
    while (i < startIndex) {
        ShadowVeryShortPeriodTotal += CandleRange(CandleSettingType.ShadowVeryShort, i - 1, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 4, inOpen, inClose) == -1
            && CandleColor(i - 3, inOpen, inClose) == -1
            && CandleColor(i - 2, inOpen, inClose) == -1
            && inOpen[i - 4] > inOpen[i - 3]
            && inOpen[i - 3] > inOpen[i - 2]
            && inClose[i - 4] > inClose[i - 3]
            && inClose[i - 3] > inClose[i - 2]
            && CandleColor(i - 1, inOpen, inClose) == -1
            && UpperShadow(i - 1, inOpen, inHigh,
                inClose) > CandleAverage(CandleSettingType.ShadowVeryShort, ShadowVeryShortPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose)
            && CandleColor(i, inOpen, inClose) == 1
            && inOpen[i] > inOpen[i - 1]
            && inClose[i] > inHigh[i - 1]) {
            outInteger[outIndex++] = 100;
        } else {
            outInteger[outIndex++] = 0;
        }
        ShadowVeryShortPeriodTotal += CandleRange(CandleSettingType.ShadowVeryShort, i - 1, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.ShadowVeryShort, ShadowVeryShortTrailingIndex - 1, inOpen, inHigh, inLow, inClose);
        i++;
        ShadowVeryShortTrailingIndex++;
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
function CdlLadderBottomLookback() {
    return (Globals.candleSettings[CandleSettingType.ShadowVeryShort].avgPeriod + 4);
}
