package ta.func;

import ta.func.Utility.RealBody;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.CandleRange;
import ta.Globals.CandleSettingType;

@:keep
function CdlDoji(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyDojiPeriodTotal:Float;
    var i:Int, outIndex:Int, BodyDojiTrailingIndex:Int, lookbackTotal:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inOpen == null || inHigh == null || inLow == null || inClose == null) {
        throw new TAException(BadParam);
    }

    lookbackTotal = CdlDojiLookback();

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

    BodyDojiPeriodTotal = 0;
    BodyDojiTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyDoji].avgPeriod;

    i = BodyDojiTrailingIndex;
    while (i < startIndex) {
        BodyDojiPeriodTotal += CandleRange(CandleSettingType.BodyDoji, i, inOpen, inHigh, inLow, inClose);
        i++;
    }

    outIndex = 0;
    do {
        if (RealBody(i, inOpen, inClose) <= CandleAverage(CandleSettingType.BodyDoji, BodyDojiPeriodTotal, i, inOpen, inHigh, inLow, inClose)) {
            outInteger[outIndex++] = 100;
        } else {
            outInteger[outIndex++] = 0;
        }
        BodyDojiPeriodTotal += CandleRange(CandleSettingType.BodyDoji, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyDoji, BodyDojiTrailingIndex, inOpen, inHigh, inLow, inClose);
        i++;
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
function CdlDojiLookback() {
    return Globals.candleSettings[CandleSettingType.BodyDoji].avgPeriod;
}
