package ta.func;

import ta.func.Ma.Ma;
import ta.func.Ma.MaLookback;
import ta.Globals.MAType;

@:keep
function Stoch(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>, optInFastK_Period:Int, optInSlowK_Period:Int,
        optInSlowK_MAType:MAType, optInSlowD_Period:Int, optInSlowD_MAType:MAType) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outSlowK:Array<Float> = [];
    var outSlowD:Array<Float> = [];

    var ret;
    var lowest:Float, highest:Float, tmp:Float, diff:Float;
    var tempBuffer:Array<Float> = [];
    var outIndex:Int, lowestIndex:Int, highestIndex:Int;
    var lookbackTotal:Int, lookbackK:Int, lookbackKSlow:Int, lookbackDSlow:Int;
    var trailingIndex:Int, today:Int, i:Int;

    // var bufferIsAllocated:Int;

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
    // optInSlowK_Period = 3;
    if (optInSlowK_Period < 1) {
        throw new TAException(BadParam);
    }
    if (optInSlowK_MAType == null) {
        optInSlowK_MAType = MAType.Sma;
    }
    // optInSlowD_Period = 3;
    if (optInSlowD_Period < 1) {
        throw new TAException(BadParam);
    }
    if (optInSlowD_MAType == null) {
        optInSlowD_MAType = MAType.Sma;
    }

    lookbackK = optInFastK_Period - 1;
    lookbackKSlow = MaLookback(optInSlowK_Period, optInSlowK_MAType);
    lookbackDSlow = MaLookback(optInSlowD_Period, optInSlowD_MAType);
    lookbackTotal = lookbackK + lookbackDSlow + lookbackKSlow;

    if (startIndex < lookbackTotal) {
        startIndex = lookbackTotal;
    }

    if (startIndex > endIndex) {
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outSlowK: outSlowK,
            outSlowD: outSlowD
        };
    }

    outIndex = 0;

    trailingIndex = startIndex - lookbackTotal;
    today = trailingIndex + lookbackK;
    lowestIndex = highestIndex = -1;
    diff = highest = lowest = 0.0;

    // bufferIsAllocated = 0;

    // if ((outSlowK == inHigh) || (outSlowK == inLow) || (outSlowK == inClose)) {
    //     tempBuffer = outSlowK;
    // } else if ((outSlowD == inHigh) || (outSlowD == inLow) || (outSlowD == inClose)) {
    //     tempBuffer = outSlowD;
    // } else {
    //     bufferIsAllocated = 1;
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

    ret = Ma(0, outIndex - 1, tempBuffer, optInSlowK_Period, optInSlowK_MAType);
    outBegIndex = ret.outBegIndex;
    outNBElement = ret.outNBElement;
    tempBuffer = ret.outReal;
    // retCode = Ma(, outBegIndex, outNBElement, tempBuffer);

    if (outNBElement == 0) {
        // ARRAY_FREE_COND(bufferIsAllocated, tempBuffer);
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outSlowK: outSlowK,
            outSlowD: outSlowD
        };
    }

    ret = Ma(0, outNBElement - 1, tempBuffer, optInSlowD_Period, optInSlowD_MAType);
    outBegIndex = ret.outBegIndex;
    outNBElement = ret.outNBElement;
    outSlowD = ret.outReal;
    // retCode = FUNCTION_CALL_DOUBLE(MA)(, outBegIndex, outNBElement, outSlowD);
    // ARRAY_MEMMOVE( outSlowK, 0, tempBuffer,lookbackDSlow,(int)VALUE_HANDLE_DEREF(outNBElement));
    // memmove(&outSlowK[0], &tempBuffer[lookbackDSlow], ((int)(*outNBElement)) * sizeof(double))
    outSlowK = tempBuffer.slice(lookbackDSlow, lookbackDSlow + outNBElement);

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
        outSlowK: outSlowK,
        outSlowD: outSlowD
    };
}

@:keep
function StochLookback(optInFastK_Period:Int, optInSlowK_Period:Int, optInSlowK_MAType:MAType, optInSlowD_Period:Int, optInSlowD_MAType:MAType) {
    var retValue:Int;

    // DEFAULT & RANGE
    // optInFastK_Period = 5;
    if (optInFastK_Period < 1) {
        return -1;
    }
    // optInSlowK_Period = 3;
    if (optInSlowK_Period < 1) {
        return -1;
    }
    if (optInSlowK_MAType == null) {
        optInSlowK_MAType = MAType.Sma;
    }
    // optInSlowD_Period = 3;
    if (optInSlowD_Period < 1) {
        return -1;
    }
    if (optInSlowD_MAType == null) {
        optInSlowD_MAType = MAType.Sma;
    }

    retValue = (optInFastK_Period - 1);

    retValue += MaLookback(optInSlowK_Period, optInSlowK_MAType);

    retValue += MaLookback(optInSlowD_Period, optInSlowD_MAType);

    return retValue;
}
