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
public class Simple {
    public var code: Int64 = 0
    public var message: String = ""

    public init() {}
    public init(code: Int64, message: String) {
        this.code = code
        this.message = message
    }
}

// 在其他 @JsonAdapter 修饰的类中，可以使用 Simple 作为成员变量类型，或者 Array、ArrayList、HashSet、HashMap 的泛型类型。
@JsonAdapter
public class NestedSimple {
    public var data: Simple = Simple()
    public var optData: Option<Simple> = None
    public var array: Array<Simple> = Array()
    public var map: HashMap<String, Simple> = HashMap()
}

@Test
class NestedClassTest {
    @TestCase
    func fromJson() {
        let input = #"
        {
            "data": { "code":123, "message":"hello" },
            "optData": null,
            "array": [
                { "code":1, "message": "hello" },
                { "code":2, "message": "cangjie" },
                { "code":3, "message": "!"}
            ],
            "map": {
                "key1": { "code":10, "message":"value1" },
                "key2": { "code":11, "message":"value2" }
            }
        }
        "#
        let ns = NestedSimple.fromJson(input)
        @Assert(ns.data.code, 123)
        @Assert(ns.data.message, "hello")
        @Assert(ns.optData.isNone())
        @Assert(ns.array[0].code == 1 && ns.array[0].message == "hello")
        @Assert(ns.array[1].code == 2 && ns.array[1].message == "cangjie")
        @Assert(ns.array[2].code == 3 && ns.array[2].message == "!")
        @Assert(ns.map.contains("key1"))
        @Assert(ns.map.contains("key2"))
        let value1 = ns.map.get("key1").getOrThrow()
        let value2 = ns.map.get("key2").getOrThrow()
        @Assert(value1.code == 10 && value1.message == "value1")
        @Assert(value2.code == 11 && value2.message == "value2")
    }

    @TestCase
    func toJson() {
        let ns = NestedSimple()
        ns.data = Simple(1, "hello")
        ns.optData = Simple(2, "cangjie")
        ns.array = [Simple(3, "333"), Simple(4, "444")]
        ns.map = HashMap([("key1", Simple(5, "555"))])
        let expectJson = #"{"data":{"code":1,"message":"hello"},"optData":{"code":2,"message":"cangjie"},"array":[{"code":3,"message":"333"},{"code":4,"message":"444"}],"map":{"key1":{"code":5,"message":"555"}}}"#
        @Assert(ns.toJson(), expectJson)
    }
}
