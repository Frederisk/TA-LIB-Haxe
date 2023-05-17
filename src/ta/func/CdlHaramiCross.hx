package ta.func;

import ta.func.Utility.CandleColor;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBody;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;
import ta.func.Utility.TAIntMax;

@:keep
function CdlHaramiCross(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyDojiPeriodTotal:Float, BodyLongPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        BodyDojiTrailingIndex:Int,
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

    lookbackTotal = CdlHaramiCrossLookback();

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
    BodyLongTrailingIndex = startIndex - 1 - Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod;
    BodyDojiTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyDoji].avgPeriod;

    i = BodyLongTrailingIndex;
    while (i < startIndex - 1) {
        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = BodyDojiTrailingIndex;
    while (i < startIndex) {
        BodyDojiPeriodTotal += CandleRange(CandleSettingType.BodyDoji, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = startIndex;

    outIndex = 0;
    do {
        if (RealBody(i - 1, inOpen, inClose) > CandleAverage(CandleSettingType.BodyLong, BodyLongPeriodTotal, i - 1, inOpen, inHigh, inLow, inClose)
            && RealBody(i, inOpen, inClose) <= CandleAverage(CandleSettingType.BodyDoji, BodyDojiPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && Math.max(inClose[i], inOpen[i]) < Math.max(inClose[i - 1], inOpen[i - 1])
            && Math.min(inClose[i], inOpen[i]) > Math.min(inClose[i - 1], inOpen[i - 1])) {
            outInteger[outIndex++] = -CandleColor(i - 1, inOpen, inClose) * 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        BodyLongPeriodTotal += CandleRange(CandleSettingType.BodyLong, i - 1, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyLong, BodyLongTrailingIndex, inOpen, inHigh, inLow, inClose);
        BodyDojiPeriodTotal += CandleRange(CandleSettingType.BodyDoji, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyDoji, BodyDojiTrailingIndex, inOpen, inHigh, inLow, inClose);
        i++;
        BodyLongTrailingIndex++;
        BodyDojiTrailingIndex++;
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
function CdlHaramiCrossLookback() {
    return (TAIntMax(Globals.candleSettings[CandleSettingType.BodyDoji].avgPeriod, Globals.candleSettings[CandleSettingType.BodyLong].avgPeriod) + 1);
}
