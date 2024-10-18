package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*

import cjjson.*
import cjjson.macros.*
import std.collection.*

@JsonAdapter
public class Basic {
    public var a: Int64 = 0
    public var b: String = ""
    public var c: ?String = None
    public var d: Array<Int64> = Array<Int64>()
    public var e: ArrayList<String> = ArrayList<String>()
    public var f: HashMap<String, Int64> = HashMap<String, Int64>()
}

@Test
func JsonAdapter_BasicTest() {
    let input: String = #"{"a":123,"b":"bbbbb","c":null,"d":[1,2,3],"e":["s1","s2","s3"],"f":{"f1":123,"f2":456}}"#
    @Assert(Basic.fromJson(input).toJson(), input)
}
