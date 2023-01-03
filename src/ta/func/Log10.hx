package ta.func;

@:keep
function Log10(startIndex:Int, endIndex:Int, inReal:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var outIndex:Int;
    var i:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inReal == null) {
        throw new TAException(BadParam);
    }

    i = startIndex;
    outIndex = 0;
    while (i <= endIndex) { // TODO: Fix log10
        var log10 = function(v:Float) {
            return (Math.log(v) / Math.log(10));
        };
        outReal[outIndex] = log10(inReal[i]);
        i++;
        outIndex++;
    }

    outNBElement = outIndex;
    outBegIndex = startIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function Log10Lookback() {
    return 0;
}
