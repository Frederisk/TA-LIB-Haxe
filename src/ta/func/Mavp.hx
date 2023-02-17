package ta.func;

import ta.func.Ma.MaLookback;
import ta.Globals.MAType;

@:keep
function Mavp(startIndex:Int, endIndex:Int, inReal:Array<Float>, inPeriods:Array<Float>, optInMinPeriod:Int, optInMaxPeriod:Int, optInMAType:MAType) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var i:Int,
        j:Int,
        lookbackTotal:Int,
        outputSize:Int,
        tempInt:Int,
        curPeriod:Int;

    var localPeriodArray:Array<Int>; // No initialization required
    var localOutputArray:Array<Float>; // No initialization required
    var localBegIndex:Int;
    var localNbElement:Int;
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
    // if(optInMinPeriod = null) {
    //    optInFastLimit = 3;
    // }
    if (optInMinPeriod < 2) {
        throw new TAException(BadParam);
    }
    // INTEGER_DEFAULT
    // if(optInMaxPeriod = null) {
    //    optInFastLimit = 30;
    // }
    if (optInMaxPeriod < 2) {
        throw new TAException(BadParam);
    }
    if (MAType == null) {
        // optInMAType = 0;
        optInMAType = Sma;
    }

    lookbackTotal = MaLookback(optInMaxPeriod, optInMAType);

    if (startIndex < lookbackTotal) {
        startIndex = lookbackTotal;
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

    if (lookbackTotal > startIndex) {
        tempInt = lookbackTotal;
    } else {
        tempInt = startIndex;
    }
    if (tempInt > endIndex) {
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }
    outputSize = endIndex - tempInt + 1;

    // ARRAY_ALLOC(localOutputArray, outputSize);
    // ARRAY_INT_ALLOC(localPeriodArray, outputSize);

    i = 0;
    while (i < outputSize) {
        tempInt = Std.int(inPeriods[startIndex + i]);
        if (tempInt < optInMinPeriod) {
            tempInt = optInMinPeriod;
        } else if (tempInt > optInMaxPeriod) {
            tempInt = optInMaxPeriod;
        }
        localPeriodArray[i] = tempInt;

        i++;
    }

    i = 0;
    while (i < outputSize) {
        curPeriod = localPeriodArray[i];
        if (curPeriod != 0) {
            ret = Ma(startIndex, endIndex, inReal, curPeriod, optInMAType);

            localBegIndex = ret.outBegIndex;
            localNbElement = ret.outNBElement;
            localOutputArray = ret.outReal;

            // if (retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success)) {
            //     ARRAY_FREE(localOutputArray);
            //     ARRAY_INT_FREE(localPeriodArray);
            //     VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
            //     VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
            //     return retCode;
            // }

            outReal[i] = localOutputArray[i];
            j = i + 1;
            while (j < outputSize) {
                if (localPeriodArray[j] == curPeriod) {
                    localPeriodArray[j] = 0;
                    outReal[j] = localOutputArray[j];
                }
            }

            j++;
        }

        i++;
    }

    // ARRAY_FREE(localOutputArray);
    // ARRAY_INT_FREE(localPeriodArray);

    outBegIndex = startIndex;
    outNBElement = outputSize;
    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function MavpLookback(optInMinPeriod:Int, optInMaxPeriod:Int, optInMAType:MAType) {
    // INTEGER_DEFAULT
    // if(optInMinPeriod = null) {
    //    optInFastLimit = 3;
    // }
    if (optInMinPeriod < 2) {
        return -1;
    }
    // INTEGER_DEFAULT
    // if(optInMaxPeriod = null) {
    //    optInFastLimit = 30;
    // }
    if (optInMaxPeriod < 2) {
        return -1;
    }
    if (MAType == null) {
        // optInMAType = 0;
        optInMAType = Sma;
    }

    return MaLookback(optInMaxPeriod, optInMAType);
}
