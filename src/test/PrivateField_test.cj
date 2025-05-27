package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*
import cjjson.*
import cjjson.macros.*
import std.collection.*

@JsonAdapter
public class ClassWithPrivateField {
    private var code: Int64 = 0
    private var message: String = ""

    public func getCode(): Int64 {
        return code
    }

    public prop msg: String {
        get() { return message }
    }
}

@Test
class PrivateFieldTest {
    @TestCase
    func allowPrivateFields() {
        let input = #"{"code":123,"message":"hello"}"#
        let obj = ClassWithPrivateField.fromJson(input)
        @Assert(obj.getCode(), 123)
        @Assert(obj.msg, "hello")
    }
}