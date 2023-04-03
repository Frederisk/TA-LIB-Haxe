package ta.func;

@:keep
function Wma(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var inIndex:Int, outIndex:Int, i:Int, trailingIndex:Int, divider:Int;
    var periodSum:Float, periodSub:Float, tempReal:Float, trailingValue:Float;
    var lookbackTotal:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inReal == null) {
        throw new TAException(BadParam);
    }
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 2) {
        throw new TAException(BadParam);
    }

    lookbackTotal = optInTimePeriod - 1;

    if (startIndex < lookbackTotal) {
        startIndex = lookbackTotal;
    }

    if (startIndex > endIndex) {
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    if (optInTimePeriod == 1) {
        outBegIndex = startIndex;
        outNBElement = endIndex - startIndex + 1;

        // ARRAY_MEMMOVE(outReal, 0, inReal, startIndex, (int) VALUE_HANDLE_DEREF(outNBElement));
        // memmove( & outReal[0], & inReal[startIndex], ((int)( * outNBElement)) * sizeof(double))
        outReal = inReal.slice(startIndex, startIndex + outNBElement);
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    divider = (optInTimePeriod * (optInTimePeriod + 1)) >> 1;

    outIndex = 0;
    trailingIndex = startIndex - lookbackTotal;

    periodSum = periodSub = 0.0;
    inIndex = trailingIndex;
    i = 1;
    while (inIndex < startIndex) {
        tempReal = inReal[inIndex++];
        periodSub += tempReal;
        periodSum += tempReal * i;
        i++;
    }
    trailingValue = 0.0;

    while (inIndex <= endIndex) {
        tempReal = inReal[inIndex++];
        periodSub += tempReal;
        periodSub -= trailingValue;
        periodSum += tempReal * optInTimePeriod;

        trailingValue = inReal[trailingIndex++];

        outReal[outIndex++] = periodSum / divider;

        periodSum -= periodSub;
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
function WmaLookback(optInTimePeriod:Int) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }

    return (optInTimePeriod - 1);
}
