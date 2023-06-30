package ta.func;

import ta.func.Utility.HighLowRange;
import ta.func.Utility.CandleRange;
import ta.func.Utility.UpperShadow;
import ta.func.Utility.LowerShadow;
import ta.func.Utility.CandleAverage;
import ta.func.Utility.RealBody;
import ta.Globals.CandleSettingType;
import ta.func.Utility.TAIntMax;

@:keep
function CdlRickshawMan(startIndex:Int, endIndex:Int, inOpen:Array<Float>, inHigh:Array<Float>, inLow:Array<Float>, inClose:Array<Float>) {
    var outBegIndex:Int;
    var outNBElement:Int;
    var outInteger:Array<Int> = [];

    var BodyDojiPeriodTotal:Float,
        ShadowLongPeriodTotal:Float,
        NearPeriodTotal:Float;
    var i:Int,
        outIndex:Int,
        BodyDojiTrailingIndex:Int,
        ShadowLongTrailingIndex:Int,
        NearTrailingIndex:Int,
        lookbackTotal:Int;

    if (startIndex < 0) {
        throw new TAException(OutOfRangeStartIndex);
    }
    if (endIndex < 0 || endIndex < startIndex) {
        throw new TAException(OutOfRangeEndIndex);
    }
    if (inOpen == null || inHigh == null || inLow == null || inClose == null) {
        throw new TAException(BadParam);
    }

    lookbackTotal = CdlRickshawManLookback();

    if (startIndex < lookbackTotal) {
        startIndex = lookbackTotal;
    }

    if (startIndex > endIndex) {
        outBegIndex = 0;
        outNBElement = 0;
        return {
            outBegIndex: outBegIndex,
            outNBElement: outNBElement,
            outInteger: outInteger
        };
    }

    BodyDojiPeriodTotal = 0;
    BodyDojiTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.BodyDoji].avgPeriod;
    ShadowLongPeriodTotal = 0;
    ShadowLongTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.ShadowLong].avgPeriod;
    NearPeriodTotal = 0;
    NearTrailingIndex = startIndex - Globals.candleSettings[CandleSettingType.Near].avgPeriod;

    i = BodyDojiTrailingIndex;
    while (i < startIndex) {
        BodyDojiPeriodTotal += CandleRange(CandleSettingType.BodyDoji, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = ShadowLongTrailingIndex;
    while (i < startIndex) {
        ShadowLongPeriodTotal += CandleRange(CandleSettingType.ShadowLong, i, inOpen, inHigh, inLow, inClose);
        i++;
    }
    i = NearTrailingIndex;
    while (i < startIndex) {
        NearPeriodTotal += CandleRange(CandleSettingType.Near, i, inOpen, inHigh, inLow, inClose);
        i++;
    }

    outIndex = 0;
    do {
        if (RealBody(i, inOpen, inClose) <= CandleAverage(CandleSettingType.BodyDoji, BodyDojiPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && LowerShadow(i, inOpen, inLow, inClose) > CandleAverage(CandleSettingType.ShadowLong, ShadowLongPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && UpperShadow(i, inOpen, inHigh, inClose) > CandleAverage(CandleSettingType.ShadowLong, ShadowLongPeriodTotal, i, inOpen, inHigh, inLow, inClose)
            && (Math.min(inOpen[i], inClose[i]) <= inLow[i]
                + HighLowRange(i, inHigh, inLow) / 2
                + CandleAverage(CandleSettingType.Near, NearPeriodTotal, i, inOpen, inHigh, inLow, inClose) && Math.max(inOpen[i], inClose[i]) >= inLow[i]
                    + HighLowRange(i, inHigh, inLow) / 2
                    - CandleAverage(CandleSettingType.Near, NearPeriodTotal, i, inOpen, inHigh, inLow, inClose))) {
            outInteger[outIndex++] = 100;
        } else {
            outInteger[outIndex++] = 0;
        }

        BodyDojiPeriodTotal += CandleRange(CandleSettingType.BodyDoji, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.BodyDoji, BodyDojiTrailingIndex, inOpen, inHigh, inLow, inClose);
        ShadowLongPeriodTotal += CandleRange(CandleSettingType.ShadowLong, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.ShadowLong, ShadowLongTrailingIndex, inOpen, inHigh, inLow, inClose);
        NearPeriodTotal += CandleRange(CandleSettingType.Near, i, inOpen, inHigh, inLow, inClose)
            - CandleRange(CandleSettingType.Near, NearTrailingIndex, inOpen, inHigh, inLow, inClose);
        i++;
        BodyDojiTrailingIndex++;
        ShadowLongTrailingIndex++;
        NearTrailingIndex++;
    } while (i <= endIndex);

    outNBElement = outIndex;
    outBegIndex = startIndex;

    return {
        outBegIndex: outBegIndex,
        outNBElement: outNBElement,
        outInteger: outInteger
    };
}

@:keep
function CdlRickshawManLookback() {
    return TAIntMax(TAIntMax(Globals.candleSettings[CandleSettingType.BodyDoji].avgPeriod, Globals.candleSettings[CandleSettingType.ShadowLong].avgPeriod),
        Globals.candleSettings[CandleSettingType.Near].avgPeriod);
}
