/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*
import cjjson.*
import cjjson.macros.*
import std.collection.*

@JsonAdapter
public class JsonDefaultClass {
    @JsonDefault
    public var a: String = "default"
    @JsonDefault
    public var b: ?String = "default"
    @JsonDefault
    public var c: Simple = Simple(404, "error")
    @JsonDefault
    public var d: ?Simple = None
}

@JsonAdapter
public struct JsonDefaultStruct {
    @JsonDefault
    public var a: String = "default"
    @JsonDefault
    public var b: ?String = "default"
    @JsonDefault
    public var c: SimpleStruct = SimpleStruct(404, "error")
    @JsonDefault
    public var d: ?SimpleStruct = None
}

@Test
class JsonDefaultTest {
    let input1 = #"{"a":"aaa","c":{"code":0, "message":"ok"}}"# // a、c 有值
    let input2 = #"{"b":"bbb","d":{"code":0, "message":"ok"}}"# // b、d 有值

    @TestCase
    func testClass() {
        let obj = JsonDefaultClass.fromJson(input1)
        @Assert(obj.a, "aaa")
        @Assert(obj.b, Some("default"))
        @Assert(obj.c.code, 0)
        @Assert(obj.c.message, "ok")
        @Assert(obj.d.isNone())

        let obj2 = JsonDefaultClass.fromJson(input2)
        @Assert(obj2.a, "default")
        @Assert(obj2.b, Some("bbb"))
        @Assert(obj2.c.code, 404)
        @Assert(obj2.c.message, "error")
        @Assert(obj2.d.isSome())
        @Assert(obj2.d.getOrThrow().code, 0)
        @Assert(obj2.d.getOrThrow().message, "ok")
    }

    @TestCase
    func testStruct() {
        let obj = JsonDefaultStruct.fromJson(input1)
        @Assert(obj.a, "aaa")
        @Assert(obj.b, Some("default"))
        @Assert(obj.c.code, 0)
        @Assert(obj.c.message, "ok")
        @Assert(obj.d.isNone())

        let obj2 = JsonDefaultStruct.fromJson(input2)
        @Assert(obj2.a, "default")
        @Assert(obj2.b, Some("bbb"))
        @Assert(obj2.c.code, 404)
        @Assert(obj2.c.message, "error")
        @Assert(obj2.d.isSome())
        @Assert(obj2.d.getOrThrow().code, 0)
        @Assert(obj2.d.getOrThrow().message, "ok")
    }
}
