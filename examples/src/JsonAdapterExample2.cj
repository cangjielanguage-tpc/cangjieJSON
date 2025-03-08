package examples

import std.collection.*

// 导入相关依赖包
import cjjson.*
import cjjson.macros.*
import encoding.json.*

@JsonAdapter
public open class Parent {
    public var a: Int64 = 0
}

@JsonAdapter[withSuperClass = Parent]
public class Child <: Parent {
    public var b: String = ""
}

func test_JsonAdapter2() {
    println("---------- test_JsonAdapter2 ----------")

    let input = #"{"a":123,"b":"hello"}"#

    let c: Child = Child.fromJson(input)
    println(c.a) // 输出 123
    println(c.b) // 输出 hello
}