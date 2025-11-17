/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*
import cjjson.*
import std.collection.*

@Test
class JsonValueExtendTest {
    @TestCase
    func checkKind() {
        let jv1 = JsonValue.fromStr("true")
        @Assert(jv1.isBool())

        let jv2 = JsonValue.fromStr("123")
        @Assert(jv2.isInt())

        let jv3 = JsonValue.fromStr("3.14")
        @Assert(jv3.isFloat())

        let jv4 = JsonValue.fromStr("\"hello world\"")
        @Assert(jv4.isString())

        let jv5 = JsonValue.fromStr(#"{"msg":"hello"}"#)
        @Assert(jv5.isObject())

        let jv6 = JsonValue.fromStr(#"[1, 2, 3]"#)
        @Assert(jv6.isArray())

        let jv7 = JsonValue.fromStr("null")
        @Assert(jv7.isNull())
    }

    @TestCase
    func setAndGet() {
        let jsonObj = JsonObject()
        // 写入应该成功
        @Assert(jsonObj.setBoolValue("bool", true))
        @Assert(jsonObj.setIntValue("int", 123))
        @Assert(jsonObj.setFloatValue("float", 3.125))
        @Assert(jsonObj.setStringValue("str", "hello"))
        let newObj = JsonObject()
        @Assert(newObj.setStringValue("data", "this is data"))
        @Assert(jsonObj.setObjectValue("obj", newObj))
        @Assert(jsonObj.setArrayValue("array", [JsonBool(true), JsonInt(100), JsonString("yoyo")]))
        @Assert(jsonObj.setNullValue("optData"))
        @Assert(jsonObj.setJsonValue("json_value", JsonString("this is a json string")))

        // 再读取
        @Assert(jsonObj.getBoolValue("bool"), true)
        @Assert(jsonObj.getIntValue("int"), 123)
        @Assert(jsonObj.getFloatValue("float"), 3.125)
        @Assert(jsonObj.getStringValue("str"), "hello")
        let readObj = jsonObj.getJsonObject("obj")
        @Assert(readObj.getStringValue("data"), "this is data")
        let readArr = jsonObj.getArrayValue("array")
        @Assert(readArr[0].asBool().getValue(), true)
        @Assert(readArr[1].asInt().getValue(), 100)
        @Assert(readArr[2].asString().getValue(), "yoyo")
        let readNull = jsonObj.get("optData").getOrThrow()
        @Assert(readNull is JsonNull)
        let readValue = jsonObj.getJsonValue("json_value")
        @Assert(readValue.asString().getValue(), "this is a json string")
    }

    @TestCase
    func invalidSetAndGet() {
        let jv: JsonValue = JsonString("haha")

        // 写入应该失败
        @Assert(jv.setBoolValue("bool", true), false)
        @Assert(jv.setIntValue("int", 123), false)
        @Assert(jv.setFloatValue("float", 3.125), false)
        @Assert(jv.setStringValue("str", "yoyo"), false)
        @Assert(jv.setObjectValue("obj", JsonObject()), false)
        @Assert(jv.setArrayValue("array", []), false)
        @Assert(jv.setNullValue("optData"), false)
        @Assert(jv.setJsonValue("json_value", JsonInt(0)), false)

        // 获取应该失败，取得默认值
        @Assert(jv.getBoolValue("bool", default: true), true)
        @Assert(jv.getIntValue("int", default: -1), -1)
        @Assert(jv.getFloatValue("float", default: 5.125), 5.125)
        @Assert(jv.getStringValue("str", default: "nothing"), "nothing")
        // 提供一个有一个 null 值的数组作为默认值
        let readArr = jv.getArrayValue("array", default: [JsonNull()])
        @Assert(readArr.size, 1)
        @Assert(readArr[0].isNull())
        // 提供一个有一个 key 值的对象作为默认值
        let defaultObj = JsonObject(HashMap<String, JsonValue>([("key", JsonString("value"))]))
        let readObj = jv.getJsonObject("obj", default: defaultObj)
        @Assert(readObj.getStringValue("key"), "value")
        // 提供一个 JsonBool 作为默认值
        let readValue = jv.getJsonValue("json_value", default: JsonBool(false))
        @Assert(readValue.asBool().getValue(), false)
    }
}
