package ta.func;

import ta.func.Utility.CandleColor;

@:keep
function Cdl3Outside(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
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

    lookbackTotal = Cdl3OutsideLookback();

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
        if ((CandleColor(i - 1,inOpen, inClose) == 1 && CandleColor(i - 2,inOpen, inClose) == -1 && inClose[i - 1] > inOpen[i - 2] && inOpen[i - 1] < inClose[i - 2]
            && inClose[i] > inClose[i - 1])
            || (CandleColor(i - 1,inOpen, inClose) == -1 && CandleColor(i - 2,inOpen, inClose) == 1 && inOpen[i - 1] > inClose[i - 2] && inClose[i - 1] < inOpen[i - 2]
                && inClose[i] < inClose[i - 1])) {
            outInteger[outIndex++] = CandleColor(i - 1,inOpen, inClose) * 100;
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

@:keep
function Cdl3OutsideLookback() {
    return 3;
}
