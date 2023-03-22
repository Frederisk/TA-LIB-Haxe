package ta.func;

@:keep
function Cci(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var tempReal:Float, tempReal2:Float, theAverage:Float, lastValue:Float;
    var i:Int, j:Int, outIndex:Int, lookbackTotal:Int;

    // CIRCBUF_PROLOG(circBuffer, double, 30);
    // var local_circBuffer:Array<Float>;
    var circBuffer_Index:Int;
    var circBuffer:Array<Float> = [];
    var maxIndex_circBuffer:Int;

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
    if (optInTimePeriod < 2) {
        throw new TAException(BadParam);
    }

    lookbackTotal = (optInTimePeriod - 1);

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

    // CIRCBUF_INIT(circBuffer, double, optInTimePeriod);
    if (optInTimePeriod < 1) {
        throw new TAException(InternalError, "Id:137"); // return ((TA_RetCode)(TA_INTERNAL_ERROR + 137));
    }
    // if (optInTimePeriod > local_circBuffer.length) {
    //     circBuffer = malloc(sizeof(double) * optInTimePeriod);
    //     if (circBuffer == null) {
    //         return TA_ALLOC_ERR;
    //     }
    // } else {
    //     circBuffer = & local_circBuffer[0];
    // }
    maxIndex_circBuffer = (optInTimePeriod - 1);
    circBuffer_Index = 0;

    i = startIndex - lookbackTotal;
    if (optInTimePeriod > 1) {
        while (i < startIndex) {
            circBuffer[circBuffer_Index] = (inHigh[i] + inLow[i] + inClose[i]) / 3;
            i++;

            // CIRCBUF_NEXT(circBuffer);
            circBuffer_Index++;
            if (circBuffer_Index > maxIndex_circBuffer) {
                circBuffer_Index = 0;
            }
        }
    }

    outIndex = 0;
    do {
        lastValue = (inHigh[i] + inLow[i] + inClose[i]) / 3;
        circBuffer[circBuffer_Index] = lastValue;

        theAverage = 0;
        j = 0;
        while (j < optInTimePeriod) {
            theAverage += circBuffer[j];
            j++;
        }
        theAverage /= optInTimePeriod;

        tempReal2 = 0;
        j = 0;
        while (j < optInTimePeriod) {
            tempReal2 += Math.abs(circBuffer[j] - theAverage);
            j++;
        }

        tempReal = lastValue - theAverage;

        if ((tempReal != 0.0) && (tempReal2 != 0.0)) {
            outReal[outIndex++] = tempReal / (0.015 * (tempReal2 / optInTimePeriod));
        } else {
            outReal[outIndex++] = 0.0;
        }

        // CIRCBUF_NEXT(circBuffer);
        circBuffer_Index++;
        if (circBuffer_Index > maxIndex_circBuffer) {
            circBuffer_Index = 0;
        }

        i++;
    } while (i <= endIndex);

    outNBElement = outIndex;
    outBegIndex = startIndex;

    // CIRCBUF_DESTROY(circBuffer);
    // if (circBuffer != &local_circBuffer[0]) {free(circBuffer);}

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function CciLookback(optInTimePeriod:Int) {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }

    return (optInTimePeriod - 1);
}
