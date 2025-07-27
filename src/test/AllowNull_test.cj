package cjjson.test

import cjjson.*
import cjjson.macros.*
import std.collection.*

import std.unittest.*
import std.unittest.testmacro.*

@JsonAdapter[allowNull]
public class AllowNullClass {
    public var a: String = "default"
    public var b: String = "default"
    public var c: String = ""
}

@JsonAdapter[allowNull]
public struct AllowNullStruct {
    public var a: String = "default"
    public var b: String = "default"
    public var c: String = ""

}

@Test
class AllowNullTest {
    // 其中，字段 a 缺失，字段 b 为 null 值，期望反序列化后返回默认值。
    private let input = #"{"b":null, "c": "ccc"}"#
    @TestCase
    func classAllowNull() {
        let obj = AllowNullClass.fromJson(input)
        @Assert(obj.a, "default")
        @Assert(obj.b, "default")
        @Assert(obj.c, "ccc")
    }

    @TestCase
    func structAllowNull() {
        let obj = AllowNullStruct.fromJson(input)
        @Assert(obj.a, "default")
        @Assert(obj.b, "default")
         @Assert(obj.c, "ccc")
    }
}