package ta.func;

@:keep
function Tanh(startIndex:Int, endIndex:Int, inReal:Array<Float>) {
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
    while (i <= endIndex) { // TODO: Fix tanh
        var tanh = function(v:Float) {
            return ((Math.exp(2 * v) - 1) / (Math.exp(2 * v) + 1));
        };
        outReal[outIndex] = tanh(inReal[i]);
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
function TanhLookback() {
    return 0;
}
