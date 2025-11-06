/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*
import cjjson.*
import cjjson.macros.*

// 如果手动添加了 `IJsonAdapter<T>` 的父接口，不影响 @JsonAdapter 的使用。
@JsonAdapter
public class ClassWithIJsonAdapter <: IJsonAdapter<ClassWithIJsonAdapter> {
    public var a: Int64 = 0
}

// 如果类实现了其他接口，也不影响 @JsonAdapter 的使用。
@JsonAdapter
public class ClassWithEqutable <: Equatable<ClassWithEqutable> {
    public var a: Int64 = 0
    public var b: String = ""

    public init() {}

    public init(a: Int64, b: String) {
        this.a = a
        this.b = b
    }

    public operator func ==(right: ClassWithEqutable): Bool {
        return this.a == right.a && this.b == right.b
    }

    public operator func !=(right: ClassWithEqutable): Bool {
        return this.a != right.a || this.b != right.b
    }
}

@Test
class ClassWithInterfaceTest {
    @TestCase
    func classWithIJsonAdapter() {
        let input: String = #"{"a": 123}"#
        let obj = ClassWithIJsonAdapter.fromJson(input)
        @Assert(obj.a, 123)
    }

    @TestCase
    func classWithEqutable() {
        let input: String = #"{"a": 123, "b": "hello"}"#
        let obj = ClassWithEqutable.fromJson(input)
        let target = ClassWithEqutable(123, "hello")
        @Assert(obj == target)
    }
}
