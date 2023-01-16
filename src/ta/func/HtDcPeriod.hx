package ta.func;

import ta.Globals.FuncUnstId;

@:keep
function HtDcPeriod(startIndex:Int, endIndex:Int, inReal:Array<Float>):{outBegIndex:Int, outNBElement:Int, outReal:Array<Float>} {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var outIndex:Int, i:Int;
    var lookbackTotal:Int, today:Int;
    var tempReal:Float, tempReal2:Float;
    var adjustedPrevPeriod:Float, period:Float;
    var trailingWMAIndex:Int;
    var periodWMASum:Float, periodWMASub:Float, trailingWMAValue:Float;
    var smoothedValue:Float;

    var a = 0.0962;
    var b = 0.5769;
    var hilbertTempReal:Float;
    var hilbertIndex:Int;

    // HILBERT_VARIABLES(detrender);
    var detrender_Odd:Array<Float> = [0.0, 0.0, 0.0]; // size: 3
    var detrender_Even:Array<Float> = [0.0, 0.0, 0.0]; // size: 3
    var detrender:Float;
    var prev_detrender_Odd:Float;
    var prev_detrender_Even:Float;
    var prev_detrender_input_Odd:Float;
    var prev_detrender_input_Even:Float;

    // HILBERT_VARIABLES(Q1);
    var Q1_Odd:Array<Float> = [0.0, 0.0, 0.0]; // size: 3
    var Q1_Even:Array<Float> = [0.0, 0.0, 0.0]; // size: 3
    var Q1:Float;
    var prev_Q1_Odd:Float;
    var prev_Q1_Even:Float;
    var prev_Q1_input_Odd:Float;
    var prev_Q1_input_Even:Float;

    // HILBERT_VARIABLES(jI);
    var jI_Odd:Array<Float> = [0.0, 0.0, 0.0]; // size: 3
    var jI_Even:Array<Float> = [0.0, 0.0, 0.0]; // size: 3
    var jI:Float;
    var prev_jI_Odd:Float;
    var prev_jI_Even:Float;
    var prev_jI_input_Odd:Float;
    var prev_jI_input_Even:Float;

    // HILBERT_VARIABLES(jQ);
    var jQ_Odd:Array<Float> = [0.0, 0.0, 0.0]; // size: 3
    var jQ_Even:Array<Float> = [0.0, 0.0, 0.0]; // size: 3
    var jQ:Float;
    var prev_jQ_Odd:Float;
    var prev_jQ_Even:Float;
    var prev_jQ_input_Odd:Float;
    var prev_jQ_input_Even:Float;

    var Q2:Float, I2:Float, prevQ2:Float, prevI2:Float, Re:Float, Im:Float;

    var I1ForOddPrev2:Float, I1ForOddPrev3:Float;
    var I1ForEvenPrev2:Float, I1ForEvenPrev3:Float;

    var rad2Deg:Float;

    var todayValue:Float, smoothPeriod:Float;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inReal == null) {
        throw new TAException(BadParam);
    }

    rad2Deg = 180.0 / (4.0 * Math.atan(1));

    lookbackTotal = 32 + Globals.unstablePeriod[FuncUnstId.HtDcPeriod];

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

    outBegIndex = startIndex;

    trailingWMAIndex = startIndex - lookbackTotal;
    today = trailingWMAIndex;

    tempReal = inReal[today++];
    periodWMASub = tempReal;
    periodWMASum = tempReal;
    tempReal = inReal[today++];
    periodWMASub += tempReal;
    periodWMASum += tempReal * 2.0;
    tempReal = inReal[today++];
    periodWMASub += tempReal;
    periodWMASum += tempReal * 3.0;

    trailingWMAValue = 0.0;

    // DO_PRICE_WMA(varNewPrice, varToStoreSmoothedValue) :
    //     periodWMASub += #1#;
    //     periodWMASub -= trailingWMAValue;
    //     periodWMASum += #1# * 4.0;
    //     trailingWMAValue = inReal[trailingWMAIndex++];
    //     #2# = periodWMASum * 0.1;
    //     periodWMASum -= periodWMASub;

    i = 9;
    do {
        tempReal = inReal[today++];
        // DO_PRICE_WMA(tempReal, smoothedValue);
        periodWMASub += tempReal;
        periodWMASub -= trailingWMAValue;
        periodWMASum += tempReal * 4.0;
        trailingWMAValue = inReal[trailingWMAIndex++];
        smoothedValue = periodWMASum * 0.1;
        periodWMASum -= periodWMASub;
    } while (--i != 0);

    hilbertIndex = 0;

    // INIT_HILBERT_VARIABLES(detrender);
    detrender_Odd[0] = 0.0;
    detrender_Odd[1] = 0.0;
    detrender_Odd[2] = 0.0;
    detrender_Even[0] = 0.0;
    detrender_Even[1] = 0.0;
    detrender_Even[2] = 0.0;
    detrender = 0.0;
    prev_detrender_Odd = 0.0;
    prev_detrender_Even = 0.0;
    prev_detrender_input_Odd = 0.0;
    prev_detrender_input_Even = 0.0;

    // INIT_HILBERT_VARIABLES(Q1);
    Q1_Odd[0] = 0.0;
    Q1_Odd[1] = 0.0;
    Q1_Odd[2] = 0.0;
    Q1_Even[0] = 0.0;
    Q1_Even[1] = 0.0;
    Q1_Even[2] = 0.0;
    Q1 = 0.0;
    prev_Q1_Odd = 0.0;
    prev_Q1_Even = 0.0;
    prev_Q1_input_Odd = 0.0;
    prev_Q1_input_Even = 0.0;

    // INIT_HILBERT_VARIABLES(jI);
    jI_Odd[0] = 0.0;
    jI_Odd[1] = 0.0;
    jI_Odd[2] = 0.0;
    jI_Even[0] = 0.0;
    jI_Even[1] = 0.0;
    jI_Even[2] = 0.0;
    jI = 0.0;
    prev_jI_Odd = 0.0;
    prev_jI_Even = 0.0;
    prev_jI_input_Odd = 0.0;
    prev_jI_input_Even = 0.0;

    // INIT_HILBERT_VARIABLES(jQ);
    jQ_Odd[0] = 0.0;
    jQ_Odd[1] = 0.0;
    jQ_Odd[2] = 0.0;
    jQ_Even[0] = 0.0;
    jQ_Even[1] = 0.0;
    jQ_Even[2] = 0.0;
    jQ = 0.0;
    prev_jQ_Odd = 0.0;
    prev_jQ_Even = 0.0;
    prev_jQ_input_Odd = 0.0;
    prev_jQ_input_Even = 0.0;

    period = 0.0;
    outIndex = 0;

    prevI2 = prevQ2 = 0.0;
    Re = Im = 0.0;
    I1ForOddPrev3 = I1ForEvenPrev3 = 0.0;
    I1ForOddPrev2 = I1ForEvenPrev2 = 0.0;
    smoothPeriod = 0.0;

    while (today <= endIndex) {
        adjustedPrevPeriod = (0.075 * period) + 0.54;

        todayValue = inReal[today];
        // DO_PRICE_WMA(todayValue, smoothedValue);
        periodWMASub += todayValue;
        periodWMASub -= trailingWMAValue;
        periodWMASum += todayValue * 4.0;
        trailingWMAValue = inReal[trailingWMAIndex++];
        smoothedValue = periodWMASum * 0.1;
        periodWMASum -= periodWMASub;

        if ((today % 2) == 0) {
            // DO_HILBERT_EVEN(detrender, smoothedValue);
            hilbertTempReal = a * smoothedValue;
            detrender = -detrender_Even[hilbertIndex];
            detrender_Even[hilbertIndex] = hilbertTempReal;
            detrender += hilbertTempReal;
            detrender -= prev_detrender_Even;
            prev_detrender_Even = b * prev_detrender_input_Even;
            detrender += prev_detrender_Even;
            prev_detrender_input_Even = smoothedValue;
            detrender *= adjustedPrevPeriod;

            // DO_HILBERT_EVEN(Q1, detrender);
            hilbertTempReal = a * detrender;
            Q1 = -Q1_Even[hilbertIndex];
            Q1_Even[hilbertIndex] = hilbertTempReal;
            Q1 += hilbertTempReal;
            Q1 -= prev_Q1_Even;
            prev_Q1_Even = b * prev_Q1_input_Even;
            Q1 += prev_Q1_Even;
            prev_Q1_input_Even = detrender;
            Q1 *= adjustedPrevPeriod;

            // DO_HILBERT_EVEN(jI, I1ForEvenPrev3);
            hilbertTempReal = a * I1ForEvenPrev3;
            jI = -jI_Even[hilbertIndex];
            jI_Even[hilbertIndex] = hilbertTempReal;
            jI += hilbertTempReal;
            jI -= prev_jI_Even;
            prev_jI_Even = b * prev_jI_input_Even;
            jI += prev_jI_Even;
            prev_jI_input_Even = I1ForEvenPrev3;
            jI *= adjustedPrevPeriod;

            // DO_HILBERT_EVEN(jQ, Q1);
            hilbertTempReal = a * Q1;
            jQ = -jQ_Even[hilbertIndex];
            jQ_Even[hilbertIndex] = hilbertTempReal;
            jQ += hilbertTempReal;
            jQ -= prev_jQ_Even;
            prev_jQ_Even = b * prev_jQ_input_Even;
            jQ += prev_jQ_Even;
            prev_jQ_input_Even = Q1;
            jQ *= adjustedPrevPeriod;

            if (++hilbertIndex == 3) {
                hilbertIndex = 0;
            }

            Q2 = (0.2 * (Q1 + jI)) + (0.8 * prevQ2);
            I2 = (0.2 * (I1ForEvenPrev3 - jQ)) + (0.8 * prevI2);

            I1ForOddPrev3 = I1ForOddPrev2;
            I1ForOddPrev2 = detrender;
        } else {
            // DO_HILBERT_ODD(detrender, smoothedValue);
            hilbertTempReal = a * smoothedValue;
            detrender = -detrender_Odd[hilbertIndex];
            detrender_Odd[hilbertIndex] = hilbertTempReal;
            detrender += hilbertTempReal;
            detrender -= prev_detrender_Odd;
            prev_detrender_Odd = b * prev_detrender_input_Odd;
            detrender += prev_detrender_Odd;
            prev_detrender_input_Odd = smoothedValue;
            detrender *= adjustedPrevPeriod;

            // DO_HILBERT_ODD(Q1, detrender);
            hilbertTempReal = a * detrender;
            Q1 = -Q1_Odd[hilbertIndex];
            Q1_Odd[hilbertIndex] = hilbertTempReal;
            Q1 += hilbertTempReal;
            Q1 -= prev_Q1_Odd;
            prev_Q1_Odd = b * prev_Q1_input_Odd;
            Q1 += prev_Q1_Odd;
            prev_Q1_input_Odd = detrender;
            Q1 *= adjustedPrevPeriod;

            // DO_HILBERT_ODD(jI, I1ForOddPrev3);
            hilbertTempReal = a * I1ForOddPrev3;
            jI = -jI_Odd[hilbertIndex];
            jI_Odd[hilbertIndex] = hilbertTempReal;
            jI += hilbertTempReal;
            jI -= prev_jI_Odd;
            prev_jI_Odd = b * prev_jI_input_Odd;
            jI += prev_jI_Odd;
            prev_jI_input_Odd = I1ForOddPrev3;
            jI *= adjustedPrevPeriod;

            // DO_HILBERT_ODD(jQ, Q1);
            hilbertTempReal = a * Q1;
            jQ = -jQ_Odd[hilbertIndex];
            jQ_Odd[hilbertIndex] = hilbertTempReal;
            jQ += hilbertTempReal;
            jQ -= prev_jQ_Odd;
            prev_jQ_Odd = b * prev_jQ_input_Odd;
            jQ += prev_jQ_Odd;
            prev_jQ_input_Odd = Q1;
            jQ *= adjustedPrevPeriod;

            Q2 = (0.2 * (Q1 + jI)) + (0.8 * prevQ2);
            I2 = (0.2 * (I1ForOddPrev3 - jQ)) + (0.8 * prevI2);

            I1ForEvenPrev3 = I1ForEvenPrev2;
            I1ForEvenPrev2 = detrender;
        }

        Re = (0.2 * ((I2 * prevI2) + (Q2 * prevQ2))) + (0.8 * Re);
        Im = (0.2 * ((I2 * prevQ2) - (Q2 * prevI2))) + (0.8 * Im);
        prevQ2 = Q2;
        prevI2 = I2;
        tempReal = period;
        if ((Im != 0.0) && (Re != 0.0)) {
            period = 360.0 / (Math.atan(Im / Re) * rad2Deg);
        }
        tempReal2 = 1.5 * tempReal;
        if (period > tempReal2) {
            period = tempReal2;
        }
        tempReal2 = 0.67 * tempReal;
        if (period < tempReal2) {
            period = tempReal2;
        }
        if (period < 6) {
            period = 6;
        } else if (period > 50) {
            period = 50;
        }
        period = (0.2 * period) + (0.8 * tempReal);

        smoothPeriod = (0.33 * period) + (0.67 * smoothPeriod);

        if (today >= startIndex) {
            outReal[outIndex++] = smoothPeriod;
        }

        today++;
    }

    outNBElement = outIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function HtDcPeriodLookback() {
    return (32 + Globals.unstablePeriod[FuncUnstId.HtDcPeriod]);
}
