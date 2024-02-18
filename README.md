# TA-Lib Haxe

Rewrite TA-LIB in Haxe.

## Road Map

- [ ] Check `round_pos` function.
- [x] Simply rewrite all necessary methods according to the original project (C language project).
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
