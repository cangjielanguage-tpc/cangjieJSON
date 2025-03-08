package examples

import std.collection.*

// 导入相关依赖包
import cjjson.*
import cjjson.macros.*
import encoding.json.*

@JsonAdapter
public class SimpleData {
    public var a: Int64 = 0
    public var b: String = ""
}

@JsonAdapter[withGenericType = T]
public open class GenericParent<T> {
    public var pData: ?T = None
}

@JsonAdapter[withSuperClass = GenericParent<T>; withGenericType = T]
public class GenericChild<T> <: GenericParent<T> {
    public var cData: ?T = None
}


func test_JsonAdapter4() {
    println("---------- test_JsonAdapter4 ----------")

    let input = #"{"pData":{"a":123,"b":"hello"},"cData":{"a":456,"b":"cangjie"}}"#
    let c = GenericChild<SimpleData>.fromJson(input)

    println(c.pData.toJson()) // 输出：{"a":123,"b":"hello"}
    println(c.cData.toJson()) // 输出：{"a":456,"b":"cangjie"}
}