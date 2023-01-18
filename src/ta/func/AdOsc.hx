package ta.func;

import ta.func.Ema.EmaLookback;
import ta.func.Utility.PerToK;

@:keep
function AdOsc(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>, inVolume:Array<Float>, optInFastPeriod:Int,
        optInSlowPeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var today:Int, outIndex:Int, lookbackTotal:Int;
    var slowestPeriod:Int;
    var high:Float, low:Float, close:Float, tmp:Float;
    var slowEMA:Float, slowk:Float, one_minus_slowk:Float;
    var fastEMA:Float, fastk:Float, one_minus_fastk:Float;
    var ad:Float;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inHigh == null || inLow == null || inClose == null || inVolume == null) {
        throw new TAException(BadParam);
    }
    // if (optInFastPeriod == null)
    //     optInFastPeriod = 3;
    // else
    if (optInFastPeriod < 2) {
        throw new TAException(BadParam);
    }
    // if ((int) optInSlowPeriod == null)
    //     {optInSlowPeriod = 10;}
    // else
    if (optInSlowPeriod < 2) {
        throw new TAException(BadParam);
    }

    if (optInFastPeriod < optInSlowPeriod) {
        slowestPeriod = optInSlowPeriod;
    } else {
        slowestPeriod = optInFastPeriod;
    }

    lookbackTotal = EmaLookback(slowestPeriod);
    if (startIndex < lookbackTotal)
        startIndex = lookbackTotal;

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

    ad = 0.0;

    //    #define CALCULATE_AD \
    //    { \
    //       high  = inHigh[today]; \
    //       low   = inLow[today]; \
    //       tmp   = high-low; \
    //       close = inClose[today]; \
    //       if( tmp > 0.0 ) \
    //          ad += (((close-low)-(high-close))/tmp)*((double)inVolume[today]); \
    //       today++; \
    //    }

    /* Constants for EMA */
    fastk = PerToK(optInFastPeriod);
    one_minus_fastk = 1.0 - fastk;

    slowk = PerToK(optInSlowPeriod);
    one_minus_slowk = 1.0 - slowk;

    //    CALCULATE_AD;
    high = inHigh[today];
    low = inLow[today];
    tmp = high - low;
    close = inClose[today];
    if (tmp > 0.0)
        ad += (((close - low) - (high - close)) / tmp) * (inVolume[today]);
    today++;

    fastEMA = ad;
    slowEMA = ad;

    while (today < startIndex) {
        //   CALCULATE_AD;
        high = inHigh[today];
        low = inLow[today];
        tmp = high - low;
        close = inClose[today];
        if (tmp > 0.0)
            ad += (((close - low) - (high - close)) / tmp) * (inVolume[today]);
        today++;

        fastEMA = (fastk * ad) + (one_minus_fastk * fastEMA);
        slowEMA = (slowk * ad) + (one_minus_slowk * slowEMA);
    }

    outIndex = 0;
    while (today <= endIndex) {
        //   CALCULATE_AD;
        high = inHigh[today];
        low = inLow[today];
        tmp = high - low;
        close = inClose[today];
        if (tmp > 0.0)
            ad += (((close - low) - (high - close)) / tmp) * (inVolume[today]);
        today++;

        fastEMA = (fastk * ad) + (one_minus_fastk * fastEMA);
        slowEMA = (slowk * ad) + (one_minus_slowk * slowEMA);

        outReal[outIndex++] = fastEMA - slowEMA;
    }
    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function AdOscLookback(optInFastPeriod:Int, optInSlowPeriod:Int) {
    var slowestPeriod:Int;

    // if (optInFastPeriod == null)
    //     optInFastPeriod = 3;
    // else
    if (optInFastPeriod < 2) {
        return -1;
    }
    // if ((int) optInSlowPeriod == null)
    //     {optInSlowPeriod = 10;}
    // else
    if (optInSlowPeriod < 2) {
        return -1;
    }

    if (optInFastPeriod < optInSlowPeriod) {
        slowestPeriod = optInSlowPeriod;
    } else {
        slowestPeriod = optInFastPeriod;
    }

    return EmaLookback(slowestPeriod);
}
