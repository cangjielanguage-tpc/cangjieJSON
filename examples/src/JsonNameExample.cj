package examples

import std.collection.*

// 导入相关依赖包
import cjjson.*
import cjjson.macros.*
import encoding.json.*

@JsonAdapter
public class JsonNameExample {
    @JsonName["newName"]
    public var name: String = ""
}

func test_JsonName() {
    println("---------- test_JsonAdapter ----------")
    let input = #"{"name": "123"}"#

    try {
        JsonNameExample.fromJson(input)
    } catch (e: Exception) {
        println("Alright, we got an exception: ${e.message}.")
        e.printStackTrace()
        println("But don't worry, this exception is normal")
    }

    let input2 = #"{"newName": "123"}"#
    println(JsonNameExample.fromJson(input2).toJson())
}