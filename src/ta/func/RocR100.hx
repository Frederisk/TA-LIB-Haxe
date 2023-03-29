package ta.func;

@:keep
function RocR100(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var inIndex:Int, outIndex:Int, trailingIndex:Int;
    var tempReal:Float;

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
    //     optInTimePeriod = 10;
    // } else
    if (optInTimePeriod < 1) {
        throw new TAException(BadParam);
    }

    if (startIndex < optInTimePeriod) {
        startIndex = optInTimePeriod;
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

    if (startIndex < optInTimePeriod) {
        startIndex = optInTimePeriod;
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

    outIndex = 0;
    inIndex = startIndex;
    trailingIndex = startIndex - optInTimePeriod;

    while (inIndex <= endIndex) {
        tempReal = inReal[trailingIndex++];
        if (tempReal != 0.0)
            outReal[outIndex++] = (inReal[inIndex] / tempReal) * 100.0;
        else
            outReal[outIndex++] = 0.0;

        inIndex++;
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
function RocR100Lookback(optInTimePeriod:Int) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 10;
    // } else
    if (optInTimePeriod < 1) {
        return -1;
    }

    return optInTimePeriod;
}
