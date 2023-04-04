package ta.func;

import ta.func.Ma.Ma;
import ta.func.Ma.MaLookback;
import ta.Globals.MAType;

@:keep
function StochF(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>, optInFastK_Period:Int, optInFastD_Period:Int,
        optInFastD_MAType:MAType) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outFastK:Array<Float> = [];
    var outFastD:Array<Float> = [];

    var ret;
    var lowest:Float, highest:Float, tmp:Float, diff:Float;
    var tempBuffer:Array<Float> = [];

    var outIndex:Int, lowestIndex:Int, highestIndex:Int;
    var lookbackTotal:Int, lookbackK:Int, lookbackFastD:Int;
    var trailingIndex:Int, today:Int, i:Int;

    // int bufferIsAllocated;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inHigh == null || inLow == null || inClose == null) {
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

    lookbackK = optInFastK_Period - 1;
    lookbackFastD = MaLookback(optInFastD_Period, optInFastD_MAType);
    lookbackTotal = lookbackK + lookbackFastD;

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

    outIndex = 0;

    trailingIndex = startIndex - lookbackTotal;
    today = trailingIndex + lookbackK;
    lowestIndex = highestIndex = -1;
    diff = highest = lowest = 0.0;

    // bufferIsAllocated = 0;

    // if ((outFastK == inHigh) || (outFastK == inLow) || (outFastK == inClose)) {
    //     tempBuffer = outFastK;
    // } else if ((outFastD == inHigh) || (outFastD == inLow) || (outFastD == inClose)) {
    //     tempBuffer = outFastD;
    // } else {
    //     ARRAY_ALLOC(tempBuffer, endIndex - today + 1);
    // }

    while (today <= endIndex) {
        tmp = inLow[today];
        if (lowestIndex < trailingIndex) {
            lowestIndex = trailingIndex;
            lowest = inLow[lowestIndex];
            i = lowestIndex;
            while (++i <= today) {
                tmp = inLow[i];
                if (tmp < lowest) {
                    lowestIndex = i;
                    lowest = tmp;
                }
            }
            diff = (highest - lowest) / 100.0;
        } else if (tmp <= lowest) {
            lowestIndex = today;
            lowest = tmp;
            diff = (highest - lowest) / 100.0;
        }

        tmp = inHigh[today];
        if (highestIndex < trailingIndex) {
            highestIndex = trailingIndex;
            highest = inHigh[highestIndex];
            i = highestIndex;
            while (++i <= today) {
                tmp = inHigh[i];
                if (tmp > highest) {
                    highestIndex = i;
                    highest = tmp;
                }
            }
            diff = (highest - lowest) / 100.0;
        } else if (tmp >= highest) {
            highestIndex = today;
            highest = tmp;
            diff = (highest - lowest) / 100.0;
        }

        if (diff != 0.0) {
            tempBuffer[outIndex++] = (inClose[today] - lowest) / diff;
        } else {
            tempBuffer[outIndex++] = 0.0;
        }

        trailingIndex++;
        today++;
    }

    ret = Ma(0, outIndex - 1, tempBuffer, optInFastD_Period, optInFastD_MAType);
    outBegIndex = ret.outBegIndex;
    outNBElement = ret.outNBElement;
    outFastD = ret.outReal;
    // retCode = FUNCTION_CALL_DOUBLE(MA)(, outBegIndex, outNBElement, outFastD);

    if (outNBElement == 0) {
        // ARRAY_FREE_COND( bufferIsAllocated, tempBuffer );
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outFastK: outFastK,
            outFastD: outFastD
        };
    }

    // ARRAY_MEMMOVE(outFastK, 0, tempBuffer, lookbackFastD, (int) VALUE_HANDLE_DEREF(outNBElement));
    // memmove(&outFastK[0], &tempBuffer[lookbackFastD], ((int)(*outNBElement)) * sizeof(double))
    outFastK = tempBuffer.slice(lookbackFastD, lookbackFastD + outNBElement);

    // ARRAY_FREE_COND( bufferIsAllocated, tempBuffer );

    // if (retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success)) {
    //     VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
    //     VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
    //     return retCode;
    // }

    outBegIndex = startIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outFastK: outFastK,
        outFastD: outFastD
    };
}

@:keep
function StochFLookback(optInFastK_Period:Int, optInFastD_Period:Int, optInFastD_MAType:MAType) {
    var retValue:Int;

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

    retValue = (optInFastK_Period - 1);

    retValue += MaLookback(optInFastD_Period, optInFastD_MAType);

    return retValue;
}
