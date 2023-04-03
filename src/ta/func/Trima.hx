package ta.func;

@:keep
function Trima(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var lookbackTotal:Int;

    var numerator:Float;
    var numeratorSub:Float;
    var numeratorAdd:Float;

    var i:Int, outIndex:Int, todayIndex:Int, trailingIndex:Int, middleIndex:Int;
    var factor:Float, tempReal:Float;

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

    outIndex = 0;

    if ((optInTimePeriod % 2) == 1) {
        i = (optInTimePeriod >> 1);
        factor = (i + 1) * (i + 1);
        factor = 1.0 / factor;

        trailingIndex = startIndex - lookbackTotal;
        middleIndex = trailingIndex + i;
        todayIndex = middleIndex + i;
        numerator = 0.0;
        numeratorSub = 0.0;

        i = middleIndex;
        while (i >= trailingIndex) {

            tempReal = inReal[i];
            numeratorSub += tempReal;
            numerator += numeratorSub;

            i--;
        }
        numeratorAdd = 0.0;
        middleIndex++;

        i = middleIndex;
        while (i <= todayIndex) {

            tempReal = inReal[i];
            numeratorAdd += tempReal;
            numerator += numeratorAdd;

            i++;
        }

        outIndex = 0;
        tempReal = inReal[trailingIndex++];
        outReal[outIndex++] = numerator * factor;
        todayIndex++;

        while (todayIndex <= endIndex) {
            numerator -= numeratorSub;
            numeratorSub -= tempReal;
            tempReal = inReal[middleIndex++];
            numeratorSub += tempReal;

            numerator += numeratorAdd;
            numeratorAdd -= tempReal;
            tempReal = inReal[todayIndex++];
            numeratorAdd += tempReal;

            numerator += tempReal;

            tempReal = inReal[trailingIndex++];
            outReal[outIndex++] = numerator * factor;
        }
    } else {
        i = (optInTimePeriod >> 1);
        factor = i * (i + 1);
        factor = 1.0 / factor;

        trailingIndex = startIndex - lookbackTotal;
        middleIndex = trailingIndex + i - 1;
        todayIndex = middleIndex + i;
        numerator = 0.0;

        numeratorSub = 0.0;

        i = middleIndex;
        while (i >= trailingIndex) {

            tempReal = inReal[i];
            numeratorSub += tempReal;
            numerator += numeratorSub;

            i--;
        }
        numeratorAdd = 0.0;
        middleIndex++;

        i = middleIndex;
        while (i <= todayIndex) {
            tempReal = inReal[i];
            numeratorAdd += tempReal;
            numerator += numeratorAdd;

            i++;
        }

        outIndex = 0;
        tempReal = inReal[trailingIndex++];
        outReal[outIndex++] = numerator * factor;
        todayIndex++;

        while (todayIndex <= endIndex) {
            numerator -= numeratorSub;
            numeratorSub -= tempReal;
            tempReal = inReal[middleIndex++];
            numeratorSub += tempReal;

            numeratorAdd -= tempReal;
            numerator += numeratorAdd;
            tempReal = inReal[todayIndex++];
            numeratorAdd += tempReal;

            numerator += tempReal;

            tempReal = inReal[trailingIndex++];
            outReal[outIndex++] = numerator * factor;
        }
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
function TrimaLookback(optInTimePeriod:Int) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }

    return (optInTimePeriod - 1);
}
