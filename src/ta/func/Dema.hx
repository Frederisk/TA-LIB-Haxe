package ta.func;

import ta.func.Ema.IntEma;
import ta.func.Utility.PerToK;
import ta.func.Ema.EmaLookback;

@:keep
function Dema(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var firstEMA:Array<Float>;
    var secondEMA:Array<Float>;
    var k:Float;
    var firstEMABegIndex:Int;
    var firstEMANbElement:Int;
    var secondEMABegIndex:Int;
    var secondEMANbElement:Int;
    var tempInt:Int,
        outIndex:Int,
        firstEMAIndex:Int,
        lookbackTotal:Int,
        lookbackEMA:Int;
    var ret;

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

    outBegIndex = 0;
    outNBElement = 0;

    lookbackEMA = EmaLookback(optInTimePeriod);
    lookbackTotal = lookbackEMA * 2;

    if (startIndex < lookbackTotal) {
        startIndex = lookbackTotal;
    }

    if (startIndex > endIndex) {
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    // Alloc firstEMA
    // if (inReal == outReal) {
    //     firstEMA = outReal;
    // }
    // else {
    //     tempInt = lookbackTotal + (endIndex - startIndex) + 1;
    //     ARRAY_ALLOC(firstEMA, tempInt);
    //     // if (!firstEMA) {
    //     //     // return ENUM_VALUE(RetCode, TA_ALLOC_ERR, AllocErr);
    //     // }
    // }

    k = PerToK(optInTimePeriod);
    ret = IntEma((startIndex - lookbackEMA), endIndex, inReal, optInTimePeriod, k);
    firstEMABegIndex = ret.outBegIndex;
    firstEMANbElement = ret.outNBElement;
    firstEMA = ret.outReal;

    if (firstEMANbElement == 0) {
        // ARRAY_FREE_COND(firstEMA != outReal, firstEMA);
        return ret;
    }

    // Alloc secondEMA
    // ARRAY_ALLOC(secondEMA, VALUE_HANDLE_GET(firstEMANbElement));

    // if (!secondEMA) {
    //     ARRAY_FREE_COND(firstEMA != outReal, firstEMA);
    //     return ENUM_VALUE(RetCode, TA_ALLOC_ERR, AllocErr);
    // }

    ret = IntEma(0, (firstEMANbElement - 1), firstEMA, optInTimePeriod, k);
    secondEMABegIndex = ret.outBegIndex;
    secondEMANbElement = ret.outNBElement;
    secondEMA = ret.outReal;

    if (secondEMANbElement == 0) {
        // ARRAY_FREE_COND(firstEMA != outReal, firstEMA);
        // ARRAY_FREE(secondEMA);
        return ret;
    }

    firstEMAIndex = secondEMABegIndex;
    outIndex = 0;
    while (outIndex < secondEMANbElement) {
        outReal[outIndex] = (2.0 * firstEMA[firstEMAIndex++]) - secondEMA[outIndex];
        outIndex++;
    }

    // ARRAY_FREE_COND(firstEMA != outReal, firstEMA);
    // ARRAY_FREE(secondEMA);

    outBegIndex = firstEMABegIndex + secondEMABegIndex;
    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function DemaLookback(optInTimePeriod:Int):Int {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }
    return (EmaLookback(optInTimePeriod) * 2);
}
