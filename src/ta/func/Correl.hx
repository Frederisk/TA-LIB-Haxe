package ta.func;

import ta.func.Utility.IsZeroOrNeg;

@:keep
function Correl(startIndex:Int, endIndex:Int, inReal0:Array<Float>, inReal1:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var sumXY:Float,
        sumX:Float,
        sumY:Float,
        sumX2:Float,
        sumY2:Float,
        x:Float,
        y:Float,
        trailingX:Float,
        trailingY:Float;
    var tempReal:Float;
    var lookbackTotal:Int, today:Int, trailingIndex:Int, outIndex:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inReal0 == null) {
        throw new TAException(BadParam);
    }
    if (inReal1 == null) {
        throw new TAException(BadParam);
    }
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 1) {
        throw new TAException(BadParam);
    }
    lookbackTotal = optInTimePeriod - 1;
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

    outBegIndex = startIndex;
    trailingIndex = startIndex - lookbackTotal;

    sumXY = sumX = sumY = sumX2 = sumY2 = 0.0;

    today = trailingIndex;

    while (today <= startIndex) {
        x = inReal0[today];
        sumX += x;
        sumX2 += x * x;

        y = inReal1[today];
        sumXY += x * y;
        sumY += y;
        sumY2 += y * y;
        today++;
    }

    trailingX = inReal0[trailingIndex];
    trailingY = inReal1[trailingIndex++];
    tempReal = (sumX2 - ((sumX * sumX) / optInTimePeriod)) * (sumY2 - ((sumY * sumY) / optInTimePeriod));
    if (!IsZeroOrNeg(tempReal)) {
        outReal[0] = (sumXY - ((sumX * sumY) / optInTimePeriod)) / Math.sqrt(tempReal);
    } else {
        outReal[0] = 0.0;
    }

    outIndex = 1;
    while (today <= endIndex) {
        sumX -= trailingX;
        sumX2 -= trailingX * trailingX;

        sumXY -= trailingX * trailingY;
        sumY -= trailingY;
        sumY2 -= trailingY * trailingY;

        x = inReal0[today];
        sumX += x;
        sumX2 += x * x;

        y = inReal1[today++];
        sumXY += x * y;
        sumY += y;
        sumY2 += y * y;

        trailingX = inReal0[trailingIndex];
        trailingY = inReal1[trailingIndex++];
        tempReal = (sumX2 - ((sumX * sumX) / optInTimePeriod)) * (sumY2 - ((sumY * sumY) / optInTimePeriod));
        if (!IsZeroOrNeg(tempReal)) {
            outReal[outIndex++] = (sumXY - ((sumX * sumY) / optInTimePeriod)) / Math.sqrt(tempReal);
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

@:keep
function CorrelLookback(optInTimePeriod:Int):Int {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 1) {
        return -1;
    }
    return (optInTimePeriod - 1);
}
