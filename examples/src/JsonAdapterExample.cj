package examples

import std.collection.*

// 导入相关依赖包
import cjjson.*
import cjjson.macros.*
import encoding.json.*

/*
 * 定义基础的 JsonAdapterExample 数据类
 */
@JsonAdapter
public class JsonAdapterExample {
    public var a: Int64 = 0
    public var b: String = ""
    public var c: ?String = None
    public var d: Array<Int64> = Array<Int64>()
    public var e: ArrayList<String> = ArrayList<String>()
    public var f: HashMap<String, Int64> = HashMap<String, Int64>()
}

/*
 * 在 CollectionExample 数据类中，JsonAdapterExample 可以作为 Array、ArrayList、HashMap 等泛型类型的类型实参。
 */
@JsonAdapter
public class CollectionExample {
    public var list: ArrayList<JsonAdapterExample> = ArrayList()
    public var map: HashMap<String, JsonAdapterExample> = HashMap()
}

func test_JsonAdapter() {
    println("---------- test_JsonAdapter ----------")
    let input: String = #"
{
    "a": 123,
    "b": "bbbbb",
    "c": null,
    "d": [ 1, 2, 3 ],
    "e": [ "s1", "s2", "s3" ],
    "f": {
        "f1": 123,
        "f2": 456
    }
}"#
    let example = JsonAdapterExample.fromJson(input)
    println(example.toJson())

    let input2: String = #"
{
    "list": [
        {
            "a": 123,
            "b": "bbbbb",
            "c": null,
            "d": [ 1, 2, 3 ],
            "e": [ "s1", "s2", "s3" ],
            "f": {
                "f1": 123,
                "f2": 456
            }
        },
        {
            "a": 456,
            "b": "xxx",
            "c": "I'm not null",
            "d": [ 7, 8, 9 ],
            "e": [ "s4", "s5", "s6" ],
            "f": {
                "f3": 100,
                "f4": 200
            }
        }
    ],
    "map": {
        "key1": {
            "a": 123,
            "b": "bbbbb",
            "c": null,
            "d": [ 1, 2, 3 ],
            "e": [ "s1", "s2", "s3" ],
            "f": {
                "f1": 123,
                "f2": 456
            }
        },
        "key2": {
            "a": 456,
            "b": "xxx",
            "c": "I'm not null",
            "d": [ 7, 8, 9 ],
            "e": [ "s4", "s5", "s6" ],
            "f": {
                "f3": 100,
                "f4": 200
            }
        }
    }
}"#

    let collection = CollectionExample.fromJson(input2)
    println(collection.toJson())
}