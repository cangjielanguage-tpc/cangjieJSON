package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*
import cjjson.*
import cjjson.macros.*

@Test
class TypeMismatchTest {
    let input = #"{"code":"hello","message":"canjgie"}"#

    @TestCase
    func classFiledNotExist() {
        // code 应该为整数类型，所以会抛出JsonTypeMismatch异常
        @AssertThrows[JsonTypeMismatch](Simple.fromJson(input))
    }

    @TestCase
    func structFiledNotExist() {
        // code 应该为整数类型，所以会抛出JsonTypeMismatch异常
        @AssertThrows[JsonTypeMismatch](SimpleStruct.fromJson(input))
    }
}