package ta.func;

@:keep
function Sum(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var periodTotal:Float, tempReal:Float;
    var i:Int, outIndex:Int, trailingIndex:Int, lookbackTotal:Int;

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

    lookbackTotal = (optInTimePeriod - 1);

    if (startIndex < lookbackTotal)
        startIndex = lookbackTotal;

    if (startIndex > endIndex) {
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    periodTotal = 0;
    trailingIndex = startIndex - lookbackTotal;

    i = trailingIndex;
    if (optInTimePeriod > 1) {
        while (i < startIndex)
            periodTotal += inReal[i++];
    }

    outIndex = 0;
    do {
        periodTotal += inReal[i++];
        tempReal = periodTotal;
        periodTotal -= inReal[trailingIndex++];
        outReal[outIndex++] = tempReal;
    } while (i <= endIndex);

    outBegIndex = startIndex;
    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function SumLookback(optInTimePeriod:Int) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }
    return (optInTimePeriod - 1);
}
