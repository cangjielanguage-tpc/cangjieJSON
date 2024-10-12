package examples

import std.collection.*

import cjjson.*
import cjjson.macros.*
import encoding.json.*

@JsonAdapter
public class Basic <: ToString {
    public var a: Int64 = 0
    public var b: String = ""
    public var c: ?String = None
    public var d: Array<Int64> = Array<Int64>()
    public var e: ArrayList<String> = ArrayList<String>()
    public var f: HashMap<String, Int64> = HashMap<String, Int64>()

    public func toString(): String {
        return"""
Basic:
    a = ${a}
    b = ${b}
    c = ${c}
    d = ${d}
    e = ${e}
    f = ${f}
"""
    }
}

@JsonAdapter
public class Parent <: ToString {
    public var list: ArrayList<Basic> = ArrayList()

    public func toString(): String {
        return "list = ${list}"
    }
}

main(): Int64 {
    let input: String = "{\"a\":123,\"b\":\"bbbbb\",\"c\":null,\"d\":[1,2,3],\"e\":[\"s1\",\"s2\",\"s3\"],\"f\":{\"f1\":123,\"f2\":456}}"
    let b = Basic.fromJson(input)
    println(b.toString())
    println(b.toJson())

    let input2: String = "{\"list\": [{\"a\":123,\"b\":\"bbbbb\",\"c\":null,\"d\":[1,2,3],\"e\":[\"s1\",\"s2\",\"s3\"],\"f\":{\"f1\":123,\"f2\":456}}]}"
    let p = Parent.fromJson(input2)
    println(p.toString())
    println(p.toJson())
    return 0
}