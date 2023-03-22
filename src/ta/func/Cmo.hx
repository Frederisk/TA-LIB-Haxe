package ta.func;

import ta.func.Utility.IsZero;
import ta.Globals.Compatibility;
import ta.Globals.FuncUnstId;

@:keep
function Cmo(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var outIndex:Int;
    var today:Int, lookbackTotal:Int, unstablePeriod:Int, i:Int;
    var prevGain:Float, prevLoss:Float, prevValue:Float, savePrevValue:Float;
    var tempValue1:Float, tempValue2:Float, tempValue3:Float, tempValue4:Float;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
        throw new TAException(BadParam);
    }

    outBegIndex = 0;
    outNBElement = 0;

    lookbackTotal = CmoLookback(optInTimePeriod);

    if (startIndex < lookbackTotal) {
        startIndex = lookbackTotal;
    }

    if (startIndex > endIndex) {
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    outIndex = 0;

    if (optInTimePeriod == 1) {
        outBegIndex = startIndex;
        i = (endIndex - startIndex) + 1;
        outNBElement = i;

        // ARRAY_MEMMOVE(outReal, 0, inReal, startIndex, i);
        // memmove(&outReal[0], &inReal[startIdx], (i) * sizeof(double))
        outReal = inReal.slice(startIndex, startIndex + i);

        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    today = startIndex - lookbackTotal;
    prevValue = inReal[today];

    unstablePeriod = Globals.unstablePeriod[FuncUnstId.Cmo];

    if ((unstablePeriod == 0) && (Globals.compatibility == Compatibility.Metastock)) {
        savePrevValue = prevValue;

        prevGain = 0.0;
        prevLoss = 0.0;
        i = optInTimePeriod;
        while (i > 0) {
            tempValue1 = inReal[today++];
            tempValue2 = tempValue1 - prevValue;
            prevValue = tempValue1;
            if (tempValue2 < 0) {
                prevLoss -= tempValue2;
            } else {
                prevGain += tempValue2;
            }

            i--;
        }

        tempValue1 = prevLoss / optInTimePeriod;
        tempValue2 = prevGain / optInTimePeriod;
        tempValue3 = tempValue2 - tempValue1;
        tempValue4 = tempValue1 + tempValue2;

        if (!IsZero(tempValue4)) {
            outReal[outIndex++] = 100 * (tempValue3 / tempValue4);
        } else {
            outReal[outIndex++] = 0.0;
        }

        if (today > endIndex) {
            outBegIndex = startIndex;
            outNBElement = outIndex;
            return {
                outBegIndex: outBegIndex,
                outNBElement: outNBElement,
                outReal: outReal
            };
        }

        today -= optInTimePeriod;
        prevValue = savePrevValue;
    }

    prevGain = 0.0;
    prevLoss = 0.0;
    today++;

    i = optInTimePeriod;
    while (i > 0) {
        tempValue1 = inReal[today++];
        tempValue2 = tempValue1 - prevValue;
        prevValue = tempValue1;
        if (tempValue2 < 0) {
            prevLoss -= tempValue2;
        } else {
            prevGain += tempValue2;
        }

        i--;
    }

    prevLoss /= optInTimePeriod;
    prevGain /= optInTimePeriod;

    if (today > startIndex) {
        tempValue1 = prevGain + prevLoss;
        if (!IsZero(tempValue1)) {
            outReal[outIndex++] = 100.0 * ((prevGain - prevLoss) / tempValue1);
        } else {
            outReal[outIndex++] = 0.0;
        }
    } else {
        while (today < startIndex) {
            tempValue1 = inReal[today];
            tempValue2 = tempValue1 - prevValue;
            prevValue = tempValue1;

            prevLoss *= (optInTimePeriod - 1);
            prevGain *= (optInTimePeriod - 1);
            if (tempValue2 < 0) {
                prevLoss -= tempValue2;
            } else {
                prevGain += tempValue2;
            }

            prevLoss /= optInTimePeriod;
            prevGain /= optInTimePeriod;

            today++;
        }
    }

    while (today <= endIndex) {
        tempValue1 = inReal[today++];
        tempValue2 = tempValue1 - prevValue;
        prevValue = tempValue1;

        prevLoss *= (optInTimePeriod - 1);
        prevGain *= (optInTimePeriod - 1);
        if (tempValue2 < 0) {
            prevLoss -= tempValue2;
        } else {
            prevGain += tempValue2;
        }

        prevLoss /= optInTimePeriod;
        prevGain /= optInTimePeriod;
        tempValue1 = prevGain + prevLoss;
        if (!IsZero(tempValue1)) {
            outReal[outIndex++] = 100.0 * ((prevGain - prevLoss) / tempValue1);
        } else {
            outReal[outIndex++] = 0.0;
        }
    }

    outBegIndex = startIndex;
    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function CmoLookback(optInTimePeriod:Int) {
    var retValue;

    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }

    retValue = optInTimePeriod + Globals.unstablePeriod[FuncUnstId.Cmo];

    if (Globals.compatibility == Compatibility.Metastock)
        retValue--;

    return retValue;
}
