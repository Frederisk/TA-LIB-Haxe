package ta.func;

import ta.func.MinusDm;

@:keep
function SarExt(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, optInStartValue:Float, optInOffsetOnReverse:Float,
        optInAccelerationInitLong:Float, optInAccelerationLong:Float, optInAccelerationMaxLong:Float, optInAccelerationInitShort:Float,
        optInAccelerationShort:Float, optInAccelerationMaxShort:Float) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var ret;
    var isLong:Int;
    var todayIndex:Int, outIndex:Int;
    var tempInt:Int;
    var newHigh:Float, newLow:Float, prevHigh:Float, prevLow:Float;
    var afLong:Float, afShort:Float, ep:Float, sar:Float;

    var ep_temp:Array<Float>; // TODO: = [0];
    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inHigh == null || inLow == null) {
        throw new TAException(BadParam);
    }
    // DEFAULT && RANGE
    // optInStartValue = 0
    // optInOffsetOnReverse = 0
    if (optInOffsetOnReverse < 0) {
        throw new TAException(BadParam);
    }
    // optInAccelerationInitLong = 0.02
    if (optInAccelerationInitLong < 0) {
        throw new TAException(BadParam);
    }
    // optInAccelerationLong = 0.02
    if (optInAccelerationLong < 0) {
        throw new TAException(BadParam);
    }
    // optInAccelerationMaxLong = 0.2
    if (optInAccelerationMaxLong < 0) {
        throw new TAException(BadParam);
    }
    // optInAccelerationInitShort = 0.02
    if (optInAccelerationInitShort < 0) {
        throw new TAException(BadParam);
    }
    // optInAccelerationShort = 0.02
    if (optInAccelerationShort < 0) {
        throw new TAException(BadParam);
    }
    // optInAccelerationMaxShort = 0.2
    if (optInAccelerationMaxShort < 0) {
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

    afLong = optInAccelerationInitLong;
    afShort = optInAccelerationInitShort;

    if (afLong > optInAccelerationMaxLong) {
        afLong = optInAccelerationInitLong = optInAccelerationMaxLong;
    }

    if (optInAccelerationLong > optInAccelerationMaxLong) {
        optInAccelerationLong = optInAccelerationMaxLong;
    }

    if (afShort > optInAccelerationMaxShort) {
        afShort = optInAccelerationInitShort = optInAccelerationMaxShort;
    }

    if (optInAccelerationShort > optInAccelerationMaxShort) {
        optInAccelerationShort = optInAccelerationMaxShort;
    }

    if (optInStartValue == 0) {
        ret = MinusDm(startIndex, startIndex, inHigh, inLow, 1);
        tempInt = ret.outBegIndex;
        tempInt = ret.outNBElement;
        ep_temp = ret.outReal;
        // retCode = FUNCTION_CALL(MINUS_DM)(startIndex, startIndex, inHigh, inLow, 1, VALUE_HANDLE_OUT(tempInt), VALUE_HANDLE_OUT(tempInt), ep_temp);
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
    } else if (optInStartValue > 0) {
        isLong = 1;
    } else {
        isLong = 0;
    }

    outBegIndex = startIndex;
    outIndex = 0;

    todayIndex = startIndex;

    newHigh = inHigh[todayIndex - 1];
    newLow = inLow[todayIndex - 1];

    // SAR_ROUNDING(newHigh);
    // SAR_ROUNDING(newLow);

    if (optInStartValue == 0) {
        if (isLong == 1) {
            ep = inHigh[todayIndex];
            sar = newLow;
        } else {
            ep = inLow[todayIndex];
            sar = newHigh;
        }
    } else if (optInStartValue > 0) {
        ep = inHigh[todayIndex];
        sar = optInStartValue;
    } else {
        ep = inLow[todayIndex];
        sar = Math.abs(optInStartValue);
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

                if (optInOffsetOnReverse != 0.0) {
                    sar += sar * optInOffsetOnReverse;
                }
                outReal[outIndex++] = -sar;

                afShort = optInAccelerationInitShort;
                ep = newLow;

                sar = sar + afShort * (ep - sar);
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
                    afLong += optInAccelerationLong;
                    if (afLong > optInAccelerationMaxLong) {
                        afLong = optInAccelerationMaxLong;
                    }
                }

                sar = sar + afLong * (ep - sar);
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

                if (optInOffsetOnReverse != 0.0) {
                    sar -= sar * optInOffsetOnReverse;
                }
                outReal[outIndex++] = sar;

                afLong = optInAccelerationInitLong;
                ep = newHigh;

                sar = sar + afLong * (ep - sar);
                // SAR_ROUNDING(sar);

                if (sar > prevLow) {
                    sar = prevLow;
                }
                if (sar > newLow) {
                    sar = newLow;
                }
            } else {
                outReal[outIndex++] = -sar;

                if (newLow < ep) {
                    ep = newLow;
                    afShort += optInAccelerationShort;
                    if (afShort > optInAccelerationMaxShort) {
                        afShort = optInAccelerationMaxShort;
                    }
                }

                sar = sar + afShort * (ep - sar);
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
function SarExtLookback(optInStartValue:Float, optInOffsetOnReverse:Float, optInAccelerationInitLong:Float, optInAccelerationLong:Float,
        optInAccelerationMaxLong:Float, optInAccelerationInitShort:Float, optInAccelerationShort:Float, optInAccelerationMaxShort:Float) {
    // DEFAULT && RANGE
    // optInStartValue = 0
    // optInOffsetOnReverse = 0
    if (optInOffsetOnReverse < 0) {
        return -1;
    }
    // optInAccelerationInitLong = 0.02
    if (optInAccelerationInitLong < 0) {
        return -1;
    }
    // optInAccelerationLong = 0.02
    if (optInAccelerationLong < 0) {
        return -1;
    }
    // optInAccelerationMaxLong = 0.2
    if (optInAccelerationMaxLong < 0) {
        return -1;
    }
    // optInAccelerationInitShort = 0.02
    if (optInAccelerationInitShort < 0) {
        return -1;
    }
    // optInAccelerationShort = 0.02
    if (optInAccelerationShort < 0) {
        return -1;
    }
    // optInAccelerationMaxShort = 0.2
    if (optInAccelerationMaxShort < 0) {
        return -1;
    }

    optInStartValue;
    optInOffsetOnReverse;
    optInAccelerationInitLong;
    optInAccelerationLong;
    optInAccelerationMaxLong;
    optInAccelerationInitShort;
    optInAccelerationShort;
    optInAccelerationMaxShort;
    return 1;
}
