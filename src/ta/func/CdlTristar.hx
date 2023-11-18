package ta.func;

import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBodyGapUp;
import ta.func.Utility.RealBodyGapDown;

@:keep
function CdlTristar(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyPeriodTotal:Float;
    var i:Int, outIndex:Int, BodyTrailingIndex:Int, lookbackTotal:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inOpen == null || inHigh == null || inLow == null || inClose == null) {
        throw new TAException(BadParam);
    }

    lookbackTotal = CdlTristarLookback();

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
    BodyTrailingIndex = startIndex - 2 - Globals.candleSettings[CandleSettingType.BodyDoji].avgPeriod;

    i = BodyTrailingIndex;
    while (i < startIndex - 2) {
        BodyPeriodTotal += CandleRange(CandleSettingType.BodyDoji, i, inOpen, inHigh, inLow, inClose);
        i++;
    }

    i = startIndex;
    outIndex = 0;
    do {
        if (RealBody(i - 2, inOpen, inClose) <= CandleAverage(CandleSettingType.BodyDoji, BodyPeriodTotal, i - 2, inOpen, inHigh, inLow, inClose)
            && RealBody(i - 1, inOpen, inClose) <= CandleAverage(CandleSettingType.BodyDoji, BodyPeriodTotal, i - 2, inOpen, inHigh, inLow, inClose)
            && RealBody(i, inOpen, inClose) <= CandleAverage(CandleSettingType.BodyDoji, BodyPeriodTotal, i - 2, inOpen, inHigh, inLow, inClose)) {
            outInteger[outIndex] = 0;
            if (RealBodyGapUp(i - 1, i - 2, inOpen, inClose)
                && Math.max(inOpen[i], inClose[i]) < Math.max(inOpen[i - 1], inClose[i - 1])) {
                outInteger[outIndex] = -100;
            }
            if (RealBodyGapDown(i - 1, i - 2, inOpen, inClose)
                && Math.min(inOpen[i], inClose[i]) > Math.min(inOpen[i - 1], inClose[i - 1])) {
                outInteger[outIndex] = 0 + 100;
            }
            outIndex++;
        } else {
            outInteger[outIndex++] = 0;
        }

        BodyPeriodTotal += CandleRange(CandleSettingType.BodyDoji, i - 2, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyDoji, BodyTrailingIndex, inOpen, inHigh, inLow, inClose);
        i++;
        BodyTrailingIndex++;
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
function CdlTristarLookback():Int {
    return (Globals.candleSettings[CandleSettingType.BodyDoji].avgPeriod + 2);
}
