package ta.func;

import ta.func.Ema.IntEma;
import ta.func.Utility.PerToK;
import ta.func.Ema.EmaLookback;

@:keep
function Tema(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
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
    var thirdEMABegIndex:Int;
    var thirdEMANbElement:Int;

    var tempInt:Int, outIndex:Int, lookbackTotal:Int, lookbackEMA:Int;
    var firstEMAIndex:Int, secondEMAIndex:Int;

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

    outNBElement = 0;
    outBegIndex = 0;

    lookbackEMA = EmaLookback(optInTimePeriod);
    lookbackTotal = lookbackEMA * 3;

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

    tempInt = lookbackTotal + (endIndex - startIndex) + 1;
    // ARRAY_ALLOC(firstEMA, tempInt);
    //  if (!firstEMA)
    //         return ENUM_VALUE(RetCode, TA_ALLOC_ERR, AllocErr);

    k = PerToK(optInTimePeriod);
    ret = IntEma(startIndex - (lookbackEMA * 2), endIndex, inReal, optInTimePeriod, k);
    firstEMABegIndex = ret.outBegIndex;
    firstEMANbElement = ret.outNBElement;
    firstEMA = ret.outReal;
    // retCode = FUNCTION_CALL(INT_EMA)(, VALUE_HANDLE_OUT(firstEMABegIndex),
    //     VALUE_HANDLE_OUT(firstEMANbElement), firstEMA);

    if (firstEMANbElement == 0) {
        // ARRAY_FREE(firstEMA);
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    // ARRAY_ALLOC(secondEMA, VALUE_HANDLE_GET(firstEMANbElement));
    //  if (!secondEMA) {
    //         ARRAY_FREE(firstEMA);
    //         return ENUM_VALUE(RetCode, TA_ALLOC_ERR, AllocErr);
    //     }
    ret = IntEma(0, firstEMANbElement - 1, firstEMA, optInTimePeriod, k);
    secondEMABegIndex = ret.outBegIndex;
    secondEMANbElement = ret.outNBElement;
    secondEMA = ret.outReal;
    // retCode = FUNCTION_CALL_DOUBLE(INT_EMA)(0, VALUE_HANDLE_GET(firstEMANbElement) - 1, firstEMA, optInTimePeriod, k, VALUE_HANDLE_OUT(secondEMABegIndex),VALUE_HANDLE_OUT(secondEMANbElement), secondEMA);

    if (secondEMANbElement == 0) {
        // ARRAY_FREE(firstEMA);
        // ARRAY_FREE(secondEMA);
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    ret = IntEma(0, secondEMANbElement - 1, secondEMA, optInTimePeriod, k);
    thirdEMABegIndex = ret.outBegIndex;
    thirdEMANbElement = ret.outNBElement;
    outReal = ret.outReal;
    // retCode = FUNCTION_CALL_DOUBLE(INT_EMA)(0, VALUE_HANDLE_GET(secondEMANbElement) - 1, secondEMA, optInTimePeriod, k, VALUE_HANDLE_OUT(thirdEMABegIndex),
    //     VALUE_HANDLE_OUT(thirdEMANbElement), outReal);

    if (thirdEMANbElement == 0) {
        // ARRAY_FREE(firstEMA);
        // ARRAY_FREE(secondEMA);
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    firstEMAIndex = thirdEMABegIndex + secondEMABegIndex;
    secondEMAIndex = thirdEMABegIndex;
    outBegIndex = firstEMAIndex + firstEMABegIndex;

    outIndex = 0;
    while (outIndex < thirdEMANbElement) {
        outReal[outIndex] += (3.0 * firstEMA[firstEMAIndex++]) - (3.0 * secondEMA[secondEMAIndex++]);
        outIndex++;
    }

    // ARRAY_FREE(firstEMA);
    // ARRAY_FREE(secondEMA);

    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function TemaLookback(optInTimePeriod:Int):Int {
    var retValue:Int;

    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }

    retValue = EmaLookback(optInTimePeriod);
    return (retValue * 3);
}
