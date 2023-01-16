package ta.func;

@:keep
function LinearReg(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var outIndex:Int;
    var today:Int, lookbackTotal:Int;
    var SumX:Float, SumXY:Float, SumY:Float, SumXSqr:Float, Divisor:Float;
    var m:Float, b:Float;
    var i:Int;
    var tempValue1:Float;

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
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
        throw new TAException(BadParam);
    }

    lookbackTotal = LinearRegLookback(optInTimePeriod);

    if (startIndex < lookbackTotal) {
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

    outIndex = 0;
    today = startIndex;

    SumX = optInTimePeriod * (optInTimePeriod - 1) * 0.5;
    SumXSqr = optInTimePeriod * (optInTimePeriod - 1) * (2 * optInTimePeriod - 1) / 6;
    Divisor = SumX * SumX - optInTimePeriod * SumXSqr;

    while (today <= endIndex) {
        SumXY = 0;
        SumY = 0;
        i = optInTimePeriod;
        while (i-- != 0) {
            SumY += tempValue1 = inReal[today - i];
            SumXY += i * tempValue1;
        }
        m = (optInTimePeriod * SumXY - SumX * SumY) / Divisor;
        b = (SumY - m * SumX) / optInTimePeriod;
        outReal[outIndex++] = b + m * (optInTimePeriod - 1);
        today++;
    }

    outBegIndex = startIndex;
    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function LinearRegLookback(optInTimePeriod:Int) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }
    return (optInTimePeriod - 1);
}
