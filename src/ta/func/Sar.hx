package ta.func;

import ta.func.MinusDm;

@:keep
function Sar(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, optInAcceleration:Float, optInMaximum:Float) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    // var ret: Any;
    var ret;
    var isLong:Int;
    var todayIndex:Int, outIndex:Int;

    // var tempInt:Int; // Unused variable

    var newHigh:Float, newLow:Float, prevHigh:Float, prevLow:Float;
    var af:Float, ep:Float, sar:Float;
    var ep_temp:Array<Float>; // No initialization required

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inHigh == null || inLow == null) {
        throw new TAException(BadParam);
    }
    // REAL_DEFAULT
    // if(optInAcceleration == null || ){
    //     optInAcceleration = 2.000000e-2;
    // } else
    if (optInAcceleration < 0.0) {
        throw new TAException(BadParam);
    }
    // REAL_DEFAULT
    // if(optInMaximum == null || ){
    //     optInMaximum = 2.000000e-1;
    // } else
    if (optInMaximum < 0.0) {
        throw new TAException(BadParam);
    }

    if (startIndex < 1) {
        startIndex = 1;
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

    af = optInAcceleration;
    if (af > optInMaximum) {
        af = optInAcceleration = optInMaximum;
    }

    // retCode = FUNCTION_CALL(MINUS_DM)(startIndex, startIndex, inHigh, inLow, 1, VALUE_HANDLE_OUT(tempInt), VALUE_HANDLE_OUT(tempInt), ep_temp);
    ret = MinusDm(startIndex, startIndex, inHigh, inLow, 1);
    // var tempInt = ret.outBegIndex;
    // var tempInt = ret.outNBElement;
    ep_temp = ret.outReal;

    if (ep_temp[0] > 0) {
        isLong = 0;
    } else {
        isLong = 1;
    }

    // if (retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success)) {
    //     VALUE_HANDLE_DEREF_TO_ZERO(outBegIndex);
    //     VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
    //     return retCode;
    // }

    outBegIndex = startIndex;
    outIndex = 0;

    todayIndex = startIndex;

    newHigh = inHigh[todayIndex - 1];
    newLow = inLow[todayIndex - 1];

    // SAR_ROUNDING(newHigh);
    // SAR_ROUNDING(newLow);

    if (isLong == 1) {
        ep = inHigh[todayIndex];
        sar = newLow;
    } else {
        ep = inLow[todayIndex];
        sar = newHigh;
    }

    // SAR_ROUNDING(sar);

    newLow = inLow[todayIndex];
    newHigh = inHigh[todayIndex];

    while (todayIndex <= endIndex) {
        prevLow = newLow;
        prevHigh = newHigh;
        newLow = inLow[todayIndex];
        newHigh = inHigh[todayIndex];
        todayIndex++;

        // SAR_ROUNDING(newLow);
        // SAR_ROUNDING(newHigh);

        if (isLong == 1) {
            if (newLow <= sar) {
                isLong = 0;
                sar = ep;

                if (sar < prevHigh) {
                    sar = prevHigh;
                }
                if (sar < newHigh) {
                    sar = newHigh;
                }

                outReal[outIndex++] = sar;

                af = optInAcceleration;
                ep = newLow;

                sar = sar + af * (ep - sar);
                // SAR_ROUNDING(sar);

                if (sar < prevHigh) {
                    sar = prevHigh;
                }
                if (sar < newHigh) {
                    sar = newHigh;
                }
            } else {
                outReal[outIndex++] = sar;

                if (newHigh > ep) {
                    ep = newHigh;
                    af += optInAcceleration;
                    if (af > optInMaximum) {
                        af = optInMaximum;
                    }
                }

                sar = sar + af * (ep - sar);
                // SAR_ROUNDING(sar);

                if (sar > prevLow) {
                    sar = prevLow;
                }
                if (sar > newLow) {
                    sar = newLow;
                }
            }
        } else {
            if (newHigh >= sar) {
                isLong = 1;
                sar = ep;

                if (sar > prevLow) {
                    sar = prevLow;
                }
                if (sar > newLow) {
                    sar = newLow;
                }

                outReal[outIndex++] = sar;

                af = optInAcceleration;
                ep = newHigh;

                sar = sar + af * (ep - sar);
                // SAR_ROUNDING(sar);

                if (sar > prevLow) {
                    sar = prevLow;
                }
                if (sar > newLow) {
                    sar = newLow;
                }
            } else {
                outReal[outIndex++] = sar;

                if (newLow < ep) {
                    ep = newLow;
                    af += optInAcceleration;
                    if (af > optInMaximum) {
                        af = optInMaximum;
                    }
                }

                sar = sar + af * (ep - sar);
                // SAR_ROUNDING(sar);

                if (sar < prevHigh) {
                    sar = prevHigh;
                }
                if (sar < newHigh) {
                    sar = newHigh;
                }
            }
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
function SarLookback(optInAcceleration:Float, optInMaximum:Float):Int {
    // REAL_DEFAULT
    // if(optInAcceleration == null || ){
    //     optInAcceleration = 2.000000e-2;
    // } else
    if (optInAcceleration < 0.0) {
        return -1;
    }
    // REAL_DEFAULT
    // if(optInMaximum == null || ){
    //     optInMaximum = 2.000000e-1;
    // } else
    if (optInMaximum < 0.0) {
        return -1;
    }

    optInAcceleration;
    optInMaximum;

    return 1;
}
/*SAR_ROUNDING is just for test purpose when cross-referencing that
 * function with example from Wilder's book. Wilder is using two
 * decimal rounding for simplification. TA-Lib does not round.
 */
/* #define SAR_ROUNDING(x) x=round_pos_2(x) */
// #define SAR_ROUNDING(x)
