package ta.func;

import ta.func.Utility.IsZero;
import ta.func.Utility.TrueRange;
import ta.Globals.FuncUnstId;

@:keep
function PlusDi(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var today:Int, lookbackTotal:Int, outIndex:Int;
    var prevHigh:Float, prevLow:Float, prevClose:Float;
    var prevPlusDM:Float, prevTR:Float;
    var tempReal:Float, diffP:Float, diffM:Float; // tempReal2:Float

    var i:Int;

    // inline function TrueRange(th:Float, tl:Float, yc:Float) {
    //     var out = th - tl;
    //     var tempReal2 = Math.abs(th - yc);
    //     if (tempReal2 > out) {
    //         out = tempReal2;
    //     }
    //     tempReal2 = Math.abs(tl - yc);
    //     if (tempReal2 > out) {
    //         out = tempReal2;
    //     }
    //     return out;
    // }

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
    if (optInTimePeriod < 1) {
        throw new TAException(BadParam);
    }

    if (optInTimePeriod > 1) {
        lookbackTotal = optInTimePeriod + Globals.unstablePeriod[FuncUnstId.PlusDI];
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
        prevClose = inClose[today];
        while (today < endIndex) {
            today++;
            tempReal = inHigh[today];
            diffP = tempReal - prevHigh;
            prevHigh = tempReal;
            tempReal = inLow[today];
            diffM = prevLow - tempReal;
            prevLow = tempReal;
            if ((diffP > 0) && (diffP > diffM)) {
                tempReal = TrueRange(prevHigh, prevLow, prevClose);
                if (IsZero(tempReal)) {
                    outReal[outIndex++] = 0.0;
                } else {
                    outReal[outIndex++] = diffP / tempReal;
                }
            } else {
                outReal[outIndex++] = 0.0;
            }
            prevClose = inClose[today];
        }

        outNBElement = outIndex;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    outBegIndex = today = startIndex;

    prevPlusDM = 0.0;
    prevTR = 0.0;
    today = startIndex - lookbackTotal;
    prevHigh = inHigh[today];
    prevLow = inLow[today];
    prevClose = inClose[today];
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

        tempReal = TrueRange(prevHigh, prevLow, prevClose);
        prevTR += tempReal;
        prevClose = inClose[today];
    }

    i = Globals.unstablePeriod[FuncUnstId.PlusDI] + 1;
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

        tempReal = TrueRange(prevHigh, prevLow, prevClose);
        prevTR = prevTR - (prevTR / optInTimePeriod) + tempReal;
        prevClose = inClose[today];
    }

    if (!IsZero(prevTR)) {
        outReal[0] = round_pos(100.0 * (prevPlusDM / prevTR));
    } else {
        outReal[0] = 0.0;
    }
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

        tempReal = TrueRange(prevHigh, prevLow, prevClose);
        prevTR = prevTR - (prevTR / optInTimePeriod) + tempReal;
        prevClose = inClose[today];

        if (!IsZero(prevTR)) {
            outReal[outIndex++] = round_pos(100.0 * (prevPlusDM / prevTR));
        } else {
            outReal[outIndex++] = 0.0;
        }
    }

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
function PlusDiLookback(optInTimePeriod:Int) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 1) {
        return -1;
    }

    if (optInTimePeriod > 1) {
        return (optInTimePeriod + Globals.unstablePeriod[FuncUnstId.PlusDI]);
    } else {
        return 1;
    }
}
