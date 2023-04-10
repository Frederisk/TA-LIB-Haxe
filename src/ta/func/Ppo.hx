package ta.func;

import ta.func.Utility.TAIntMax;
import ta.func.Apo.IntPo;
import ta.func.Ma.MaLookback;
import ta.Globals.MAType;

@:keep
function Ppo(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInFastPeriod:Int, optInSlowPeriod:Int, optInMAType:MAType) {
    // var outBegIndex:Int;
    // var outNBElement:Int;
    // var outReal:Array<Float> = [];

    var tempBuffe:Array<Float>;
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

    // ARRAY_ALLOC(tempBuffer, endIndex - startIndex + 1);
    // #if !defined (_JAVA)
    // if (!tempBuffer)
    //     return ENUM_VALUE(RetCode, TA_ALLOC_ERR, AllocErr);
    // #endif

    ret = IntPo(startIndex, endIndex, inReal, optInFastPeriod, optInSlowPeriod, optInMAType, 1);
    return ret;
}

@:keep
function PpoLookback(optInFastPeriod:Int, optInSlowPeriod:Int, optInMAType:MAType) {
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
