package ta.func;

import ta.func.Ema.IntEma;
import ta.func.Utility.PerToK;
import ta.func.Ema.EmaLookback;

@:keep
function Macd(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInFastPeriod:Int, optInSlowPeriod:Int, optInSignalPeriod:Int) {
    // var outBegIndex:Int;
    // var outNBElement:Int;
    // var outMACD:Array<Float> = [];
    // var outMACDSignal:Array<Float> = [];
    // var outMACDHist:Array<Float> = [];

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
    // if(optInFastPeriod == null || ){
    //     optInFastPeriod = 12;
    // } else
    if (optInFastPeriod < 2) {
        throw new TAException(BadParam);
    }
    // INTEGER_DEFAULT
    // if(optInSlowPeriod == null || ){
    //     optInSlowPeriod = 26;
    // } else
    if (optInSlowPeriod < 2) {
        throw new TAException(BadParam);
    }
    // INTEGER_DEFAULT
    // if(optInSignalPeriod == null || ){
    //     optInSignalPeriod = 9;
    // } else
    if (optInSignalPeriod < 1) {
        throw new TAException(BadParam);
    }

    return IntMacd(startIndex, endIndex, inReal, optInFastPeriod, optInSlowPeriod, optInSignalPeriod);
}

@:keep
function IntMacd(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInFastPeriod:Int, optInSlowPeriod:Int, optInSignalPeriod_2:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outMACD:Array<Float> = [];
    var outMACDSignal:Array<Float> = [];
    var outMACDHist:Array<Float> = [];

    var slowEMABuffer:Array<Float>; // No initialization required
    var fastEMABuffer:Array<Float>; // No initialization required
    var k1:Float, k2:Float;
    var ret;
    var tempInteger:Int;
    var outBegIndex1:Int;
    var outNbElement1:Int;
    var outBegIndex2:Int;
    var outNbElement2:Int;
    var lookbackTotal:Int, lookbackSignal:Int;
    var i:Int;

    if (optInSlowPeriod < optInFastPeriod) {
        tempInteger = optInSlowPeriod;
        optInSlowPeriod = optInFastPeriod;
        optInFastPeriod = tempInteger;
    }

    if (optInSlowPeriod != 0) {
        k1 = PerToK(optInSlowPeriod);
    } else {
        optInSlowPeriod = 26;
        k1 = 0.075;
    }

    if (optInFastPeriod != 0) {
        k2 = PerToK(optInFastPeriod);
    } else {
        optInFastPeriod = 12;
        k2 = 0.15;
    }

    lookbackSignal = EmaLookback(optInSignalPeriod_2);
    lookbackTotal = lookbackSignal;
    lookbackTotal += EmaLookback(optInSlowPeriod);

    if (startIndex < lookbackTotal) {
        startIndex = lookbackTotal;
    }

    if (startIndex > endIndex) {
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outMACD: outMACD,
            outMACDSignal: outMACDSignal,
            outMACDHist: outMACDHist
        };
    }

    tempInteger = (endIndex - startIndex) + 1 + lookbackSignal;
    // ARRAY_ALLOC(fastEMABuffer, tempInteger);
    // fastEMABuffer = []; // Size: tempInteger
    // if (!fastEMABuffer) {
    //     outBegIndex = 0;
    //     outNBElement = 0;
    //     return ENUM_VALUE(RetCode, TA_ALLOC_ERR, AllocErr);
    // }

    // ARRAY_ALLOC(slowEMABuffer, tempInteger);
    // slowEMABuffer = []; // Size: tempInteger
    // if (!slowEMABuffer) {
    //     outBegIndex = 0;
    //     outNBElement = 0;
    //     ARRAY_FREE(fastEMABuffer);
    //     return ENUM_VALUE(RetCode, TA_ALLOC_ERR, AllocErr);
    // }

    tempInteger = startIndex - lookbackSignal;

    // retCode = FUNCTION_CALL(INT_EMA)( VALUE_HANDLE_OUT(outBegIndex1), VALUE_HANDLE_OUT(outNbElement1), slowEMABuffer);
    ret = IntEma(tempInteger, endIndex, inReal, optInSlowPeriod, k1);
    outBegIndex1 = ret.outBegIndex;
    outNbElement1 = ret.outNBElement;
    slowEMABuffer = ret.outReal;

    //    if( retCode != ENUM_VALUE(RetCode,TA_SUCCESS,Success) )
    //    {
    //       VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
    //       VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
    //       ARRAY_FREE( fastEMABuffer );
    //       ARRAY_FREE( slowEMABuffer );
    //       return retCode;
    //    }

    // retCode = FUNCTION_CALL(INT_EMA)( VALUE_HANDLE_OUT(outBegIndex2), VALUE_HANDLE_OUT(outNbElement2), fastEMABuffer);
    ret = IntEma(tempInteger, endIndex, inReal, optInFastPeriod, k2);
    outBegIndex2 = ret.outBegIndex;
    outNbElement2 = ret.outNBElement;
    fastEMABuffer = ret.outReal;

    //    if( retCode != ENUM_VALUE(RetCode,TA_SUCCESS,Success) )
    //    {
    //         outBegIndex = 0;
    //         outNBElement = 0;
    //       ARRAY_FREE( fastEMABuffer );
    //       ARRAY_FREE( slowEMABuffer );
    //       return retCode;
    //    }

    if ((outBegIndex1 != tempInteger)
        || (outBegIndex2 != tempInteger)
        || (outNbElement1 != outNbElement2)
        || (outNbElement1 != (endIndex - startIndex) + 1 + lookbackSignal)) {
        outBegIndex = 0;
        outNBElement = 0;
        // ARRAY_FREE(fastEMABuffer);
        // ARRAY_FREE(slowEMABuffer);
        // return TA_INTERNAL_ERROR(119);
        throw new TAException(InternalError, "ID:119");
    }

    i = 0;
    while (i < outNbElement1) {
        fastEMABuffer[i] = fastEMABuffer[i] - slowEMABuffer[i];

        i++;
    }

    // ARRAY_MEMMOVE(outMACD, 0, fastEMABuffer, lookbackSignal, (endIndex - startIndex) + 1);
    // memmove(&outMACD[0], &fastEMABuffer[lookbackSignal], ((endIndex - startIndex) + 1) * sizeof(double))
    outMACD = fastEMABuffer.slice(lookbackSignal, lookbackSignal + ((endIndex - startIndex) + 1));

    // retCode = FUNCTION_CALL_DOUBLE(INT_EMA)(0, VALUE_HANDLE_GET(outNbElement1) - 1, fastEMABuffer, optInSignalPeriod_2, PER_TO_K(optInSignalPeriod_2), VALUE_HANDLE_OUT(outBegIndex2), VALUE_HANDLE_OUT(outNbElement2), outMACDSignal);
    ret = IntEma(0, outNbElement1 - 1, fastEMABuffer, optInSignalPeriod_2, PerToK(optInSignalPeriod_2));
    outBegIndex2 = ret.outBegIndex;
    outNbElement2 = ret.outNBElement;
    outMACDSignal = ret.outReal;

    // ARRAY_FREE(fastEMABuffer);
    // ARRAY_FREE(slowEMABuffer);

    // if (retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success)) {
    //     VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
    //     VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
    //     return retCode;
    // }

    i = 0;
    while (i < outNbElement2) {
        outMACDHist[i] = outMACD[i] - outMACDSignal[i];

        i++;
    }

    outBegIndex = startIndex;
    outNBElement = outNbElement2;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outMACD: outMACD,
        outMACDSignal: outMACDSignal,
        outMACDHist: outMACDHist
    };
}

@:keep
function MacdLookback(optInFastPeriod:Int, optInSlowPeriod:Int, optInSignalPeriod:Int) {
    var tempInteger:Int;

    // INTEGER_DEFAULT
    // if(optInFastPeriod == null || ){
    //     optInFastPeriod = 12;
    // } else
    if (optInFastPeriod < 2) {
        return -1;
    }
    // INTEGER_DEFAULT
    // if(optInSlowPeriod == null || ){
    //     optInSlowPeriod = 26;
    // } else
    if (optInSlowPeriod < 2) {
        return -1;
    }
    // INTEGER_DEFAULT
    // if(optInSignalPeriod == null || ){
    //     optInSignalPeriod = 9;
    // } else
    if (optInSignalPeriod < 1) {
        return -1;
    }

    if (optInSlowPeriod < optInFastPeriod) {
        tempInteger = optInSlowPeriod;
        optInSlowPeriod = optInFastPeriod;
        optInFastPeriod = tempInteger;
    }

    return (EmaLookback(optInSlowPeriod) + EmaLookback(optInSignalPeriod));
}
