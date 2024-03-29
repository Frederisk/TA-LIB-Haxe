package ta.func;

import ta.func.Sma.IntSma;
import ta.func.TRange;
import ta.Globals.FuncUnstId;

@:keep
function Atr(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var ret;
    var outIndex:Int, today:Int, lookbackTotal:Int;
    var nbATR:Int;
    var outBegIndex1:Int;
    var outNbElement1:Int;
    var prevATR:Float;
    var tempBuffer:Array<Float>; // No initialization required
    // var prevATRTemp:Array<Float> = [0.0]; // size: 1
    var prevATRTemp:Array<Float>; // No initialization required

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
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 1) {
        throw new TAException(BadParam);
    }

    outBegIndex = 0;
    outNBElement = 0;

    lookbackTotal = AtrLookback(optInTimePeriod);

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

    if (optInTimePeriod <= 1) {
        return TRange(startIndex, endIndex, inHigh, inLow, inClose);
    }

    // tempBuffer = [for (0...(lookbackTotal + (endIndex - startIndex) + 1)) 0.0];
    ret = TRange((startIndex - lookbackTotal + 1), endIndex, inHigh, inLow, inClose);

    outBegIndex1 = ret.outBegIndex;
    outNbElement1 = ret.outNBElement;
    tempBuffer = ret.outReal;

    // if (retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success)) {
    //     ARRAY_FREE(tempBuffer);
    //     return retCode;
    // }

    ret = IntSma(optInTimePeriod - 1, optInTimePeriod - 1, tempBuffer, optInTimePeriod);

    outBegIndex1 = ret.outBegIndex;
    outNbElement1 = ret.outNBElement;
    prevATRTemp = ret.outReal;

    // if (retCode != ENUM_VALUE(RetCode, TA_SUCCESS, Success)) {
    //     ARRAY_FREE(tempBuffer);
    //     return retCode;
    // }
    prevATR = prevATRTemp[0];

    today = optInTimePeriod;
    outIndex = Globals.unstablePeriod[FuncUnstId.Atr];
    while (outIndex != 0) {
        prevATR *= optInTimePeriod - 1;
        prevATR += tempBuffer[today++];
        prevATR /= optInTimePeriod;
        outIndex--;
    }

    outIndex = 1;
    outReal[0] = prevATR;

    nbATR = (endIndex - startIndex) + 1;

    while (--nbATR != 0) {
        prevATR *= optInTimePeriod - 1;
        prevATR += tempBuffer[today++];
        prevATR /= optInTimePeriod;
        outReal[outIndex++] = prevATR;
    }

    outBegIndex = startIndex;
    outNBElement = outIndex;

    // ARRAY_FREE(tempBuffer);

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function AtrLookback(optInTimePeriod:Int):Int {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 1) {
        return -1;
    }
    return (optInTimePeriod + Globals.unstablePeriod[FuncUnstId.Atr]);
}
