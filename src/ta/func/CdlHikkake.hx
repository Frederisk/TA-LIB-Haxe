package ta.func;

@:keep
function CdlHikkake(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var i:Int,
        outIndex:Int,
        lookbackTotal:Int,
        patternIndex:Int,
        patternResult:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inOpen == null || inHigh == null || inLow == null || inClose == null) {
        throw new TAException(BadParam);
    }

    lookbackTotal = CdlHikkakeLookback();

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

    patternIndex = 0;
    patternResult = 0;

    i = startIndex - 3;
    while (i < startIndex) {
        if (inHigh[i - 1] < inHigh[i - 2]
            && inLow[i - 1] > inLow[i - 2]
            && ((inHigh[i] < inHigh[i - 1] && inLow[i] < inLow[i - 1]) || (inHigh[i] > inHigh[i - 1] && inLow[i] > inLow[i - 1]))) {
            patternResult = 100 * (inHigh[i] < inHigh[i - 1] ? 1 : -1);
            patternIndex = i;
        } else if (i <= patternIndex + 3
            && ((patternResult > 0 && inClose[i] > inHigh[patternIndex - 1])
                || (patternResult < 0 && inClose[i] < inLow[patternIndex - 1])))
            patternIndex = 0;
        i++;
    }

    i = startIndex;

    outIndex = 0;
    do {
        if (inHigh[i - 1] < inHigh[i - 2]
            && inLow[i - 1] > inLow[i - 2]
            && ((inHigh[i] < inHigh[i - 1] && inLow[i] < inLow[i - 1]) || (inHigh[i] > inHigh[i - 1] && inLow[i] > inLow[i - 1]))) {
            patternResult = 100 * (inHigh[i] < inHigh[i - 1] ? 1 : -1);
            patternIndex = i;
            outInteger[outIndex++] = patternResult;
        } else if (i <= patternIndex + 3
            && ((patternResult > 0 && inClose[i] > inHigh[patternIndex - 1])
                || (patternResult < 0 && inClose[i] < inLow[patternIndex - 1]))) {
            outInteger[outIndex++] = patternResult + 100 * (patternResult > 0 ? 1 : -1);
            patternIndex = 0;
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
function CdlHikkakeLookback() {
    return 5;
}
