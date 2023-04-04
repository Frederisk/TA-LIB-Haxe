package ta.func;

import ta.func.Ma.Ma;
import ta.func.Ma.MaLookback;
import ta.Globals.MAType;

@:keep
function MacdExt(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInFastPeriod:Int, optInFastMAType:MAType, optInSlowPeriod:Int, optInSlowMAType:MAType,
        optInSignalPeriod:Int, optInSignalMAType:MAType) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outMACD:Array<Float> = [];
    var outMACDSignal:Array<Float> = [];
    var outMACDHist:Array<Float> = [];

    var slowMABuffer:Array<Float>;
    var fastMABuffer:Array<Float>;

    var ret;

    var tempInteger:Int;

    var outBegIndex1:Int;
    var outNbElement1:Int;
    var outBegIndex2:Int;
    var outNbElement2:Int;

    var lookbackTotal:Int, lookbackSignal:Int, lookbackLargest:Int;
    var i:Int;

    var tempMAType:MAType;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inReal == null) {
        throw new TAException(BadParam);
    }
    // DEFAULT & RANGE
    // optInFastPeriod = 12;
    if (optInFastPeriod < 2) {
        throw new TAException(BadParam);
    }
    if (optInFastMAType == null) {
        optInFastMAType = MAType.Sma;
    }
    // optInSlowPeriod = 26;
    if (optInSlowPeriod < 2) {
        throw new TAException(BadParam);
    }
    if (optInSlowMAType == null) {
        optInSlowMAType = MAType.Sma;
    }
    // optInSignalPeriod = 9;
    if (optInSignalPeriod < 1) {
        throw new TAException(BadParam);
    }
    if (optInSignalMAType == null) {
        optInSignalMAType = MAType.Sma;
    }

    if (optInSlowPeriod < optInFastPeriod) {
        tempInteger = optInSlowPeriod;
        optInSlowPeriod = optInFastPeriod;
        optInFastPeriod = tempInteger;
        tempMAType = optInSlowMAType;
        optInSlowMAType = optInFastMAType;
        optInFastMAType = tempMAType;
    }

    lookbackLargest = MaLookback(optInFastPeriod, optInFastMAType);
    tempInteger = MaLookback(optInSlowPeriod, optInSlowMAType);
    if (tempInteger > lookbackLargest) {
        lookbackLargest = tempInteger;
    }

    lookbackSignal = MaLookback(optInSignalPeriod, optInSignalMAType);
    lookbackTotal = lookbackSignal + lookbackLargest;

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
    // ARRAY_ALLOC(fastMABuffer, tempInteger);
    // if (!fastMABuffer) {
    //         VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
    //         VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
    //         return ENUM_VALUE(RetCode, TA_ALLOC_ERR, AllocErr);
    //     }
    // ARRAY_ALLOC(slowMABuffer, tempInteger);

    // if (!slowMABuffer) {
    //     VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
    //     VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
    //     // ARRAY_FREE(fastMABuffer);
    //     return ENUM_VALUE(RetCode, TA_ALLOC_ERR, AllocErr);
    // }

    tempInteger = startIndex - lookbackSignal;

    ret = Ma(tempInteger, endIndex, inReal, optInSlowPeriod, optInSlowMAType);
    outBegIndex1 = ret.outBegIndex;
    outNbElement1 = ret.outNBElement;
    slowMABuffer = ret.outReal;

    // retCode = FUNCTION_CALL(MA)( VALUE_HANDLE_OUT(outBegIndex1),
    //     VALUE_HANDLE_OUT(outNbElement1), slowMABuffer);

    // if (retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success)) {
    //     VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
    //     VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
    //     ARRAY_FREE(fastMABuffer);
    //     ARRAY_FREE(slowMABuffer);
    //     return retCode;
    // }

    ret = Ma(tempInteger, endIndex, inReal, optInFastPeriod, optInFastMAType);
    outBegIndex2 = ret.outBegIndex;
    outNbElement2 = ret.outNBElement;
    fastMABuffer = ret.outReal;
    // retCode = FUNCTION_CALL(MA)(, VALUE_HANDLE_OUT(outBegIndex2),
    //     VALUE_HANDLE_OUT(outNbElement2), fastMABuffer);

    // if (retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success)) {
    //     VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
    //     VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
    //     ARRAY_FREE(fastMABuffer);
    //     ARRAY_FREE(slowMABuffer);
    //     return retCode;
    // }

    if ((outBegIndex1 != tempInteger)
        || (outBegIndex2 != tempInteger)
        || (outNbElement1 != outNbElement2)
        || (outNbElement1 != (endIndex - startIndex) + 1 + lookbackSignal)) {
        outBegIndex = 0;
        outNBElement = 0;
        // ARRAY_FREE(fastMABuffer);
        // ARRAY_FREE(slowMABuffer);
        throw new TAException(InternalError, "Id:119");
        // return TA_INTERNAL_ERROR(119);
    }

    i = 0;
    while (i < outNbElement1) {
        fastMABuffer[i] = fastMABuffer[i] - slowMABuffer[i];

        i++;
    }

    // ARRAY_MEMMOVE(outMACD, 0, fastMABuffer, lookbackSignal, (endIndex - startIndex) + 1);
    // memmove(&outMACD[0], &fastMABuffer[lookbackSignal], ((endIdx - startIdx) + 1) * sizeof(double))
    outMACD = fastMABuffer.slice(lookbackSignal, lookbackSignal + (endIndex - startIndex) + 1);

    ret = Ma(0, outNbElement1 - 1, fastMABuffer, optInSignalPeriod, optInSignalMAType);
    outBegIndex2 = ret.outBegIndex;
    outNbElement2 = ret.outNBElement;
    outMACDSignal = ret.outReal;
    // retCode = FUNCTION_CALL_DOUBLE(MA)(,
    // VALUE_HANDLE_OUT(outBegIndex2), VALUE_HANDLE_OUT(outNbElement2), outMACDSignal);

    // ARRAY_FREE(fastMABuffer);
    // ARRAY_FREE(slowMABuffer);

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
function MacdExtLookback(optInFastPeriod:Int, optInFastMAType:MAType, optInSlowPeriod:Int, optInSlowMAType:MAType, optInSignalPeriod:Int,
        optInSignalMAType:MAType) {
    var tempInteger:Int, lookbackLargest:Int;
    // DEFAULT & RANGE
    // optInFastPeriod = 12;
    if (optInFastPeriod < 2) {
        return -1;
    }
    if (optInFastMAType == null) {
        optInFastMAType = MAType.Sma;
    }
    // optInSlowPeriod = 26;
    if (optInSlowPeriod < 2) {
        return -1;
    }
    if (optInSlowMAType == null) {
        optInSlowMAType = MAType.Sma;
    }
    // optInSignalPeriod = 9;
    if (optInSignalPeriod < 1) {
        return -1;
    }
    if (optInSignalMAType == null) {
        optInSignalMAType = MAType.Sma;
    }

    lookbackLargest = MaLookback(optInFastPeriod, optInFastMAType);
    tempInteger = MaLookback(optInSlowPeriod, optInSlowMAType);

    if (tempInteger > lookbackLargest) {
        lookbackLargest = tempInteger;
    }

    return lookbackLargest + MaLookback(optInSignalPeriod, optInSignalMAType);
}
