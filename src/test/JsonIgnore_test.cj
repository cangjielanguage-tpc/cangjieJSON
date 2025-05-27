package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*

import cjjson.*
import cjjson.macros.*
import std.collection.*

@JsonAdapter
public class IgnoreClass {
    @JsonIgnore
    public var a: String = ""
    @JsonIgnore
    public var b = ArrayList<Int64>()

    public var c: Int64 = 0
}

@JsonAdapter
public struct IgnoreStruct {
    @JsonIgnore
    public var a: String = ""
    @JsonIgnore
    public var b = ArrayList<Int64>()

    public var c: Int64 = 0
}

@Test
class JsonIgnoreTest {
    let input = #"{"a":"aaa","b":[1,2,3],"c":456}"#

    @TestCase
    func fromJson() {
        let ic = IgnoreClass.fromJson(input)
        @Assert(ic.a, "")
        @Assert(ic.b.size, 0)
        @Assert(ic.c, 456)
    }

    @TestCase
    func toJson() {
        let ic = IgnoreClass()
        ic.a = "aaa"
        ic.b = ArrayList([1, 2, 3])
        ic.c = 456
        let expectJson = #"{"c":456}"#
        @Assert(ic.toJson(), expectJson)
    }

    @TestCase
    func structFromJson() {
        let obj = IgnoreStruct.fromJson(input)
        @Assert(obj.a, "")
        @Assert(obj.b.size, 0)
        @Assert(obj.c, 456)
    }

    @TestCase
    func structToJson() {
        var obj = IgnoreStruct()
        obj.a = "aaa"
        obj.b = ArrayList([1, 2, 3])
        obj.c = 456
        let expectJson = #"{"c":456}"#
        @Assert(obj.toJson(), expectJson)
    }
}