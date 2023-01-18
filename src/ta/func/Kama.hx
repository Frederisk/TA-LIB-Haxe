package ta.func;

import ta.Globals.FuncUnstId;
import ta.func.Utility.IsZero;

@:keep
function Kama(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var constMax:Float = 2.0 / (30.0 + 1.0);
    var constDiff:Float = 2.0 / (2.0 + 1.0) - constMax;

    var tempReal:Float, tempReal2:Float;
    var sumROC1:Float, periodROC:Float, prevKAMA:Float;
    var i:Int, today:Int, outIndex:Int, lookbackTotal:Int;
    var trailingIndex:Int;
    var trailingValue:Float;

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
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 2) {
        throw new TAException(BadParam);
    }

    outBegIndex = 0;
    outNBElement = 0;

    lookbackTotal = optInTimePeriod + Globals.unstablePeriod[FuncUnstId.Kama];

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

    sumROC1 = 0.0;
    today = startIndex - lookbackTotal;
    trailingIndex = today;
    i = optInTimePeriod;
    while (i-- > 0) {
        tempReal = inReal[today++];
        tempReal -= inReal[today];
        sumROC1 += Math.abs(tempReal);
    }

    prevKAMA = inReal[today - 1];

    tempReal = inReal[today];
    tempReal2 = inReal[trailingIndex++];
    periodROC = tempReal - tempReal2;

    trailingValue = tempReal2;

    if ((sumROC1 <= periodROC) || IsZero(sumROC1)) {
        tempReal = 1.0;
    } else {
        tempReal = Math.abs(periodROC / sumROC1);
    }

    tempReal = (tempReal * constDiff) + constMax;
    tempReal *= tempReal;
    trace(today);
    prevKAMA = ((inReal[today++] - prevKAMA) * tempReal) + prevKAMA;

    while (today <= startIndex) {
        tempReal = inReal[today];
        tempReal2 = inReal[trailingIndex++];
        periodROC = tempReal - tempReal2;

        sumROC1 -= Math.abs(trailingValue - tempReal2);
        sumROC1 += Math.abs(tempReal - inReal[today - 1]);

        trailingValue = tempReal2;

        if ((sumROC1 <= periodROC) || IsZero(sumROC1)) {
            tempReal = 1.0;
        } else {
            tempReal = Math.abs(periodROC / sumROC1);
        }

        tempReal = (tempReal * constDiff) + constMax;
        tempReal *= tempReal;

        prevKAMA = ((inReal[today++] - prevKAMA) * tempReal) + prevKAMA;
    }

    outReal[0] = prevKAMA;
    outIndex = 1;
    outBegIndex = today - 1;

    while (today <= endIndex) {
        tempReal = inReal[today];
        tempReal2 = inReal[trailingIndex++];
        periodROC = tempReal - tempReal2;

        sumROC1 -= Math.abs(trailingValue - tempReal2);
        sumROC1 += Math.abs(tempReal - inReal[today - 1]);

        trailingValue = tempReal2;

        if ((sumROC1 <= periodROC) || IsZero(sumROC1)) {
            tempReal = 1.0;
        } else {
            tempReal = Math.abs(periodROC / sumROC1);
        }

        tempReal = (tempReal * constDiff) + constMax;
        tempReal *= tempReal;
        // trace('inReal[today]', inReal[today]);
        // trace('prevKAMA', prevKAMA);
        // trace('tempReal', tempReal);

        prevKAMA = ((inReal[today++] - prevKAMA) * tempReal) + prevKAMA;
        outReal[outIndex++] = prevKAMA;
    }

    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function KamaLookback(optInTimePeriod:Int) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }
    return (optInTimePeriod + Globals.unstablePeriod[FuncUnstId.Kama]);
}
