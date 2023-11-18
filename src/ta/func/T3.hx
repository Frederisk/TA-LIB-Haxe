package ta.func;

import ta.Globals.FuncUnstId;

@:keep
function T3(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int, optInVFactor:Float) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var outIndex:Int, lookbackTotal:Int;
    var today:Int, i:Int;
    var k:Float, one_minus_k:Float;
    var e1:Float, e2:Float, e3:Float, e4:Float, e5:Float, e6:Float;
    var c1:Float, c2:Float, c3:Float, c4:Float;
    var tempReal:Float;

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
    //     optInTimePeriod = 5;
    // } else
    if (optInTimePeriod < 2) {
        throw new TAException(BadParam);
    }
    // FLOAT_DEFAULT
    // if(optInVFactor == null || ){
    //     optInVFactor = 0.7;
    // } else
    if (optInVFactor < 0.0 || optInVFactor > 1.0) {
        throw new TAException(BadParam);
    }

    lookbackTotal = 6 * (optInTimePeriod - 1) + Globals.unstablePeriod[FuncUnstId.T3];
    if (startIndex <= lookbackTotal) {
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
    today = startIndex - lookbackTotal;

    k = 2.0 / (optInTimePeriod + 1.0);
    one_minus_k = 1.0 - k;

    tempReal = inReal[today++];

    i = optInTimePeriod - 1;
    while (i > 0) {
        tempReal += inReal[today++];

        i--;
    }
    e1 = tempReal / optInTimePeriod;

    tempReal = e1;

    i = optInTimePeriod - 1;
    while (i > 0) {
        e1 = (k * inReal[today++]) + (one_minus_k * e1);
        tempReal += e1;

        i--;
    }
    e2 = tempReal / optInTimePeriod;

    tempReal = e2;

    i = optInTimePeriod - 1;
    while (i > 0) {
        e1 = (k * inReal[today++]) + (one_minus_k * e1);
        e2 = (k * e1) + (one_minus_k * e2);
        tempReal += e2;

        i--;
    }
    e3 = tempReal / optInTimePeriod;

    tempReal = e3;

    i = optInTimePeriod - 1;
    while (i > 0) {
        e1 = (k * inReal[today++]) + (one_minus_k * e1);
        e2 = (k * e1) + (one_minus_k * e2);
        e3 = (k * e2) + (one_minus_k * e3);
        tempReal += e3;

        i--;
    }
    e4 = tempReal / optInTimePeriod;

    tempReal = e4;

    i = optInTimePeriod - 1;
    while (i > 0) {
        e1 = (k * inReal[today++]) + (one_minus_k * e1);
        e2 = (k * e1) + (one_minus_k * e2);
        e3 = (k * e2) + (one_minus_k * e3);
        e4 = (k * e3) + (one_minus_k * e4);
        tempReal += e4;

        i--;
    }
    e5 = tempReal / optInTimePeriod;

    tempReal = e5;

    i = optInTimePeriod - 1;
    while (i > 0) {
        e1 = (k * inReal[today++]) + (one_minus_k * e1);
        e2 = (k * e1) + (one_minus_k * e2);
        e3 = (k * e2) + (one_minus_k * e3);
        e4 = (k * e3) + (one_minus_k * e4);
        e5 = (k * e4) + (one_minus_k * e5);
        tempReal += e5;

        i--;
    }
    e6 = tempReal / optInTimePeriod;

    while (today <= startIndex) {
        e1 = (k * inReal[today++]) + (one_minus_k * e1);
        e2 = (k * e1) + (one_minus_k * e2);
        e3 = (k * e2) + (one_minus_k * e3);
        e4 = (k * e3) + (one_minus_k * e4);
        e5 = (k * e4) + (one_minus_k * e5);
        e6 = (k * e5) + (one_minus_k * e6);
    }

    tempReal = optInVFactor * optInVFactor;
    c1 = -(tempReal * optInVFactor);
    c2 = 3.0 * (tempReal - c1);
    c3 = -6.0 * tempReal - 3.0 * (optInVFactor - c1);
    c4 = 1.0 + 3.0 * optInVFactor - c1 + 3.0 * tempReal;

    outIndex = 0;
    outReal[outIndex++] = c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3;

    while (today <= endIndex) {
        e1 = (k * inReal[today++]) + (one_minus_k * e1);
        e2 = (k * e1) + (one_minus_k * e2);
        e3 = (k * e2) + (one_minus_k * e3);
        e4 = (k * e3) + (one_minus_k * e4);
        e5 = (k * e4) + (one_minus_k * e5);
        e6 = (k * e5) + (one_minus_k * e6);
        outReal[outIndex++] = c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3;
    }

    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function T3lookback(optInTimePeriod:Int, optInVFactor:Float):Int {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 5;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }
    // FLOAT_DEFAULT
    // if(optInVFactor == null || ){
    //     optInVFactor = 0.7;
    // } else
    if (optInVFactor < 0.0 || optInVFactor > 1.0) {
        return -1;
    }

    optInVFactor;
    return (6 * (optInTimePeriod - 1) + Globals.unstablePeriod[FuncUnstId.T3]);
}
