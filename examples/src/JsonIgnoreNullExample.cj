package examples

import std.collection.*

// 导入相关依赖包
import cjjson.*
import cjjson.macros.*
import encoding.json.*

@JsonAdapter
public class IgnoreNullExample {
    // @JsonIgnoreNull 可以用于修饰非Option类型的成员，但是不会有效果
    @JsonIgnoreNull
    public var a: Int64 = 0

    @JsonIgnoreNull
    public var b: Option<Int64> = 0

    @JsonIgnoreNull
    public var c: Option<String> = ""

    @JsonIgnoreNull
    public var d: Option<ArrayList<Int64>> = None

    @JsonIgnoreNull
    public var e: Option<ArrayList<String>> = None
}

func test_JsonIgnoreNull() {
    println("---------- test_JsonIgnoreNull ----------")
    println("case 1 > ")
    // 如果 JSON 字符串中的值为 null，经过反序列化后，再序列化时该字段会被忽略
    let input = #"{"a":1,"b":null,"c":"ccc","d":[4,5,6],"e":null}"#
    let expectOutput = #"{"a":1,"c":"ccc","d":[4,5,6]}"#
    println("  input  = " + input)
    println("  expect = " + expectOutput)
    println("  actual = " + IgnoreNullExample.fromJson(input).toJson())

    // 如果 JSON 字符串中没有对应的字段，经过反序列化后，再序列化时该字段会被忽略
    println("case 2 > ")
    let input2 = #"{"a":1}"#
    let expectOutput2 = #"{"a":1}"#
    println("  input  = " + input2)
    println("  expect = " + expectOutput2)
    println("  actual = " + IgnoreNullExample.fromJson(input2).toJson())
}