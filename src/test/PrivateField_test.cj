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
public class ClassWithPrivateField {
    private var code: Int64 = 0
    private var message: String = ""

    public func getCode(): Int64 {
        return code
    }

    public prop msg: String {
        get() {
            return message
        }
    }
}

@JsonAdapter
public struct StructWithPrivateField {
    private var code: Int64 = 0
    private var message: String = ""

    public func getCode(): Int64 {
        return code
    }

    public prop msg: String {
        get() {
            return message
        }
    }
}

@Test
class PrivateFieldTest {
    let input = #"{"code":123,"message":"hello"}"#

    @TestCase
    func classAllowPrivateFields() {
        let obj = ClassWithPrivateField.fromJson(input)
        @Assert(obj.getCode(), 123)
        @Assert(obj.msg, "hello")
    }

    @TestCase
    func structAllowPrivateFields() {
        let obj2 = StructWithPrivateField.fromJson(input)
        @Assert(obj2.getCode(), 123)
        @Assert(obj2.msg, "hello")
    }
}
