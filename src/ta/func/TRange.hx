package ta.func;

@:keep
function TRange(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var today:Int, outIndex:Int;
    var val2:Float, val3:Float, greatest:Float;
    var tempCY:Float, tempLT:Float, tempHT:Float;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inHigh == null || inLow == null || inClose == null) {
        throw new TAException(BadParam);
    }

    if (startIndex < 1)
        {startIndex = 1;}

    if (startIndex > endIndex) {
        outBegIndex =0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    outIndex = 0;
    today = startIndex;
    while (today <= endIndex) {
        tempLT = inLow[today];
        tempHT = inHigh[today];
        tempCY = inClose[today - 1];
        greatest = tempHT - tempLT;

        val2 = Math.abs(tempCY - tempHT);
        if (val2 > greatest)
            greatest = val2;

        val3 = Math.abs(tempCY - tempLT);
        if (val3 > greatest)
            greatest = val3;

        outReal[outIndex++] = greatest;
        today++;
    }

    outNBElement = outIndex;
    outBegIndex = startIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function TRangeLookback() {
    return 1;
}