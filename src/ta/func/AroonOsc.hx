package ta.func;

@:keep
function AroonOsc(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var lowest:Float, highest:Float, tmp:Float, factor:Float, aroon:Float;
    var outIndex:Int;
    var trailingIndex:Int, lowestIndex:Int, highestIndex:Int, today:Int, i:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inHigh == null || inLow == null) {
        throw new TAException(BadParam);
    }
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
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

    outIndex = 0;
    today = startIndex;
    trailingIndex = startIndex - optInTimePeriod;
    lowestIndex = -1;
    highestIndex = -1;
    lowest = 0.0;
    highest = 0.0;
    factor = 100.0 / optInTimePeriod;

    while (today <= endIndex) {
        tmp = inLow[today];
        if (lowestIndex < trailingIndex) {
            lowestIndex = trailingIndex;
            lowest = inLow[lowestIndex];
            i = lowestIndex;
            while (++i <= today) {
                tmp = inLow[i];
                if (tmp <= lowest) {
                    lowestIndex = i;
                    lowest = tmp;
                }
            }
        } else if (tmp <= lowest) {
            lowestIndex = today;
            lowest = tmp;
        }

        tmp = inHigh[today];
        if (highestIndex < trailingIndex) {
            highestIndex = trailingIndex;
            highest = inHigh[highestIndex];
            i = highestIndex;
            while (++i <= today) {
                tmp = inHigh[i];
                if (tmp >= highest) {
                    highestIndex = i;
                    highest = tmp;
                }
            }
        } else if (tmp >= highest) {
            highestIndex = today;
            highest = tmp;
        }

        aroon = factor * (highestIndex - lowestIndex);

        outReal[outIndex] = aroon;

        outIndex++;
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
function AroonOscLookback(optInTimePeriod:Int):Int {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }

    return optInTimePeriod;
}
