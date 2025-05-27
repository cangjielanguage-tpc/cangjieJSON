package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*
import cjjson.*
import cjjson.macros.*

// 如果手动添加了 `IJsonAdapter<T>` 的父接口，不影响 @JsonAdapter 的使用。
@JsonAdapter
public struct StructWithIJsonAdapter <: IJsonAdapter<StructWithIJsonAdapter> {
    public var a: Int64 = 0
}

// 如果类实现了其他接口，也不影响 @JsonAdapter 的使用。
@JsonAdapter
public struct StructWithEqutable <: Equatable<StructWithEqutable> {
    public var a: Int64 = 0
    public var b: String = ""

    public init() {}

    public init(a: Int64, b: String) {
        this.a = a
        this.b = b
    }

    public operator func ==(right: StructWithEqutable): Bool {
        return this.a == right.a && this.b == right.b
    }

    public operator func !=(right: StructWithEqutable): Bool {
        return this.a != right.a || this.b != right.b
    }
}

@Test
class StructWithInterfaceTest {
    @TestCase
    func structWithIJsonAdapter() {
        let input: String = #"{"a": 123}"#
        let obj = StructWithIJsonAdapter.fromJson(input)
        @Assert(obj.a, 123)
    }

    @TestCase
    func structWithEqutable() {
        let input: String = #"{"a": 123, "b": "hello"}"#
        let obj = StructWithEqutable.fromJson(input)
        let target = StructWithEqutable(123, "hello")
        @Assert(obj == target)
    }
}