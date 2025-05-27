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

@Test
class JsonIgnoreNullTest {
    @TestCase
    func useNullValue() {
        let input = #"{"a":1,"b":null,"c":"ccc","d":[4,5,6],"e":null}"#
        let inc = IgnoreNullClass.fromJson(input)
        @Assert(inc.a, 1)
        @Assert(inc.b.isNone())
        @Assert(inc.c.getOrThrow(), "ccc")
        @Assert(inc.d.isSome())
        let arr = inc.d.getOrThrow()
        @Assert(arr[0], 4)
        @Assert(arr[1], 5)
        @Assert(arr[2], 6)
        @Assert(inc.e.isNone())
    }

    @TestCase
    func missValue() {
        let input = #"{"a":1}"#
        let inc = IgnoreNullClass.fromJson(input)
        @Assert(inc.a, 1)
        @Assert(inc.b.isNone())
        @Assert(inc.c.isNone())
        @Assert(inc.d.isNone())
        @Assert(inc.e.isNone())
    }

    @TestCase
    func toJson() {
        let inc = IgnoreNullClass()
        inc.a = 123
        inc.b = None
        inc.c = "hello"
        inc.d = None
        inc.e = ArrayList(["cangjie", "world"])
        let expectJson = #"{"a":123,"c":"hello","e":["cangjie","world"]}"#
        @Assert(inc.toJson(), expectJson)
    }
}