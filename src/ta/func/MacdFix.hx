package ta.func;

import ta.func.Macd.IntMacd;
import ta.func.Ema.EmaLookback;

@:keep
function MacdFix(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInSignalPeriod:Int) {
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
    // if(optInSignalPeriod == null || ){
    //     optInSignalPeriod = 9;
    // } else
    if (optInSignalPeriod < 1) {
        throw new TAException(BadParam);
    }

    return IntMacd(startIndex, endIndex, inReal, 0, 0, optInSignalPeriod);
}

@:keep
function MacdFixLookback(optInSignalPeriod:Int) {
    // INTEGER_DEFAULT
    // if(optInSignalPeriod == null || ){
    //     optInSignalPeriod = 9;
    // } else
    if (optInSignalPeriod < 1) {
        return -1;
    }

    return (EmaLookback(26) + EmaLookback(optInSignalPeriod));
}
