package ta.func;

import ta.func.Utility.CandleColor;

@:keep
function CdlEngulfing(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inOpen == null || inHigh == null || inLow == null || inClose == null) {
        throw new TAException(BadParam);
    }

    var i:Int, outIndex:Int, lookbackTotal:Int;

    lookbackTotal = CdlEngulfingLookback();

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
        if ((CandleColor(i, inOpen, inClose) == 1
            && CandleColor(i - 1, inOpen, inClose) == -1
            && inClose[i] > inOpen[i - 1]
            && inOpen[i] < inClose[i - 1])
            || (CandleColor(i, inOpen, inClose) == -1
                && CandleColor(i - 1, inOpen, inClose) == 1
                && inOpen[i] > inClose[i - 1]
                && inClose[i] < inOpen[i - 1]))
            outInteger[outIndex++] = CandleColor(i, inOpen, inClose) * 100;
        else
            outInteger[outIndex++] = 0;
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
function CdlEngulfingLookback():Int {
    return 2;
}
