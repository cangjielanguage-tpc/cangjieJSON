/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*
import cjjson.*
import cjjson.macros.*

// 泛型类，未使用 withGenericType 属性，
@JsonAdapter
public class GenericNotMark<T> {
    public var a: Int64 = 0

    @JsonIgnore
    public var data: ?T = None
}

// 泛型类，使用了 withGenericType 属性
@JsonAdapter[withGenericType = T]
public class GenericMark<T> {
    public var a: Int64 = 0
    public var data: ?T = None
}

@JsonAdapter
public class SimpleData {
    public var d1: Int64 = 0
    public var d2: Int64 = 0
}

// 泛型结构体，未使用 withGenericType 属性，
@JsonAdapter
public struct GenericStructNotMark<T> {
    public var a: Int64 = 0

    @JsonIgnore
    public var data: ?T = None
}

// 泛型结构体，使用了 withGenericType 属性
@JsonAdapter[withGenericType = T]
public struct GenericStructMark<T> {
    public var a: Int64 = 0
    public var data: ?T = None
}

@Test
class WithGenericTypeTest {
    let input = #"{"a":123,"data":{"d1":100,"d2":200}}"#

    @TestCase
    func classUsingWithGenericType() {
        let obj = GenericNotMark<SimpleData>.fromJson(input)
        @Assert(obj.data.isNone())
        @Assert(obj.toJson(), #"{"a":123}"#)
    }

    @TestCase
    func classNotUsingWithGenericType() {
        let obj = GenericMark<SimpleData>.fromJson(input)
        @Assert(obj.data.isSome())
        @Assert(obj.toJson(), input)
    }

    @TestCase
    func structUsingWithGenericType() {
        let obj = GenericStructNotMark<SimpleData>.fromJson(input)
        @Assert(obj.data.isNone())
        @Assert(obj.toJson(), #"{"a":123}"#)
    }

    @TestCase
    func structNotUsingWithGenericType() {
        let obj = GenericStructMark<SimpleData>.fromJson(input)
        @Assert(obj.data.isSome())
        @Assert(obj.toJson(), input)
    }
}
