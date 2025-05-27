package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*
import cjjson.*
import cjjson.macros.*
import std.collection.*

@Test
class BasicTypeExtendTest {
    @TestCase
    func stringConvert() {
        let value = String.fromJson("hello".toJson())
        @Assert(value, "hello")
    }

    @TestCase
    func intConvert() {
        let value = Int64.fromJson(123.toJson())
        @Assert(value, 123)
    }

    @TestCase
    func floatConvert() {
        let value = Float64.fromJson(3.125.toJson())
        @Assert(value, 3.125)
    }

    @TestCase
    func boolConvert() {
        let value = Bool.fromJson(true.toJson())
        @Assert(value, true)
    }

    @TestCase
    func optionConvert() {
        let value = Option<Int64>.fromJson(Option<Int64>.None.toJson())
        @Assert(value, None)

        let value2 = Option<Int64>.fromJson(123.toJson())
        @Assert(value2.getOrThrow(), 123)
    }
}