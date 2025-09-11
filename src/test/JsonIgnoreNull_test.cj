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
func JsonIgnoreNull_UseNullValue() {
    let input = #"{"a":1,"b":null,"c":"ccc","d":[4,5,6],"e":null}"#
    let expectOutput = #"{"a":1,"c":"ccc","d":[4,5,6]}"#
    @Assert(IgnoreNullClass.fromStreamJson(input).toStreamJson(), expectOutput)
    @Assert(IgnoreNullClass.fromJson(input).toJson(), expectOutput)
}

@Test
func JsonIgnoreNull_MissValue() {
    let input = #"{"a":1}"#
    let expectOutput = #"{"a":1,"b":0,"c":""}"#
    @Assert(IgnoreNullClass.fromStreamJson(input).toStreamJson(), expectOutput)
    @Assert(IgnoreNullClass.fromJson(input).toJson(), expectOutput)
}
