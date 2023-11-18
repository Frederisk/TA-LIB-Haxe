package ta.func;

import ta.Globals.FuncUnstId;

@:keep
function PlusDm(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var today:Int, lookbackTotal:Int, outIndex:Int;
    var prevHigh:Float, prevLow:Float, tempReal:Float;
    var prevPlusDM:Float;
    var diffP:Float, diffM:Float;
    var i:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inHigh == null || inLow == null) {
        throw new TAException(BadParam);
    }
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 1) {
        throw new TAException(BadParam);
    }

    if (optInTimePeriod > 1) {
        lookbackTotal = optInTimePeriod + Globals.unstablePeriod[FuncUnstId.PlusDM] - 1;
    } else {
        lookbackTotal = 1;
    }

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

    outIndex = 0;

    if (optInTimePeriod <= 1) {
        outBegIndex = startIndex;
        today = startIndex - 1;
        prevHigh = inHigh[today];
        prevLow = inLow[today];
        while (today < endIndex) {
            today++;
            tempReal = inHigh[today];
            diffP = tempReal - prevHigh;
            prevHigh = tempReal;
            tempReal = inLow[today];
            diffM = prevLow - tempReal;
            prevLow = tempReal;
            if ((diffP > 0) && (diffP > diffM)) {
                outReal[outIndex++] = diffP;
            } else {
                outReal[outIndex++] = 0;
            }
        }

        outNBElement = outIndex;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    outBegIndex = startIndex;

    prevPlusDM = 0.0;
    today = startIndex - lookbackTotal;
    prevHigh = inHigh[today];
    prevLow = inLow[today];
    i = optInTimePeriod - 1;
    while (i-- > 0) {
        today++;
        tempReal = inHigh[today];
        diffP = tempReal - prevHigh;
        prevHigh = tempReal;
        tempReal = inLow[today];
        diffM = prevLow - tempReal;
        prevLow = tempReal;

        if ((diffP > 0) && (diffP > diffM)) {
            prevPlusDM += diffP;
        }
    }

    i = Globals.unstablePeriod[FuncUnstId.PlusDM];
    while (i-- != 0) {
        today++;
        tempReal = inHigh[today];
        diffP = tempReal - prevHigh;
        prevHigh = tempReal;
        tempReal = inLow[today];
        diffM = prevLow - tempReal;
        prevLow = tempReal;
        if ((diffP > 0) && (diffP > diffM)) {
            prevPlusDM = prevPlusDM - (prevPlusDM / optInTimePeriod) + diffP;
        } else {
            prevPlusDM = prevPlusDM - (prevPlusDM / optInTimePeriod);
        }
    }

    outReal[0] = prevPlusDM;
    outIndex = 1;

    while (today < endIndex) {
        today++;
        tempReal = inHigh[today];
        diffP = tempReal - prevHigh;
        prevHigh = tempReal;
        tempReal = inLow[today];
        diffM = prevLow - tempReal;
        prevLow = tempReal;

        if ((diffP > 0) && (diffP > diffM)) {
            prevPlusDM = prevPlusDM - (prevPlusDM / optInTimePeriod) + diffP;
        } else {
            prevPlusDM = prevPlusDM - (prevPlusDM / optInTimePeriod);
        }

        outReal[outIndex++] = prevPlusDM;
    }

    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function PlusDmLookback(optInTimePeriod:Int):Int {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 1) {
        return -1;
    }

    if (optInTimePeriod > 1) {
        return (optInTimePeriod + Globals.unstablePeriod[FuncUnstId.PlusDM] - 1);
    } else {
        return 1;
    }
}
