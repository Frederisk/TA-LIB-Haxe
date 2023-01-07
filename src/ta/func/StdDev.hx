package ta.func;

import ta.func.Var.IntVar;
import ta.func.Var.VarLookback;
import ta.func.Utility.IsZeroOrNeg;

@:keep
function StdDev(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int, optInNbDev:Float) {
    // var outBegIndex:Int;
    // var outNBElement:Int;
    // var outReal:Array<Float> = [];

    var i:Int;
    var tempReal:Float;

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
    if (optInTimePeriod < 2) {
        throw new TAException(BadParam);
    }

    var ret = IntVar(startIndex, endIndex, inReal, optInTimePeriod);
    // ret = IntVar(startIdx, endIdx, inReal, optInTimePeriod, outBegIdx, outNBElement, outReal);
    var outBegIndex:Int = ret.outBegIndex;
    var outNBElement:Int = ret.outNBElement;
    var outReal:Array<Float> = ret.outReal;

    // if (retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success))
    //     return retCode;
    if (optInNbDev != 1.0) {
        i = 0;
        while (i < outNBElement) {
            tempReal = outReal[i];
            if (!IsZeroOrNeg(tempReal)) {
                outReal[i] = Math.sqrt(tempReal) * optInNbDev;
            } else {
                outReal[i] = 0.0;
            }
            i++;
        }
    } else {
        i = 0;
        while (i < outNBElement) {
            tempReal = outReal[i];
            if (!IsZeroOrNeg(tempReal)) {
                outReal[i] = Math.sqrt(tempReal);
            } else {
                outReal[i] = 0.0;
            }
            i++;
        }
    }

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function StdDevLookback(optInTimePeriod:Int, optInNbDev:Float) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 5;
    // } else
    // INTEGER_DEFAULT
    // if(optInNbDev == null || ){
    //     optInNbDev = 1.0;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }
    return (VarLookback(optInTimePeriod, optInNbDev));
}
