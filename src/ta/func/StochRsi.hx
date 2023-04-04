package ta.func;

import ta.Globals.MAType;
import ta.func.StochF.StochF;
import ta.func.StochF.StochFLookback;
import ta.func.Rsi.Rsi;
import ta.func.Rsi.RsiLookback;

@:keep
function StochRsi(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int, optInFastK_Period:Int, optInFastD_Period:Int,
        optInFastD_MAType:MAType) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outFastK:Array<Float> = [];
    var outFastD:Array<Float> = [];

    var tempRSIBuffer:Array<Float>;

    // var ret;

    var lookbackTotal:Int, lookbackSTOCHF:Int, tempArraySize:Int;
    var outBegIndex1:Int;
    var outBegIndex2:Int;
    var outNbElement1:Int;

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
    // optInFastK_Period = 5;
    if (optInFastK_Period < 1) {
        throw new TAException(BadParam);
    }
    // optInFastD_Period = 3;
    if (optInFastD_Period < 1) {
        throw new TAException(BadParam);
    }
    if (optInFastD_MAType == null) {
        optInFastD_MAType = MAType.Sma;
    }
    outBegIndex = 0;
    outNBElement = 0;

    lookbackSTOCHF = StochFLookback(optInFastK_Period, optInFastD_Period, optInFastD_MAType);
    lookbackTotal = RsiLookback(optInTimePeriod) + lookbackSTOCHF;

    if (startIndex < lookbackTotal) {
        startIndex = lookbackTotal;
    }

    if (startIndex > endIndex) {
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outFastK: outFastK,
            outFastD: outFastD
        };
    }

    outBegIndex = startIndex;

    tempArraySize = (endIndex - startIndex) + 1 + lookbackSTOCHF;

    // ARRAY_ALLOC(tempRSIBuffer, tempArraySize);

    var ret = Rsi(startIndex - lookbackSTOCHF, endIndex, inReal, optInTimePeriod);
    outBegIndex1 = ret.outBegIndex;
    outNbElement1 = ret.outNBElement;
    tempRSIBuffer = ret.outReal;

    // retCode = FUNCTION_CALL(RSI)(, VALUE_HANDLE_OUT(outBegIndex1), VALUE_HANDLE_OUT(outNbElement1), tempRSIBuffer);

    if (outNbElement1 == 0) {
        // ARRAY_FREE(tempRSIBuffer);
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outFastK: outFastK,
            outFastD: outFastD
        };
    }

    var ret = StochF(0, tempArraySize - 1, tempRSIBuffer, tempRSIBuffer, tempRSIBuffer, optInFastK_Period, optInFastD_Period, optInFastD_MAType);
    outBegIndex2 = ret.outBegIndex;
    outNBElement = ret.outNBElement;
    outFastK = ret.outFastK;
    outFastD = ret.outFastD;

    // retCode = FUNCTION_CALL_DOUBLE(STOCHF)(, VALUE_HANDLE_OUT(outBegIndex2), outNBElement, outFastK, outFastD);

    // ARRAY_FREE(tempRSIBuffer);

    if (outNBElement == 0) {
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outFastK: outFastK,
            outFastD: outFastD
        };
    }

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outFastK: outFastK,
        outFastD: outFastD
    };
}

@:keep
function StochRsiLookback(optInTimePeriod:Int, optInFastK_Period:Int, optInFastD_Period:Int, optInFastD_MAType:MAType) {
    var retValue;

    // DEFAULT & RANGE
    // optInFastK_Period = 5;
    if (optInFastK_Period < 1) {
        return -1;
    }
    // optInFastD_Period = 3;
    if (optInFastD_Period < 1) {
        return -1;
    }
    if (optInFastD_MAType == null) {
        optInFastD_MAType = MAType.Sma;
    }

    retValue = RsiLookback(optInTimePeriod) + StochFLookback(optInFastK_Period, optInFastD_Period, optInFastD_MAType);
    return retValue;
}
