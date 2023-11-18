package ta.func;

@:keep
function Obv(startIndex:Int, endIndex:Int, inReal:Array<Float>, inVolume:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var i:Int;
    var outIndex:Int;
    var prevReal:Float, tempReal:Float, prevOBV:Float;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inReal == null) {
        throw new TAException(BadParam);
    }
    if (inVolume == null) {
        throw new TAException(BadParam);
    }

    prevOBV = inVolume[startIndex];
    prevReal = inReal[startIndex];
    outIndex = 0;

    i = startIndex;
    while (i <= endIndex) {
        tempReal = inReal[i];
        if (tempReal > prevReal) {
            prevOBV += inVolume[i];
        } else if (tempReal < prevReal) {
            prevOBV -= inVolume[i];
        }

        outReal[outIndex++] = prevOBV;
        prevReal = tempReal;

        i++;
    }

    outBegIndex = startIndex;
    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function ObvLookback():Int {
    return 0;
}
