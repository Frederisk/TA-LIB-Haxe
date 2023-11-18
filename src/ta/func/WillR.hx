package ta.func;

@:keep
function WillR(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var lowest:Float, highest:Float, tmp:Float, diff:Float;
    var outIndex:Int, nbInitialElementNeeded:Int;
    var trailingIndex:Int, lowestIndex:Int, highestIndex:Int;
    var today:Int, i:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inHigh == null || inLow == null || inClose == null) {
        throw new TAException(BadParam);
    }
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
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
            outReal: outReal
        };
    }

    diff = 0.0;

    outIndex = 0;
    today = startIndex;
    trailingIndex = startIndex - nbInitialElementNeeded;
    lowestIndex = highestIndex = -1;
    diff = highest = lowest = 0.0;

    while (today <= endIndex) {
        tmp = inLow[today];
        if (lowestIndex < trailingIndex) {
            lowestIndex = trailingIndex;
            lowest = inLow[lowestIndex];
            i = lowestIndex;
            while (++i <= today) {
                tmp = inLow[i];
                if (tmp < lowest) {
                    lowestIndex = i;
                    lowest = tmp;
                }
            }
            diff = (highest - lowest) / (-100.0);
        } else if (tmp <= lowest) {
            lowestIndex = today;
            lowest = tmp;
            diff = (highest - lowest) / (-100.0);
        }

        tmp = inHigh[today];
        if (highestIndex < trailingIndex) {
            highestIndex = trailingIndex;
            highest = inHigh[highestIndex];
            i = highestIndex;
            while (++i <= today) {
                tmp = inHigh[i];
                if (tmp > highest) {
                    highestIndex = i;
                    highest = tmp;
                }
            }
            diff = (highest - lowest) / (-100.0);
        } else if (tmp >= highest) {
            highestIndex = today;
            highest = tmp;
            diff = (highest - lowest) / (-100.0);
        }

        if (diff != 0.0) {
            outReal[outIndex++] = (highest - inClose[today]) / diff;
        } else {
            outReal[outIndex++] = 0.0;
        }

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
function WillRLookback(optInTimePeriod:Int):Int {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }

    return (optInTimePeriod - 1);
}
