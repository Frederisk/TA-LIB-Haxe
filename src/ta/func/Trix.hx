package ta.func;

import ta.func.Roc;
import ta.func.Ema.IntEma;
import ta.func.Utility.PerToK;
import ta.func.RocR.RocRLookback;
import ta.func.Ema.EmaLookback;

@:keep
function Trix(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var k:Float;
    var tempBuffer:Array<Float>;
    var nbElement:Int;
    var begIndex:Int;
    var totalLookback:Int;
    var emaLookback:Int, rocLookback:Int;
    var ret;
    var nbElementToOutput:Int;

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
    if (optInTimePeriod < 1) {
        throw new TAException(BadParam);
    }

    emaLookback = EmaLookback(optInTimePeriod);
    rocLookback = RocRLookback(1);
    totalLookback = (emaLookback * 3) + rocLookback;

    if (startIndex < totalLookback) {
        startIndex = totalLookback;
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

    outBegIndex = startIndex;

    nbElementToOutput = (endIndex - startIndex) + 1 + totalLookback;

    // ARRAY_ALLOC(tempBuffer, nbElementToOutput);
    // #if !defined
    // (_JAVA) if (!tempBuffer) {
    //     VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
    //     VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
    //     return ENUM_VALUE(RetCode, TA_ALLOC_ERR, AllocErr);
    // }
    // #endif

    k = PerToK(optInTimePeriod);
    ret = IntEma((startIndex - totalLookback), endIndex, inReal, optInTimePeriod, k);
    begIndex = ret.outBegIndex;
    nbElement = ret.outNBElement;
    tempBuffer = ret.outReal;
    // retCode = IntEma((startIndex - totalLookback), endIndex, inReal, optInTimePeriod, k, VALUE_HANDLE_OUT(begIndex), VALUE_HANDLE_OUT(nbElement),
    //     tempBuffer);

    if (nbElement == 0) {
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    // if ((retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success)) || (VALUE_HANDLE_GET(nbElement) == 0)) {
    //     VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
    //     VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
    //     ARRAY_FREE(tempBuffer);
    //     return retCode;
    // }

    nbElementToOutput--;

    nbElementToOutput -= emaLookback;

    ret = IntEma(0, nbElementToOutput, tempBuffer, optInTimePeriod, k);
    begIndex = ret.outBegIndex;
    nbElement = ret.outNBElement;
    tempBuffer = ret.outReal;
    // retCode = FUNCTION_CALL_DOUBLE(INT_EMA)(0, nbElementToOutput, tempBuffer, optInTimePeriod, k, VALUE_HANDLE_OUT(begIndex), VALUE_HANDLE_OUT(nbElement),
    //     tempBuffer);

    if (nbElement == 0) {
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    // if ((retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success)) || (VALUE_HANDLE_GET(nbElement) == 0)) {
    //     VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
    //     VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
    //     ARRAY_FREE(tempBuffer);
    //     return retCode;
    // }

    nbElementToOutput -= emaLookback;

    ret = IntEma(0, nbElementToOutput, tempBuffer, optInTimePeriod, k);
    begIndex = ret.outBegIndex;
    nbElement = ret.outNBElement;
    tempBuffer = ret.outReal;

    // retCode = FUNCTION_CALL_DOUBLE(INT_EMA)(0, nbElementToOutput, tempBuffer, optInTimePeriod, k, VALUE_HANDLE_OUT(begIndex), VALUE_HANDLE_OUT(nbElement),
    //     tempBuffer);

    if (nbElement == 0) {
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    // if ((retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success)) || (VALUE_HANDLE_GET(nbElement) == 0)) {
    //     VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
    //     VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
    //     ARRAY_FREE(tempBuffer);
    //     return retCode;
    // }

    /* Calculate the 1-day Rate-Of-Change */
    nbElementToOutput -= emaLookback;

    ret = Roc(0, nbElementToOutput, tempBuffer, 1);
    begIndex = ret.outBegIndex;
    outNBElement = ret.outNBElement;
    outReal = ret.outReal;
    // retCode = FUNCTION_CALL_DOUBLE(ROC)(0, nbElementToOutput, tempBuffer, 1, VALUE_HANDLE_OUT(begIndex), outNBElement, outReal);

    // ARRAY_FREE(tempBuffer);

    if (nbElement == 0) {
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    // if ((retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success)) || ((int) VALUE_HANDLE_DEREF(outNBElement) == 0)) {
    //     VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
    //     VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
    //     return retCode;
    // }

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function TrixLookback(optInTimePeriod:Int) {
    var emaLookback:Int;

    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 1) {
        return -1;
    }

    emaLookback = EmaLookback(optInTimePeriod);
    return (emaLookback * 3) + RocRLookback(1);
}
