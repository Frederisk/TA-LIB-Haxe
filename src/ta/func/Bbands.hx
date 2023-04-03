package ta.func;

import ta.func.StdDev.StdDev;
import ta.func.StdDev.IntStdDevUsingPrecalcMa;
import ta.func.Ma.Ma;
import ta.func.Ma.MaLookback;
import ta.Globals.MAType;

function Bbands(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int, optInNbDevUp:Float, optInNbDevDn:Float, optInMAType:MAType) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outRealUpperBand:Array<Float> = [];
    var outRealMiddleBand:Array<Float> = [];
    var outRealLowerBand:Array<Float> = [];

    var ret;
    var i:Int;
    var tempReal:Float, tempReal2:Float;
    var tempBuffer1:Array<Float>;
    var tempBuffer2:Array<Float>;

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
    if (optInTimePeriod < 2) {
        throw new TAException(BadParam);
    }
    // DEFAULT && RANGE
    // optInNbDevUp = 2.0;
    // optInNbDevDn =2.0;
    if (optInMAType == null) {
        optInMAType = MAType.Sma;
    }

    if (inReal == outRealUpperBand) {
        tempBuffer1 = outRealMiddleBand;
        tempBuffer2 = outRealLowerBand;
    } else if (inReal == outRealLowerBand) {
        tempBuffer1 = outRealMiddleBand;
        tempBuffer2 = outRealUpperBand;
    } else if (inReal == outRealMiddleBand) {
        tempBuffer1 = outRealLowerBand;
        tempBuffer2 = outRealUpperBand;
    } else {
        tempBuffer1 = outRealMiddleBand;
        tempBuffer2 = outRealUpperBand;
    }
    if ((tempBuffer1 == inReal) || (tempBuffer2 == inReal)) {
        throw new TAException(BadParam);
    }

    ret = Ma(startIndex, endIndex, inReal, optInTimePeriod, optInMAType);
    outBegIndex = ret.outBegIndex;
    outNBElement = ret.outNBElement;
    tempBuffer1 = ret.outReal;
    // retCode = FUNCTION_CALL(MA)(, outBegIndex, outNBElement, tempBuffer1);

    if (outNBElement == 0) {
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outRealUpperBand: outRealUpperBand,
            outRealMiddleBand: outRealMiddleBand,
            outRealLowerBand: outRealLowerBand
        };
    }

    if (optInMAType == MAType.Sma) {
        // FUNCTION_CALL(INT_stddev_using_precalc_ma)(inReal, tempBuffer1, VALUE_HANDLE_DEREF(outBegIndex), VALUE_HANDLE_DEREF(outNBElement), optInTimePeriod,tempBuffer2);

        tempBuffer2 = IntStdDevUsingPrecalcMa(inReal, tempBuffer1, outBegIndex, outNBElement, optInTimePeriod);
    } else {
        ret = StdDev(outBegIndex, endIndex, inReal, optInTimePeriod, 1.0);
        outBegIndex = ret.outBegIndex;
        outNBElement = ret.outNBElement;
        tempBuffer2 = ret.outReal;
        // retCode = FUNCTION_CALL(STDDEV)((int) VALUE_HANDLE_DEREF(outBegIndex), endIndex, inReal, optInTimePeriod, 1.0, outBegIndex, outNBElement, tempBuffer2);

        // if (retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success)) {
        //     VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
        //     return retCode;
        // }
    }

    if (tempBuffer1 != outRealMiddleBand) {
        // ARRAY_COPY(outRealMiddleBand, tempBuffer1, VALUE_HANDLE_DEREF(outNBElement));
        // memcpy(outRealMiddleBand, tempBuffer1, sizeof(double) * (( * outNBElement)))
        outRealMiddleBand = tempBuffer1.copy();
    }

    if (optInNbDevUp == optInNbDevDn) {
        if (optInNbDevUp == 1.0) {
            i = 0;
            while (i < outNBElement) {
                tempReal = tempBuffer2[i];
                tempReal2 = outRealMiddleBand[i];
                outRealUpperBand[i] = tempReal2 + tempReal;
                outRealLowerBand[i] = tempReal2 - tempReal;

                i++;
            }
        } else {
            i = 0;
            while (i < outNBElement) {
                tempReal = tempBuffer2[i] * optInNbDevUp;
                tempReal2 = outRealMiddleBand[i];
                outRealUpperBand[i] = tempReal2 + tempReal;
                outRealLowerBand[i] = tempReal2 - tempReal;

                i++;
            }
        }
    } else if (optInNbDevUp == 1.0) {
        i = 0;
        while (i < outNBElement) {
            tempReal = tempBuffer2[i];
            tempReal2 = outRealMiddleBand[i];
            outRealUpperBand[i] = tempReal2 + tempReal;
            outRealLowerBand[i] = tempReal2 - (tempReal * optInNbDevDn);

            i++;
        }
    } else if (optInNbDevDn == 1.0) {
        i = 0;
        while (i < outNBElement) {
            tempReal = tempBuffer2[i];
            tempReal2 = outRealMiddleBand[i];
            outRealLowerBand[i] = tempReal2 - tempReal;
            outRealUpperBand[i] = tempReal2 + (tempReal * optInNbDevUp);

            i++;
        }
    } else {
        i = 0;
        while (i < outNBElement) {
            tempReal = tempBuffer2[i];
            tempReal2 = outRealMiddleBand[i];
            outRealUpperBand[i] = tempReal2 + (tempReal * optInNbDevUp);
            outRealLowerBand[i] = tempReal2 - (tempReal * optInNbDevDn);

            i++;
        }
    }

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outRealUpperBand: outRealUpperBand,
        outRealMiddleBand: outRealMiddleBand,
        outRealLowerBand: outRealLowerBand
    };
}

@:keep
function BbandsLookback(optInTimePeriod:Int, optInNbDevUp:Float, optInNbDevDn:Float, optInMAType:MAType) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 5;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }
    // DEFAULT && RANGE
    // optInNbDevUp = 2.0;
    // optInNbDevDn =2.0;
    if (optInMAType == null) {
        optInMAType = MAType.Sma;
    }

    optInNbDevUp;
    optInNbDevDn;

    return MaLookback(optInTimePeriod, optInMAType);
}
