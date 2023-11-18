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
    var ret;
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

    ret = IntVar(startIndex, endIndex, inReal, optInTimePeriod);
    // ret = IntVar(startIndex, endIndex, inReal, optInTimePeriod, outBegIndex, outNBElement, outReal);
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

function IntStdDevUsingPrecalcMa(inReal:Array<Float>, inMovAvg:Array<Float>, inMovAvgBegIndex:Int, inMovAvgNbElement:Int, timePeriod:Int) {
    var output:Array<Float> = [];

    var tempReal:Float, periodTotal2:Float, meanValue2:Float;
    var outIndex:Int;

    var startSum:Int, endSum:Int;

    startSum = 1 + inMovAvgBegIndex - timePeriod;
    endSum = inMovAvgBegIndex;

    periodTotal2 = 0;

    outIndex = startSum;
    while (outIndex < endSum) {

        tempReal = inReal[outIndex];
        tempReal *= tempReal;
        periodTotal2 += tempReal;

        outIndex++;
    }

    outIndex = 0;
    while (outIndex < inMovAvgNbElement) {
        tempReal = inReal[endSum];
        tempReal *= tempReal;
        periodTotal2 += tempReal;
        meanValue2 = periodTotal2 / timePeriod;

        tempReal = inReal[startSum];
        tempReal *= tempReal;
        periodTotal2 -= tempReal;

        tempReal = inMovAvg[outIndex];
        tempReal *= tempReal;
        meanValue2 -= tempReal;

        if (!IsZeroOrNeg(meanValue2)) {
            output[outIndex] = Math.sqrt(meanValue2);
        } else {
            output[outIndex] = 0.0;
        }

        outIndex++;
        startSum++;
        endSum++;
    }
    return output;
}

@:keep
function StdDevLookback(optInTimePeriod:Int, optInNbDev:Float):Int {
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
