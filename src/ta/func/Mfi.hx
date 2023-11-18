package ta.func;

import ta.Globals.FuncUnstId;

@:keep
function Mfi(startIndex:Int, endIndex:Int, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>, inVolume:Array<Float>, optInTimePeriod:Int) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var posSumMF:Float, negSumMF:Float, prevValue:Float;
    var tempValue1:Float, tempValue2:Float;
    var lookbackTotal:Int, outIndex:Int, i:Int, today:Int;

    // MoneyFlow local_mflow[50]; int mflow_Index; MoneyFlow* mflow; int maxIndex_mflow;
    // var local_mflow:Array<MoneyFlow>; // Size: 50
    var mflow_Index:Int;
    var mflow:Array<MoneyFlow>; // Must be initialized
    var maxIndex_mflow:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inHigh == null || inLow == null || inClose == null || inVolume == null) {
        throw new TAException(BadParam);
    }
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
        throw new TAException(BadParam);
    }

    // CIRCBUF_INIT_CLASS(mflow, MoneyFlow, optInTimePeriod);

    if (optInTimePeriod < 1) {
        throw new TAException(InternalError, "Id:137"); // return ((TA_RetCode)(TA_INTERNAL_ERROR + 137));
    }
    // if ((int) optInTimePeriod > (int)(sizeof(local_mflow) / sizeof(MoneyFlow))) {
    //     mflow = malloc(sizeof(MoneyFlow) * optInTimePeriod);
    //     if (!mflow)
    //         return TA_ALLOC_ERR;
    // } else
    //     mflow = & local_mflow[0];
    mflow = [for (_ in 0...optInTimePeriod) new MoneyFlow()];
    maxIndex_mflow = (optInTimePeriod - 1);
    mflow_Index = 0;

    outBegIndex = 0;
    outNBElement = 0;

    lookbackTotal = optInTimePeriod + Globals.unstablePeriod[FuncUnstId.Mfi];

    if (startIndex < lookbackTotal) {
        startIndex = lookbackTotal;
    }

    if (startIndex > endIndex) {
        // CIRCBUF_DESTROY(mflow);
        // { if (mflow != &local_mflow[0]) free(mflow); }
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    outIndex = 0;
    today = startIndex - lookbackTotal;
    prevValue = (inHigh[today] + inLow[today] + inClose[today]) / 3.0;

    posSumMF = 0.0;
    negSumMF = 0.0;
    today++;

    i = optInTimePeriod;
    while (i > 0) {
        tempValue1 = (inHigh[today] + inLow[today] + inClose[today]) / 3.0;
        tempValue2 = tempValue1 - prevValue;
        prevValue = tempValue1;
        tempValue1 *= inVolume[today++];
        if (tempValue2 < 0) {
            mflow[mflow_Index].negative = tempValue1;
            negSumMF += tempValue1;
            mflow[mflow_Index].positive = 0.0;
        } else if (tempValue2 > 0) {
            mflow[mflow_Index].positive = tempValue1;
            posSumMF += tempValue1;
            mflow[mflow_Index].negative = 0.0;
        } else {
            mflow[mflow_Index].positive = 0.0;
            mflow[mflow_Index].negative = 0.0;
        }

        // CIRCBUF_NEXT(mflow);
        // mflow_Index++;
        // if (mflow_Index > maxIndex_mflow)
        //     mflow_Index = 0;
        mflow_Index++;
        if (mflow_Index > maxIndex_mflow) {
            mflow_Index = 0;
        }

        i--;
    }

    if (today > startIndex) {
        tempValue1 = posSumMF + negSumMF;
        if (tempValue1 < 1.0) {
            outReal[outIndex++] = 0.0;
        } else {
            outReal[outIndex++] = 100.0 * (posSumMF / tempValue1);
        }
    } else {
        while (today < startIndex) {
            posSumMF -= mflow[mflow_Index].positive;
            negSumMF -= mflow[mflow_Index].negative;

            tempValue1 = (inHigh[today] + inLow[today] + inClose[today]) / 3.0;
            tempValue2 = tempValue1 - prevValue;
            prevValue = tempValue1;
            tempValue1 *= inVolume[today++];
            if (tempValue2 < 0) {
                mflow[mflow_Index].negative = tempValue1;
                negSumMF += tempValue1;
                mflow[mflow_Index].positive = 0.0;
            } else if (tempValue2 > 0) {
                mflow[mflow_Index].positive = tempValue1;
                posSumMF += tempValue1;
                mflow[mflow_Index].negative = 0.0;
            } else {
                mflow[mflow_Index].positive = 0.0;
                mflow[mflow_Index].negative = 0.0;
            }

            // CIRCBUF_NEXT(mflow);
            // mflow_Index++;
            // if (mflow_Index > maxIndex_mflow)
            //     {mflow_Index = 0;}
            mflow_Index++;
            if (mflow_Index > maxIndex_mflow) {
                mflow_Index = 0;
            }
        }
    }

    while (today <= endIndex) {
        posSumMF -= mflow[mflow_Index].positive;
        negSumMF -= mflow[mflow_Index].negative;

        tempValue1 = (inHigh[today] + inLow[today] + inClose[today]) / 3.0;
        tempValue2 = tempValue1 - prevValue;
        prevValue = tempValue1;
        tempValue1 *= inVolume[today++];
        if (tempValue2 < 0) {
            mflow[mflow_Index].negative = tempValue1;
            negSumMF += tempValue1;
            mflow[mflow_Index].positive = 0.0;
        } else if (tempValue2 > 0) {
            mflow[mflow_Index].positive = tempValue1;
            posSumMF += tempValue1;
            mflow[mflow_Index].negative = 0.0;
        } else {
            mflow[mflow_Index].positive = 0.0;
            mflow[mflow_Index].negative = 0.0;
        }

        tempValue1 = posSumMF + negSumMF;
        if (tempValue1 < 1.0) {
            outReal[outIndex++] = 0.0;
        } else {
            outReal[outIndex++] = 100.0 * (posSumMF / tempValue1);
        }

        // CIRCBUF_NEXT(mflow);
        // mflow_Index++;
        // if (mflow_Index > maxIndex_mflow)
        //     mflow_Index = 0;
        mflow_Index++;
        if (mflow_Index > maxIndex_mflow) {
            mflow_Index = 0;
        }
    }

    // CIRCBUF_DESTROY(mflow);
    // { if (mflow != &local_mflow[0]) free(mflow); }

    outBegIndex = startIndex;
    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

class MoneyFlow {
    public var positive:Float;
    public var negative:Float;

    public function new() {}
}

@:keep
function MfiLookback(optInTimePeriod:Int):Int {
    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 14;
    // } else
    if (optInTimePeriod < 2) {
        return -1;
    }

    return (optInTimePeriod + Globals.unstablePeriod[FuncUnstId.Mfi]);
}
