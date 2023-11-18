package ta.func;

import ta.func.Utility.IsZero;
import ta.func.Utility.TrueRange;
import ta.Globals.FuncUnstId;

@:keep
function Adx(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var today:Int, lookbackTotal:Int, outIndex:Int;
    var prevHigh:Float, prevLow:Float, prevClose:Float;
    var prevMinusDM:Float, prevPlusDM:Float, prevTR:Float;
    var tempReal:Float, /*tempReal2:Float,*/ diffP:Float, diffM:Float;
    var minusDI:Float, plusDI:Float, sumDX:Float, prevADX:Float;

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

    lookbackTotal = (2 * optInTimePeriod) + Globals.unstablePeriod[FuncUnstId.Adx] - 1;

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

    sumDX = 0.0;
    i = optInTimePeriod;
    while (i-- > 0) {
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
            if (!IsZero(tempReal))
                sumDX += round_pos(100.0 * (Math.abs(minusDI - plusDI) / tempReal));
        }
    }

    prevADX = round_pos(sumDX / optInTimePeriod);

    i = Globals.unstablePeriod[FuncUnstId.Adx];
    while (i-- > 0) {
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
                tempReal = round_pos(100.0 * (Math.abs(minusDI - plusDI) / tempReal));
                prevADX = round_pos(((prevADX * (optInTimePeriod - 1)) + tempReal) / optInTimePeriod);
            }
        }
    }

    outReal[0] = prevADX;
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
                tempReal = round_pos(100.0 * (Math.abs(minusDI - plusDI) / tempReal));
                prevADX = round_pos(((prevADX * (optInTimePeriod - 1)) + tempReal) / optInTimePeriod);
            }
        }

        outReal[outIndex++] = prevADX;
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
function AdxLookback(optInTimePeriod:Int):Int {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }

    return ((2 * optInTimePeriod) + Globals.unstablePeriod[FuncUnstId.Adx] - 1);
}
