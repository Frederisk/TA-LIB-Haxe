package ta.func;

import ta.func.Utility.IsZero;

@:keep
function Beta(startIndex:Int, endIndex:Int, inReal0:Array<Float>, inReal1:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var S_xx = 0.0, S_xy = 0.0, S_x = 0.0, S_y = 0.0;
    var last_price_x = 0.0, last_price_y = 0.0;
    var trailing_last_price_x = 0.0, trailing_last_price_y = 0.0;
    var tmp_real = 0.0;
    var x:Float, y:Float;
    var n = 0.0;
    var i:Int, outIndex:Int;
    var trailingIndex:Int, nbInitialElementNeeded:Int;

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
    //     optInTimePeriod = 5;
    // } else
    if (optInTimePeriod < 1) {
        throw new TAException(BadParam);
    }

    nbInitialElementNeeded = optInTimePeriod;

    if (startIndex < nbInitialElementNeeded) {
        startIndex = nbInitialElementNeeded;
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

    trailingIndex = startIndex - nbInitialElementNeeded;
    last_price_x = trailing_last_price_x = inReal0[trailingIndex];
    last_price_y = trailing_last_price_y = inReal1[trailingIndex];

    i = ++trailingIndex;

    while (i < startIndex) {
        tmp_real = inReal0[i];
        if (!IsZero(last_price_x)) {
            x = (tmp_real - last_price_x) / last_price_x;
        } else {
            x = 0.0;
        }
        last_price_x = tmp_real;

        tmp_real = inReal1[i++];
        if (!IsZero(last_price_y)) {
            y = (tmp_real - last_price_y) / last_price_y;
        } else {
            y = 0.0;
        }
        last_price_y = tmp_real;

        S_xx += x * x;
        S_xy += x * y;
        S_x += x;
        S_y += y;
    }

    outIndex = 0;
    n = optInTimePeriod;
    do {
        tmp_real = inReal0[i];
        if (!IsZero(last_price_x)) {
            x = (tmp_real - last_price_x) / last_price_x;
        } else {
            x = 0.0;
        }
        last_price_x = tmp_real;

        tmp_real = inReal1[i++];
        if (!IsZero(last_price_y)) {
            y = (tmp_real - last_price_y) / last_price_y;
        } else {
            y = 0.0;
        }
        last_price_y = tmp_real;

        S_xx += x * x;
        S_xy += x * y;
        S_x += x;
        S_y += y;

        tmp_real = inReal0[trailingIndex];
        if (!IsZero(trailing_last_price_x)) {
            x = (tmp_real - trailing_last_price_x) / trailing_last_price_x;
        } else {
            x = 0.0;
        }
        trailing_last_price_x = tmp_real;

        tmp_real = inReal1[trailingIndex++];
        if (!IsZero(trailing_last_price_y)) {
            y = (tmp_real - trailing_last_price_y) / trailing_last_price_y;
        } else {
            y = 0.0;
        }
        trailing_last_price_y = tmp_real;

        tmp_real = (n * S_xx) - (S_x * S_x);
        if (!IsZero(tmp_real)) {
            outReal[outIndex++] = ((n * S_xy) - (S_x * S_y)) / tmp_real;
        } else {
            outReal[outIndex++] = 0.0;
        }

        S_xx -= x * x;
        S_xy -= x * y;
        S_x -= x;
        S_y -= y;
    } while (i <= endIndex);

    outBegIndex = startIndex;
    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function BetaLookback(optInTimePeriod:Int) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 5;
    // } else
    if (optInTimePeriod < 1) {
        return -1;
    }
    return (optInTimePeriod);
}
