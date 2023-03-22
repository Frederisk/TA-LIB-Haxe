package ta.func;

import ta.func.Utility.TrueRange;
import ta.func.Utility.IsZero;
import ta.Globals.FuncUnstId;

@:keep
function Dx(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var today:Int, lookbackTotal:Int, outIndex:Int;
    var prevHigh:Float, prevLow:Float, prevClose:Float;
    var prevMinusDM:Float, prevPlusDM:Float, prevTR:Float;
    var tempReal:Float, tempReal2:Float, diffP:Float, diffM:Float;
    var minusDI:Float, plusDI:Float;

    var i:Int;

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

    if (optInTimePeriod > 1)
        lookbackTotal = optInTimePeriod + Globals.unstablePeriod[FuncUnstId.Dx];
    else {
        lookbackTotal = 2;
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

    outBegIndex = today = startIndex;

    prevMinusDM = 0.0;
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

        if ((diffM > 0) && (diffP < diffM)) {
            prevMinusDM += diffM;
        } else if ((diffP > 0) && (diffP > diffM)) {
            prevPlusDM += diffP;
        }

        tempReal = TrueRange(prevHigh, prevLow, prevClose);
        prevTR += tempReal;
        prevClose = inClose[today];
    }

    i = Globals.unstablePeriod[FuncUnstId.Dx] + 1;
    while (i-- != 0) {
        today++;
        tempReal = inHigh[today];
        diffP = tempReal - prevHigh;
        prevHigh = tempReal;

        tempReal = inLow[today];
        diffM = prevLow - tempReal;
        prevLow = tempReal;

        prevMinusDM -= prevMinusDM / optInTimePeriod;
        prevPlusDM -= prevPlusDM / optInTimePeriod;

        if ((diffM > 0) && (diffP < diffM)) {
            prevMinusDM += diffM;
        } else if ((diffP > 0) && (diffP > diffM)) {
            prevPlusDM += diffP;
        }

        tempReal = TrueRange(prevHigh, prevLow, prevClose);
        prevTR = prevTR - (prevTR / optInTimePeriod) + tempReal;
        prevClose = inClose[today];
    }

    if (!IsZero(prevTR)) {
        minusDI = round_pos(100.0 * (prevMinusDM / prevTR));
        plusDI = round_pos(100.0 * (prevPlusDM / prevTR));
        tempReal = minusDI + plusDI;
        if (!IsZero(tempReal)) {
            outReal[0] = round_pos(100.0 * (Math.abs(minusDI - plusDI) / tempReal));
        } else {
            outReal[0] = 0.0;
        }
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

        prevMinusDM -= prevMinusDM / optInTimePeriod;
        prevPlusDM -= prevPlusDM / optInTimePeriod;

        if ((diffM > 0) && (diffP < diffM)) {
            prevMinusDM += diffM;
        } else if ((diffP > 0) && (diffP > diffM)) {
            prevPlusDM += diffP;
        }

        tempReal = TrueRange(prevHigh, prevLow, prevClose);
        prevTR = prevTR - (prevTR / optInTimePeriod) + tempReal;
        prevClose = inClose[today];

        if (!IsZero(prevTR)) {
            minusDI = round_pos(100.0 * (prevMinusDM / prevTR));
            plusDI = round_pos(100.0 * (prevPlusDM / prevTR));
            tempReal = minusDI + plusDI;
            if (!IsZero(tempReal)) {
                outReal[outIndex] = round_pos(100.0 * (Math.abs(minusDI - plusDI) / tempReal));
            } else {
                outReal[outIndex] = outReal[outIndex - 1];
            }
        } else {
            outReal[outIndex] = outReal[outIndex - 1];
        }
        outIndex++;
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
function DxLookback(optInTimePeriod:Int) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }

    if (optInTimePeriod < 1) {
        return (optInTimePeriod + Globals.unstablePeriod[FuncUnstId.Dx]);
    } else {
        // TODO: WTF
        return 2;
    }
}
