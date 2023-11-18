package ta.func;

@:keep
function Div(startIndex:Int, endIndex:Int, inReal0:Array<Float>, inReal1:Array<Float>) {
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
    if (inReal0 == null) {
        throw new TAException(BadParam);
    }
    if (inReal1 == null) {
        throw new TAException(BadParam);
    }

    i = startIndex;
    outIndex = 0;
    while (i <= endIndex) {
        outReal[outIndex] = inReal0[i] / inReal1[i];
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
function DivLookback():Int {
    return 0;
}
