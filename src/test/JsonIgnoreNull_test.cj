package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*

import cjjson.*
import cjjson.macros.*
import std.collection.*

@JsonAdapter
public class IgnoreNullClass {
    @JsonIgnoreNull
    public var a: Int64 = 0

    @JsonIgnoreNull
    public var b: Option<Int64> = 0

    @JsonIgnoreNull
    public var c: Option<String> = ""

    @JsonIgnoreNull
    public var d: Option<ArrayList<Int64>> = None

    @JsonIgnoreNull
    public var e: Option<ArrayList<String>> = None
}

@JsonAdapter
public struct IgnoreNullStruct {
    @JsonIgnoreNull
    public var a: Int64 = 0

    @JsonIgnoreNull
    public var b: Option<Int64> = 0

    @JsonIgnoreNull
    public var c: Option<String> = ""

    @JsonIgnoreNull
    public var d: Option<ArrayList<Int64>> = None

    @JsonIgnoreNull
    public var e: Option<ArrayList<String>> = None
}

@Test
class JsonIgnoreNullTest {
    @TestCase
    func useNullValue() {
        let input = #"{"a":1,"b":null,"c":"ccc","d":[4,5,6],"e":null}"#
        let obj = IgnoreNullClass.fromJson(input)
        @Assert(obj.a, 1)
        @Assert(obj.b.isNone())
        @Assert(obj.c.getOrThrow(), "ccc")
        @Assert(obj.d.isSome())
        let arr = obj.d.getOrThrow()
        @Assert(arr[0], 4)
        @Assert(arr[1], 5)
        @Assert(arr[2], 6)
        @Assert(obj.e.isNone())
    }

    @TestCase
    func missValue() {
        let input = #"{"a":1}"#
        let obj = IgnoreNullClass.fromJson(input)
        @Assert(obj.a, 1)
        @Assert(obj.b.isNone())
        @Assert(obj.c.isNone())
        @Assert(obj.d.isNone())
        @Assert(obj.e.isNone())
    }

    @TestCase
    func toJson() {
        let obj = IgnoreNullClass()
        obj.a = 123
        obj.b = None
        obj.c = "hello"
        obj.d = None
        obj.e = ArrayList(["cangjie", "world"])
        let expectJson = #"{"a":123,"c":"hello","e":["cangjie","world"]}"#
        @Assert(obj.toJson(), expectJson)
    }

    @TestCase
    func structUseNullValue() {
        let input = #"{"a":1,"b":null,"c":"ccc","d":[4,5,6],"e":null}"#
        let obj = IgnoreNullStruct.fromJson(input)
        @Assert(obj.a, 1)
        @Assert(obj.b.isNone())
        @Assert(obj.c.getOrThrow(), "ccc")
        @Assert(obj.d.isSome())
        let arr = obj.d.getOrThrow()
        @Assert(arr[0], 4)
        @Assert(arr[1], 5)
        @Assert(arr[2], 6)
        @Assert(obj.e.isNone())
    }

    @TestCase
    func structMissValue() {
        let input = #"{"a":1}"#
        let obj = IgnoreNullStruct.fromJson(input)
        @Assert(obj.a, 1)
        @Assert(obj.b.isNone())
        @Assert(obj.c.isNone())
        @Assert(obj.d.isNone())
        @Assert(obj.e.isNone())
    }

    @TestCase
    func structToJson() {
        var obj = IgnoreNullStruct()
        obj.a = 123
        obj.b = None
        obj.c = "hello"
        obj.d = None
        obj.e = ArrayList(["cangjie", "world"])
        let expectJson = #"{"a":123,"c":"hello","e":["cangjie","world"]}"#
        @Assert(obj.toJson(), expectJson)
    }
}