package ta.func;

@:keep
function Ad(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>, inVolume:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var nbBar:Int, currentBar:Int, outIndex:Int;
    var high:Float, low:Float, close:Float, tmp:Float;
    var ad:Float;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inHigh == null || inLow == null || inClose == null || inVolume == null) {
        throw new TAException(BadParam);
    }

    nbBar = endIndex - startIndex + 1;
    outNBElement = nbBar;
    outBegIndex = startIndex;
    currentBar = startIndex;
    outIndex = 0;
    ad = 0.0;

    while (nbBar != 0) {
        high = inHigh[currentBar];
        low = inLow[currentBar];
        tmp = high - low;
        close = inClose[currentBar];

        if (tmp > 0.0)
            ad += (((close - low) - (high - close)) / tmp) * (inVolume[currentBar]);

        outReal[outIndex++] = ad;

        currentBar++;
        nbBar--;
    }

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function AdLookback() {
    return 0;
}
