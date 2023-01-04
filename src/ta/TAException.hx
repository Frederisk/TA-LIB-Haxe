package ta;

import haxe.Exception;

using haxe.EnumTools;

@:keep @:keepSub
class TAException extends Exception {
    public function new(status:ExceptionStatus) {
        super(status.getName());
        if (status == Success) {
            throw new Exception('You Should NOT throw exception when your task is successful');
        }
    }
}

@:nativeGen
enum ExceptionStatus {
    Success;
    LibNotInitialize;
    BadParam;
    AllocError;
    GroupNotFound;
    FuncNotFound;
    InvalidHandle;
    InvalidParamHolder;
    InvalidParamHolderType;
    InvalidParamFunction;
    InputNotAllInitialize;
    OutputNotAllInitialize;
    OutOfRangeStartIndex;
    OutOfRangeEndIndex;
    InvalidListType;
    BadObject;
    NotSupported;
    InternalError;
    UnknownErr;
}

// enum abstract ExceptionStatus(Int) {
// 	var Success = 0; // No error
// 	var LibNotInitialize = 1; // TA_Initialize was not successfully called
// 	var BadParam = 2; // A parameter is out of range
// 	var AllocError = 3; // Possibly out-of-memory
// 	var GroupNotFound = 4;
// 	var FuncNotFound = 5;
// 	var InvalidHandle = 6;
// 	var InvalidParamHolder = 7;
// 	var InvalidParamHolderType = 8;
// 	var InvalidParamFunction = 9;
// 	var InputNotAllInitialize = 10;
// 	var OutputNotAllInitialize = 11;
// 	var OutOfRangeStartIndex = 12;
// 	var OutOfRangeEndIndex = 13;
// 	var InvalidListType = 14;
// 	var BadObject = 15;
// 	var NotSupported = 16;
// 	var InternalError = 5000;
// 	var UnknownErr = 0xFFFF;
// }
