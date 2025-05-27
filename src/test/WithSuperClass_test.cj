package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*
import cjjson.*
import cjjson.macros.*

// 定义一个父类
@JsonAdapter
public open class Parent {
    public var a: Int64 = 0
}

// 子类存在父类，但未使用 withSuperClass 属性，则父类中的成员变量不会被序列化和反序列化
@JsonAdapter
public class ChildNotMarkParent <: Parent {
    public var b: String = ""
}

// 子类存在父类，且使用了 withSuperClass 属性，则父类中的成员变量会被序列化和反序列化
@JsonAdapter[withSuperClass=Parent]
public class ChildMarkParent <: Parent {
    public var b: String = ""
}

@Test
class WithSuperClassTest {
    @TestCase
    func withSuperClassEnabled() {
        let input: String = #"{"a":123,"b":"hello"}"#
        let c = ChildNotMarkParent.fromJson(input)
        // 父类中的成员变量不会被反序列化
        @Assert(c.a, 0)
        @Assert(c.b, "hello")
        // 父类中的成员变量也不会被序列化
        @Assert(c.toJson(), #"{"b":"hello"}"#)
    }

    @TestCase
    func withSuperClassDisabled() {
        let input: String = #"{"a":123,"b":"hello"}"#
        let c = ChildMarkParent.fromJson(input)
        // 父类中的成员变量会被反序列化
        @Assert(c.a, 123)
        @Assert(c.b, "hello")
        // 父类中的成员变量也会被序列化
        @Assert(c.toJson(), input)
    }
}
