package ta.func;

import ta.func.Wma.WmaLookback;
import ta.func.Tema.TemaLookback;
import ta.func.Trima.TrimaLookback;
import ta.func.T3.T3lookback;
import ta.func.Mama.MamaLookback;
import ta.func.Kama.KamaLookback;
import ta.func.Dema.DemaLookback;
import ta.func.Ema.EmaLookback;
import ta.func.Sma.SmaLookback;
import ta.Globals.MAType;

@:keep
function Ma(startIndex:Int, endIndex:Int, inReal:Array<Float>, optInTimePeriod:Int, optInMAType:MAType) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outReal:Array<Float> = [];

    var dummyBuffer:Array<Float>;
    var ret;

    var nbElement:Int;
    var outIndex:Int, todayIndex:Int;
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
    if (optInTimePeriod < 1) {
        throw new TAException(BadParam);
    }

    if (optInMAType == null) {
        throw new TAException(BadParam);
    }

    if (optInTimePeriod == 1) {
        nbElement = endIndex - startIndex + 1;
        outNBElement = nbElement;

        todayIndex = startIndex;
        outIndex = 0;
        while (outIndex < nbElement) {
            outReal[outIndex] = inReal[todayIndex];

            outIndex++;
            todayIndex++;
        }
        outBegIndex = startIndex;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outReal: outReal
        };
    }

    switch (optInMAType) {
        case MAType.Sma:
            return ta.func.Sma.Sma(startIndex, endIndex, inReal, optInTimePeriod);
            // ret = ta.func.Sma.Sma(startIndex, endIndex, inReal, optInTimePeriod);
            // outBegIndex = ret.outBegIndex;
            // outNBElement = ret.outNBElement;
            // outReal = ret.outReal;
            // retCode = FUNCTION_CALL(SMA)(, outBegIndex, outNBElement, outReal);

        case MAType.Ema:
            return ta.func.Ema.Ema(startIndex, endIndex, inReal, optInTimePeriod);
            // ret = ta.func.Ema.Ema(startIndex, endIndex, inReal, optInTimePeriod);
            // outBegIndex = ret.outBegIndex;
            // outNBElement = ret.outNBElement;
            // outReal = ret.outReal;
            // retCode = FUNCTION_CALL(EMA)(, outBegIndex, outNBElement, outReal);

        case MAType.Wma:
            return ta.func.Wma.Wma(startIndex, endIndex, inReal, optInTimePeriod);
            // ret = ta.func.Wma.Wma(startIndex, endIndex, inReal, optInTimePeriod);
            // outBegIndex = ret.outBegIndex;
            // outNBElement = ret.outNBElement;
            // outReal = ret.outReal;
            // retCode = FUNCTION_CALL(WMA)(startIndex, endIndex, inReal, optInTimePeriod, outBegIndex, outNBElement, outReal);

        case MAType.Dema:
            return ta.func.Dema.Dema(startIndex, endIndex, inReal, optInTimePeriod);
            // ret = ta.func.Dema.Dema(startIndex, endIndex, inReal, optInTimePeriod);
            // outBegIndex = ret.outBegIndex;
            // outNBElement = ret.outNBElement;
            // outReal = ret.outReal;
            // retCode = FUNCTION_CALL(DEMA)(startIndex, endIndex, inReal, optInTimePeriod, outBegIndex, outNBElement, outReal);

        case MAType.Tema:
            return ta.func.Tema.Tema(startIndex, endIndex, inReal, optInTimePeriod);
            // ret = ta.func.Tema.Tema(startIndex, endIndex, inReal, optInTimePeriod);
            // outBegIndex = ret.outBegIndex;
            // outNBElement = ret.outNBElement;
            // outReal = ret.outReal;
            // retCode = FUNCTION_CALL(TEMA)(startIndex, endIndex, inReal, optInTimePeriod, outBegIndex, outNBElement, outReal);

        case MAType.Trima:
            return ta.func.Trima.Trima(startIndex, endIndex, inReal, optInTimePeriod);
            // ret = ta.func.Trima.Trima(startIndex, endIndex, inReal, optInTimePeriod);
            // outBegIndex = ret.outBegIndex;
            // outNBElement = ret.outNBElement;
            // outReal = ret.outReal;
            // retCode = FUNCTION_CALL(TRIMA)(startIndex, endIndex, inReal, optInTimePeriod, outBegIndex, outNBElement, outReal);

        case MAType.Kama:
            return ta.func.Kama.Kama(startIndex, endIndex, inReal, optInTimePeriod);
            // ret = ta.func.Kama.Kama(startIndex, endIndex, inReal, optInTimePeriod);
            // outBegIndex = ret.outBegIndex;
            // outNBElement = ret.outNBElement;
            // outReal = ret.outReal;
            // retCode = FUNCTION_CALL(KAMA)(startIndex, endIndex, inReal, optInTimePeriod, outBegIndex, outNBElement, outReal);

        case MAType.Mama:
            // ARRAY_ALLOC(dummyBuffer, (endIndex - startIndex + 1));

            // if (!dummyBuffer)
            //                 return ENUM_VALUE(RetCode, TA_ALLOC_ERR, AllocErr);
            ret = ta.func.Mama.Mama(startIndex, endIndex, inReal, 0.5, 0.05);
            outBegIndex = ret.outBegIndex;
            outNBElement = ret.outNBElement;
            outReal = ret.outMAMA;
            dummyBuffer = ret.outFAMA;
            // retCode = FUNCTION_CALL(MAMA)(startIndex, endIndex, inReal, 0.5, 0.05, outBegIndex, outNBElement, outReal, dummyBuffer);

            // ARRAY_FREE(dummyBuffer);

        case MAType.T3:
            return ta.func.T3.T3(startIndex, endIndex, inReal, optInTimePeriod, 0.7);
            // ret = ta.func.T3.T3(startIndex, endIndex, inReal, optInTimePeriod, 0.7);
            // outBegIndex = ret.outBegIndex;
            // outNBElement = ret.outNBElement;
            // outReal = ret.outReal;
            // retCode = FUNCTION_CALL(T3)(startIndex, endIndex, inReal, optInTimePeriod, 0.7, outBegIndex, outNBElement, outReal);

        default:
            throw new TAException(BadParam);
    }

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outReal: outReal
    };
}

@:keep
function MaLookback(optInTimePeriod:Int, optInMAType:MAType):Int {
    var retValue:Int;

    // INTEGER_DEFAULT
    // if(optInTimePeriod == null || ){
    //     optInTimePeriod = 30;
    // } else
    if (optInTimePeriod < 1) {
        return -1;
    }
    if (optInMAType == null) {
        return -1;
    }

    if (optInTimePeriod <= 1) {
        return 0;
    }

    switch (optInMAType) {
        case MAType.Sma:
            retValue = SmaLookback(optInTimePeriod);
        case MAType.Ema:
            retValue = EmaLookback(optInTimePeriod);
        case MAType.Wma:
            retValue = WmaLookback(optInTimePeriod);
        case MAType.Dema:
            retValue = DemaLookback(optInTimePeriod);
        case MAType.Tema:
            retValue = TemaLookback(optInTimePeriod);
        case MAType.Trima:
            retValue = TrimaLookback(optInTimePeriod);
        case MAType.Kama:
            retValue = KamaLookback(optInTimePeriod);
        case MAType.Mama:
            retValue = MamaLookback(0.5, 0.05);
        case MAType.T3:
            retValue = T3lookback(optInTimePeriod, 0.7);
        default:
            retValue = 0;
    }

    return retValue;
}
