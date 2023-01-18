package ta.func;

import ta.Globals.Compatibility;
import ta.func.Utility.PerToK;
import ta.Globals.FuncUnstId;

@:keep
function Ema(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
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

    return IntEma(startIndex, endIndex, inReal, optInTimePeriod, PerToK(optInTimePeriod));
}

@:keep
function IntEma(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int, optInK_1:Float) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var tempReal:Float, prevMA:Float;
    var i:Int, today:Int, outIndex:Int, lookbackTotal:Int;

    lookbackTotal = EmaLookback(optInTimePeriod);

    if (startIndex < lookbackTotal)
        {startIndex = lookbackTotal;}

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


    if (Globals.compatibility == Compatibility.Default) {
        today = startIndex - lookbackTotal;
        i = optInTimePeriod;
        tempReal = 0.0;
        while (i-- > 0) {
            tempReal += inReal[today++];
        }

        prevMA = tempReal / optInTimePeriod;
    } else {
        prevMA = inReal[0];
        today = 1;
    }

    while (today <= startIndex) {
        prevMA = ((inReal[today++] - prevMA) * optInK_1) + prevMA;
    }

    outReal[0] = prevMA;
    outIndex = 1;

    while (today <= endIndex) {
        prevMA = ((inReal[today++] - prevMA) * optInK_1) + prevMA;
        outReal[outIndex++] = prevMA;
    }

    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function EmaLookback(optInTimePeriod:Int) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }
    return (optInTimePeriod - 1 + Globals.unstablePeriod[FuncUnstId.Ema]);
}
