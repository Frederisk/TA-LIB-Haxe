package ta.func;

@:keep
function MinMax(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outMin:Array<Float> = [];
    var outMax:Array<Float> = [];

    var highest:Float, lowest:Float, tmpHigh:Float, tmpLow:Float;
    var outIndex:Int, nbInitialElementNeeded:Int;
    var trailingIndex:Int, today:Int, i:Int, highestIndex:Int, lowestIndex:Int;

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
            outMin: outMin,
            outMax: outMax
        };
    }

    outIndex = 0;
    today = startIndex;
    trailingIndex = startIndex - nbInitialElementNeeded;
    highestIndex = -1;
    highest = 0.0;
    lowestIndex = -1;
    lowest = 0.0;

    while (today <= endIndex) {
        tmpLow = tmpHigh = inReal[today];

        if (highestIndex < trailingIndex) {
            highestIndex = trailingIndex;
            highest = inReal[highestIndex];
            i = highestIndex;
            while (++i <= today) {
                tmpHigh = inReal[i];
                if (tmpHigh > highest) {
                    highestIndex = i;
                    highest = tmpHigh;
                }
            }
        } else if (tmpHigh >= highest) {
            highestIndex = today;
            highest = tmpHigh;
        }

        if (lowestIndex < trailingIndex) {
            lowestIndex = trailingIndex;
            lowest = inReal[lowestIndex];
            i = lowestIndex;
            while (++i <= today) {
                tmpLow = inReal[i];
                if (tmpLow < lowest) {
                    lowestIndex = i;
                    lowest = tmpLow;
                }
            }
        } else if (tmpLow <= lowest) {
            lowestIndex = today;
            lowest = tmpLow;
        }

        outMax[outIndex] = highest;
        outMin[outIndex] = lowest;
        outIndex++;
        trailingIndex++;
        today++;
    }

    outBegIndex = startIndex;
    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outMin: outMin,
        outMax: outMax
    };
}

@:keep
function MinMaxLookback(optInTimePeriod:Int):Int {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }
    return (optInTimePeriod - 1);
}
