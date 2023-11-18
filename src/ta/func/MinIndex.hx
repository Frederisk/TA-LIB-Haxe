package ta.func;

@:keep
function MinIndex(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var lowest:Float, tmp:Float;
    var outIndex:Int, nbInitialElementNeeded:Int;
    var trailingIndex:Int, today:Int, i:Int, lowestIndex:Int;

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

    if (startIndex < nbInitialElementNeeded) {
        startIndex = nbInitialElementNeeded;
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

    outIndex = 0;
    today = startIndex;
    trailingIndex = startIndex - nbInitialElementNeeded;
    lowestIndex = -1;
    lowest = 0.0;

    while (today <= endIndex) {
        tmp = inReal[today];

        if (lowestIndex < trailingIndex) {
            lowestIndex = trailingIndex;
            lowest = inReal[lowestIndex];
            i = lowestIndex;
            while (++i <= today) {
                tmp = inReal[i];
                if (tmp < lowest) {
                    lowestIndex = i;
                    lowest = tmp;
                }
            }
        } else if (tmp <= lowest) {
            lowestIndex = today;
            lowest = tmp;
        }

        outInteger[outIndex++] = lowestIndex;
        trailingIndex++;
        today++;
    }

    outBegIndex = startIndex;
    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outInteger: outInteger
    };
}

@:keep
function MinIndexLookback(optInTimePeriod:Int):Int {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }
    return (optInTimePeriod - 1);
}
