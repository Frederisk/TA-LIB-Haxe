package ta.func;

import ta.func.Utility.RealBodyGapDown;
import ta.func.Utility.RealBodyGapUp;
import ta.func.Utility.CandleColor;

@:keep
function CdlXSideGap3Methods(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var i:Int, outIndex:Int, lookbackTotal:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inOpen == null || inHigh == null || inLow == null || inClose == null) {
        throw new TAException(BadParam);
    }

    lookbackTotal = CdlXSideGap3MethodsLookback();

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

    i = startIndex;

    outIndex = 0;
    do {
        if (CandleColor(i - 2, inOpen, inClose) == CandleColor(i - 1, inOpen, inClose)
            && CandleColor(i - 1, inOpen, inClose) == -CandleColor(i, inOpen, inClose)
            && inOpen[i] < Math.max(inClose[i - 1], inOpen[i - 1])
            && inOpen[i] > Math.min(inClose[i - 1], inOpen[i - 1])
            && inClose[i] < Math.max(inClose[i - 2], inOpen[i - 2])
            && inClose[i] > Math.min(inClose[i - 2], inOpen[i - 2])
            && ((CandleColor(i - 2, inOpen, inClose) == 1 && RealBodyGapUp(i - 1, i - 2, inOpen, inClose))
                || (CandleColor(i - 2, inOpen, inClose) == -1 && RealBodyGapDown(i - 1, i - 2, inOpen, inClose)))) {
            outInteger[outIndex++] = CandleColor(i - 2, inOpen, inClose) * 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        i++;
    } while (i <= endIndex);

    outNBElement = outIndex;
    outBegIndex = startIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outInteger: outInteger
    };
}

function CdlXSideGap3MethodsLookback():Int {
    return 2;
}
