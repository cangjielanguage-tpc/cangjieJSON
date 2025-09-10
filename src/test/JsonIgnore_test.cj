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

@Test
func JsonIgnore_BasicTest() {
    let input = #"{"a":"aaa","b":[1,2,3],"c":456}"#
    let expectOutput = #"{"c":456}"#
    @Assert(IgnoreClass.fromJson(input).toJson(), expectOutput)
    @Assert(IgnoreClass.fromStreamJson(input).toStreamJson(), expectOutput)
}