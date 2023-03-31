package ta.func;

import ta.func.Utility.IsZero;
import ta.func.Sma.SmaLookback;

@:keep
function UltOsc(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>, optInTimePeriod1:Int, optInTimePeriod2:Int,
        optInTimePeriod3:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var a1Total:Float, a2Total:Float, a3Total:Float;
    var b1Total:Float, b2Total:Float, b3Total:Float;
    var trueLow:Float, trueRange:Float, closeMinusTrueLow:Float;
    var tempDouble:Float,
        output:Float,
        tempHT:Float,
        tempLT:Float,
        tempCY:Float;
    var lookbackTotal:Int;
    var longestPeriod:Int, longestIndex:Int;
    var i:Int, j:Int, today:Int, outIndex:Int;
    var trailingIndex1:Int, trailingIndex2:Int, trailingIndex3:Int;

    var usedFlag:Array<Int>; // No initialization required
    var periods:Array<Int>; // No initialization required
    var sortedPeriods:Array<Int>; // No initialization required

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
    // if(optInTimePeriod1 == null || ){
    //     optInTimePeriod1 = 7;
    // } else
    if (optInTimePeriod1 < 1) {
        throw new TAException(BadParam);
    }
    // INTEGER_DEFAULT
    // if(optInTimePeriod2 == null || ){
    //     optInTimePeriod2 = 14;
    // } else
    if (optInTimePeriod2 < 1) {
        throw new TAException(BadParam);
    }
    // INTEGER_DEFAULT
    // if(optInTimePeriod3 == null || ){
    //     optInTimePeriod3 = 28;
    // } else
    if (optInTimePeriod3 < 1) {
        throw new TAException(BadParam);
    }

    outBegIndex = 0;
    outNBElement = 0;

    periods[0] = optInTimePeriod1;
    periods[1] = optInTimePeriod2;
    periods[2] = optInTimePeriod3;
    usedFlag[0] = 0;
    usedFlag[1] = 0;
    usedFlag[2] = 0;

    i = 0;
    while (i < 3) {
        longestPeriod = 0;
        longestIndex = 0;

        j = 0;
        while (j < 3) {
            if ((usedFlag[j] == 0) && (periods[j] > longestPeriod)) {
                longestPeriod = periods[j];
                longestIndex = j;
            }

            ++j;
        }
        usedFlag[longestIndex] = 1;
        sortedPeriods[i] = longestPeriod;

        ++i;
    }
    optInTimePeriod1 = sortedPeriods[2];
    optInTimePeriod2 = sortedPeriods[1];
    optInTimePeriod3 = sortedPeriods[0];

    lookbackTotal = UltOscLookback(optInTimePeriod1, optInTimePeriod2, optInTimePeriod3);
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

    inline function CalcTerms(day:Int) {
        tempLT = inLow[day];
        tempHT = inHigh[day];
        tempCY = inClose[day - 1];
        trueLow = Math.min(tempLT, tempCY);
        closeMinusTrueLow = inClose[day] - trueLow;
        trueRange = tempHT - tempLT;
        tempDouble = Math.abs(tempCY - tempHT);
        if (tempDouble > trueRange) {
            trueRange = tempDouble;
        }
        tempDouble = Math.abs(tempCY - tempLT);
        if (tempDouble > trueRange) {
            trueRange = tempDouble;
        }
    }

    //    #define CALC_TERMS(day)                        \
    //    {                                              \
    //       tempLT = inLow[day];                        \
    //       tempHT = inHigh[day];                       \
    //       tempCY = inClose[day-1];                    \
    //       trueLow = min( tempLT, tempCY );            \
    //       closeMinusTrueLow = inClose[day] - trueLow; \
    //       trueRange = tempHT - tempLT;                \
    //       tempDouble = std_fabs( tempCY - tempHT );       \
    //       if( tempDouble > trueRange )                 \
    //          trueRange = tempDouble;                  \
    //       tempDouble = std_fabs( tempCY - tempLT  );      \
    //       if( tempDouble > trueRange )                 \
    //          trueRange = tempDouble;                  \
    //    }

    inline function PromeTotals(aTotal:Float, bTotal:Float, period:Int) {
        aTotal = 0;
        bTotal = 0;

        i = startIndex - period + 1;
        while (i < startIndex) {
            CalcTerms(i);
            aTotal += closeMinusTrueLow;
            bTotal += trueRange;

            ++i;
        }
    }

    //    #define PRIME_TOTALS(aTotal, bTotal, period)                 \
    //    {                                                            \
    //       aTotal = 0;                                               \
    //       bTotal = 0;                                               \
    //       for ( i = startIndex-period+1; i < startIndex; ++i )          \
    //       {                                                         \
    //          CALC_TERMS(i);                                         \
    //          aTotal += closeMinusTrueLow;                           \
    //          bTotal += trueRange;                                   \
    //       }                                                         \
    //    }

    PromeTotals(a1Total, b1Total, optInTimePeriod1);
    PromeTotals(a2Total, b2Total, optInTimePeriod2);
    PromeTotals(a3Total, b3Total, optInTimePeriod3);

    //    #undef PRIME_TOTALS

    today = startIndex;
    outIndex = 0;
    trailingIndex1 = today - optInTimePeriod1 + 1;
    trailingIndex2 = today - optInTimePeriod2 + 1;
    trailingIndex3 = today - optInTimePeriod3 + 1;
    while (today <= endIndex) {
        CalcTerms(today);
        a1Total += closeMinusTrueLow;
        a2Total += closeMinusTrueLow;
        a3Total += closeMinusTrueLow;
        b1Total += trueRange;
        b2Total += trueRange;
        b3Total += trueRange;

        output = 0.0;

        if (!IsZero(b1Total)) {
            output += 4.0 * (a1Total / b1Total);
        }
        if (!IsZero(b2Total)) {
            output += 2.0 * (a2Total / b2Total);
        }
        if (!IsZero(b3Total)) {
            output += a3Total / b3Total;
        }

        CalcTerms(trailingIndex1);
        a1Total -= closeMinusTrueLow;
        b1Total -= trueRange;

        CalcTerms(trailingIndex2);
        a2Total -= closeMinusTrueLow;
        b2Total -= trueRange;

        CalcTerms(trailingIndex3);
        a3Total -= closeMinusTrueLow;
        b3Total -= trueRange;

        outReal[outIndex] = 100.0 * (output / 7.0);

        outIndex++;
        today++;
        trailingIndex1++;
        trailingIndex2++;
        trailingIndex3++;
    }
    //    #undef CALC_TERMS

    outNBElement = outIndex;
    outBegIndex = startIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function UltOscLookback(optInTimePeriod1:Int, optInTimePeriod2:Int, optInTimePeriod3:Int) {
    var maxPeriod:Int;

    // INTEGER_DEFAULT
    // if(optInTimePeriod1 == null || ){
    //     optInTimePeriod1 = 7;
    // } else
    if (optInTimePeriod1 < 1) {
        return -1;
    }
    // INTEGER_DEFAULT
    // if(optInTimePeriod2 == null || ){
    //     optInTimePeriod2 = 14;
    // } else
    if (optInTimePeriod2 < 1) {
        return -1;
    }
    // INTEGER_DEFAULT
    // if(optInTimePeriod3 == null || ){
    //     optInTimePeriod3 = 28;
    // } else
    if (optInTimePeriod3 < 1) {
        return -1;
    }

    // maxPeriod = Math.max(Math.max(optInTimePeriod1, optInTimePeriod2), optInTimePeriod3);
    maxPeriod = (optInTimePeriod1 > optInTimePeriod2) ? optInTimePeriod1 : optInTimePeriod2;
    maxPeriod = (maxPeriod > optInTimePeriod3) ? maxPeriod : optInTimePeriod3;
    return (SmaLookback(maxPeriod) + 1);
}
