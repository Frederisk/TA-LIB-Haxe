# TA-Lib Haxe

Rewrite TA-LIB in Haxe.

## Functions TODO List

Pattern Recognition:

```plain
CDLMATCHINGLOW       Matching Low
CDLMATHOLD           Mat Hold
CDLMORNINGDOJISTAR   Morning Doji Star
CDLMORNINGSTAR       Morning Star
CDLONNECK            On-Neck Pattern
CDLPIERCING          Piercing Pattern
CDLRICKSHAWMAN       Rickshaw Man
CDLRISEFALL3METHODS  Rising/Falling Three Methods
CDLSEPARATINGLINES   Separating Lines
CDLSHOOTINGSTAR      Shooting Star
CDLSHORTLINE         Short Line Candle
CDLSPINNINGTOP       Spinning Top
CDLSTALLEDPATTERN    Stalled Pattern
CDLSTICKSANDWICH     Stick Sandwich
CDLTAKURI            Takuri (Dragonfly Doji with very long lower shadow)
CDLTASUKIGAP         Tasuki Gap
CDLTHRUSTING         Thrusting Pattern
CDLTRISTAR           Tristar Pattern
CDLUNIQUE3RIVER      Unique 3 River
CDLUPSIDEGAP2CROWS   Upside Gap Two Crows
CDLXSIDEGAP3METHODS  Upside/Downside Gap Three Methods
```

## Road Map

- [ ] Check `round_pos` function.
- [ ] Simply rewrite all necessary methods according to the original project (C language project).
- [ ] Create the necessary classes and interfaces to provide good design in the lens language.
- [ ] Review all methods and add necessary comments.
- [ ] Create unit tests and CI.
- [ ] Design the class and interface of the library, and standardize the API.
- [ ] Check the output of C#, Python, JavaScript and other languages ​​to ensure that the design goals are met.
- [ ] Create package data and publish.

## Idea

- [ ] Use `haxe.ds.Vector` instead of `Array` for better performance.
- [ ] For `TAException`, when `ExceptionStatus` is `InternalError`, a field or message is required to hold the error `ID`.
- [ ] The type `abstract` will lose their type when compiled into targets. So it should be avoided.

## Acknowledgement

- [TA-Lib](https://ta-lib.org/)
- [Python wrapper for TA-Lib](https://ta-lib.github.io/ta-lib-python/)
