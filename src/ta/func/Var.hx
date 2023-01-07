package ta.func;

@:keep
function Var(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int, optInNbDev:Float) {
    // var outBegIndex:Int;
    // var outNBElement:Int;
    // var outReal:Array<Float> = [];

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
    //     optInTimePeriod = 5;
    // } else
    // INTEGER_DEFAULT
    // if(optInNbDev == null || ){
    //     optInNbDev = 1.0;
    // } else
    if (optInTimePeriod < 1) {
        throw new TAException(BadParam);
    }

    return IntVar(startIndex, endIndex, inReal, optInTimePeriod);
}

function IntVar(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var tempReal:Float,
        periodTotal1:Float,
        periodTotal2:Float,
        meanValue1:Float,
        meanValue2:Float;

    var i:Int, outIndex:Int, trailingIndex:Int, nbInitialElementNeeded:Int;

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

    periodTotal1 = 0;
    periodTotal2 = 0;
    trailingIndex = startIndex - nbInitialElementNeeded;

    i = trailingIndex;
    if (optInTimePeriod > 1) {
        while (i < startIndex) {
            tempReal = inReal[i++];
            periodTotal1 += tempReal;
            tempReal *= tempReal;
            periodTotal2 += tempReal;
        }
    }

    outIndex = 0;
    do {
        tempReal = inReal[i++];

        periodTotal1 += tempReal;
        tempReal *= tempReal;
        periodTotal2 += tempReal;

        meanValue1 = periodTotal1 / optInTimePeriod;
        meanValue2 = periodTotal2 / optInTimePeriod;

        tempReal = inReal[trailingIndex++];
        periodTotal1 -= tempReal;
        tempReal *= tempReal;
        periodTotal2 -= tempReal;

        outReal[outIndex++] = meanValue2 - meanValue1 * meanValue1;
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
function VarLookback(optInTimePeriod:Int, optInNbDev:Float) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 5;
    // } else
    // INTEGER_DEFAULT
    // if(optInNbDev == null || ){
    //     optInNbDev = 1.0;
    // } else
    (optInNbDev);
    if (optInTimePeriod < 1) {
        return -1;
    }
    return (optInTimePeriod - 1);
}
