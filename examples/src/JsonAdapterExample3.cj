package examples

import std.collection.*

// 导入相关依赖包
import cjjson.*
import cjjson.macros.*
import encoding.json.*

@JsonAdapter
public class MyData {
    public var a: Int64 = 0
    public var b: String = ""
}

@JsonAdapter[withGenericType = T]
public class Result<T> {
    public var data: ?T = None
}

func test_JsonAdapter3() {
    println("---------- test_JsonAdapter3 ----------")

    let input = #"{"data":{"a":123,"b":"hello"}}"#
    let res = Result<MyData>.fromJson(input)
    println(res.toJson()) // 输出：{"data":{"a":123,"b":"hello"}}
}