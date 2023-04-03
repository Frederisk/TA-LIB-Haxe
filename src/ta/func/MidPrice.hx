package ta.func;

@:keep
function MidPrice(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var lowest:Float, highest:Float, tmp:Float;
    var outIndex:Int, nbInitialElementNeeded:Int;
    var trailingIndex:Int, today:Int, i:Int;

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
    if (optInTimePeriod < 1) {
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

    outIndex = 0;
    today = startIndex;
    trailingIndex = startIndex - nbInitialElementNeeded;

    while (today <= endIndex) {
        lowest = inLow[trailingIndex];
        highest = inHigh[trailingIndex];
        trailingIndex++;

        i = trailingIndex;
        while (i <= today) {

            tmp = inLow[i];
            if (tmp < lowest) {
                lowest = tmp;
            }
            tmp = inHigh[i];
            if (tmp > highest) {
                highest = tmp;
            }

            i++;
        }

        outReal[outIndex++] = (highest + lowest) / 2.0;
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
function MidPriceLookback(optInTimePeriod:Int) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }

    return (optInTimePeriod - 1);
}
