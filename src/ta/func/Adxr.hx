package ta.func;

import ta.func.Adx.Adx;
import ta.func.Adx.AdxLookback;

@:keep
function Adxr(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var adx:Array<Float>; // No initialization required
    var adxrLookback:Int, i:Int, j:Int, outIndex:Int, nbElement:Int;
    var ret;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inHigh == null || inLow == null || inClose == null) {
        throw new TAException(BadParam);
    }
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
        throw new TAException(BadParam);
    }

    adxrLookback = AdxrLookback(optInTimePeriod);

    if (startIndex < adxrLookback) {
        startIndex = adxrLookback;
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

    // ARRAY_ALLOC( adx, endIndex-startIndex+optInTimePeriod );
    // #if !defined( _JAVA )
    //    if( !adx )
    //       return ENUM_VALUE(RetCode,TA_ALLOC_ERR,AllocErr);
    // #endif

    ret = Adx(startIndex - (optInTimePeriod - 1), endIndex, inHigh, inLow, inClose, optInTimePeriod);
    outBegIndex = ret.outBegIndex;
    outNBElement = ret.outNBElement;
    adx = ret.outReal;

    // retCode = FUNCTION_CALL(ADX)( startIndex-(optInTimePeriod-1), endIndex,
    //                               inHigh, inLow, inClose,
    //                               optInTimePeriod, outBegIndex, outNBElement, adx );

    // if( retCode != ENUM_VALUE(RetCode,TA_SUCCESS,Success) )
    // {
    //    ARRAY_FREE( adx );
    //    return retCode;
    // }

    i = optInTimePeriod - 1;
    j = 0;
    outIndex = 0;
    nbElement = endIndex - startIndex + 2;
    while (--nbElement != 0) {
        outReal[outIndex++] = round_pos((adx[i++] + adx[j++]) / 2.0);
    }

    // ARRAY_FREE( adx );

    outBegIndex = startIndex;
    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

inline function round_pos(num:Float) {
    return num;
}

@:keep
function AdxrLookback(optInTimePeriod:Int):Int {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }

    if (optInTimePeriod > 1) {
        return (optInTimePeriod + AdxLookback(optInTimePeriod) - 1);
    } else {
        // FIXME: WTF
        return 3;
    }
}
