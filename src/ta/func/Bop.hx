package ta.func;

import ta.func.Utility.IsZeroOrNeg;

@:keep
function Bop(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var outIndex:Int, i:Int;
    var tempReal:Float;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inOpen == null || inHigh == null || inLow == null || inClose == null) {
        throw new TAException(BadParam);
    }
    outIndex = 0;
    i = startIndex;
    while (i <= endIndex) {

        tempReal = inHigh[i] - inLow[i];
        if (IsZeroOrNeg(tempReal)) {
            outReal[outIndex++] = 0.0;
        } else {
            outReal[outIndex++] = (inClose[i] - inOpen[i]) / tempReal;
        }

        i++;
    }

    outNBElement = outIndex;
    outBegIndex = startIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };}

@:keep
function BopLookback() {
    return 0;
}
