package ta.func;

import ta.func.Utility.TAIntMax;
import ta.func.Utility.IsZero;
import ta.Globals.MAType;
import ta.func.Ma.Ma;
import ta.func.Ma.MaLookback;

@:keep
function Apo(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInFastPeriod:Int, optInSlowPeriod:Int, optInMAType:MAType) {
    // var outBegIndex:Int;
    // var outNBElement:Int;
    // var outReal:Array<Float> = [];

    // var tempBuffe:Array<Float>;
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
    if (optInMAType == null) {
        optInMAType = MAType.Sma;
    }

    //        ARRAY_ALLOC(tempBuffer, (endIndex-startIndex+1) );
    //    #if !defined(_JAVA)
    //       if( !tempBuffer )
    //          return ENUM_VALUE(RetCode,TA_ALLOC_ERR,AllocErr);
    //    #endif

    ret = IntPo(startIndex, endIndex, inReal, optInFastPeriod, optInSlowPeriod, optInMAType, 0);

    return ret;
}

@:keep
function ApoLookback(optInFastPeriod:Int, optInSlowPeriod:Int, optInMAType:MAType) {
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
    if (optInMAType == null) {
        optInMAType = MAType.Sma;
    }

    return MaLookback(TAIntMax(optInSlowPeriod, optInFastPeriod), optInMAType);
}

@:keep
function IntPo(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInFastPeriod:Int, optInSlowPeriod:Int, optInMethod_2:MAType, doPercentageOutput:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];
    var tempBuffer:Array<Float>; // Temp

    var ret;
    var tempReal:Float;
    var tempInteger:Int;
    var outBegIndex1:Int;
    var outNbElement1:Int;
    var outBegIndex2:Int;
    var outNbElement2:Int;

    var i:Int, j:Int;

    if (optInSlowPeriod < optInFastPeriod) {
        tempInteger = optInSlowPeriod;
        optInSlowPeriod = optInFastPeriod;
        optInFastPeriod = tempInteger;
    }

    ret = Ma(startIndex, endIndex, inReal, optInFastPeriod, optInMethod_2);
    outBegIndex2 = ret.outBegIndex;
    outNbElement2 = ret.outNBElement;
    tempBuffer = ret.outReal;

    // retCode = FUNCTION_CALL(MA)(, VALUE_HANDLE_OUT(outBegIndex2), VALUE_HANDLE_OUT(outNbElement2),
    // tempBuffer);

    // if (retCode == ENUM_VALUE(RetCode, TA_SUCCESS, Success)) {
    ret = Ma(startIndex, endIndex, inReal, optInSlowPeriod, optInMethod_2);
    outBegIndex1 = ret.outBegIndex;
    outNbElement1 = ret.outNBElement;
    outReal = ret.outReal;
    // retCode = FUNCTION_CALL(MA)(, VALUE_HANDLE_OUT(outBegIndex1), VALUE_HANDLE_OUT(outNbElement1), outReal);

    // if (retCode == ENUM_VALUE(RetCode, TA_SUCCESS, Success)) {
    tempInteger = outBegIndex1 - outBegIndex2;
    if (doPercentageOutput != 0) {
        i = 0;
        j = tempInteger;
        while (i < outNbElement1) {
            tempReal = outReal[i];
            if (!IsZero(tempReal)) {
                outReal[i] = ((tempBuffer[j] - tempReal) / tempReal) * 100.0;
            } else {
                outReal[i] = 0.0;
            }

            i++;
            j++;
        }
    } else {
        i = 0;
        j = tempInteger;
        while (i < outNbElement1) {
            outReal[i] = tempBuffer[j] - outReal[i];

            i++;
            j++;
        }
    }

    outBegIndex = outBegIndex1;
    outNBElement = outNbElement1;
    // }
    // }

    // if (retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success)) {
    //     VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
    //     VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
    // }

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}
