package ta.func;

@:keep
function Max(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var highest:Float, tmp:Float;
    var outIndex:Int, nbInitialElementNeeded:Int;
    var trailingIndex:Int, today:Int, i:Int, highestIndex:Int;

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

    nbInitialElementNeeded = (optInTimePeriod - 1);

    if (startIndex < nbInitialElementNeeded)
        startIndex = nbInitialElementNeeded;

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
    today = startIndex;
    trailingIndex = startIndex - nbInitialElementNeeded;
    highestIndex = -1;
    highest = 0.0;

    while (today <= endIndex) {
        tmp = inReal[today];

        if (highestIndex < trailingIndex) {
            highestIndex = trailingIndex;
            highest = inReal[highestIndex];
            i = highestIndex;
            while (++i <= today) {
                tmp = inReal[i];
                if (tmp > highest) {
                    highestIndex = i;
                    highest = tmp;
                }
            }
        } else if (tmp >= highest) {
            highestIndex = today;
            highest = tmp;
        }

        outReal[outIndex++] = highest;
        trailingIndex++;
        today++;
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
function MaxLookback(optInTimePeriod:Int) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }
    return (optInTimePeriod - 1);
}
