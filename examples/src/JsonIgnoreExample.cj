package examples

import std.collection.*

// 导入相关依赖包
import cjjson.*
import cjjson.macros.*
import encoding.json.*


// IgnoreClass 没有使用 @JsonAdapter 修饰
public class IgnoreClass {
    public var str = ""
    public var val = 123
}

@JsonAdapter
public class JsonIgnoreExample {
    // 使用 @JsonIgnore 修饰的成员将不参与序列化和反序列化
    @JsonIgnore
    public var a: Int64 = 0

    // static 成员必须使用 @JsonIgnore 修饰
    @JsonIgnore
    public static var sa: Int64 = 0

    // private 成员必须使用 @JsonIgnore 修饰
    @JsonIgnore
    private var pa: Int64 = 0

    // 使用 @JsonIgnore 修饰成员，其类型无需满足 IJsonAdapter 接口约束
    @JsonIgnore
    public var b: IgnoreClass = IgnoreClass()  

    public var c: Int64 = 0
}

func test_JsonIgnore() {
    println("---------- test_JsonIgnore ----------")
    let input = #"
    {
        "a": 1,
        "sa": 2,
        "pa": 3,
        "b": {
            "str": "sss",
            "val":456
        },
        "c":789
    }"#
    println(JsonIgnoreExample.fromJson(input).toJson())
}