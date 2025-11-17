/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
package cjjson.test

import cjjson.*
import cjjson.macros.*
import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import stdx.encoding.json.*

@Test
class JsonKindTest {
    @TestCase
    func jsonKindObj() {
        var jobj = JsonObject()
        jobj.put("a", JsonString("jjjjjj"))
        jobj.put("b", JsonInt(123))
        var kind = jobj.kind().toString()
        @Assert(kind,"JSON Object")
    }

    @TestCase
    func jsonKindInt() {
        var jint = JsonInt(123)
        var kind = jint.kind().toString()
        @Assert(kind,"JSON Int")
    }

    @TestCase
    func jsonKindFloat() {
        var jfloat = JsonFloat(123.12)
        var kind = jfloat.kind().toString()
        @Assert(kind,"JSON Float")
    }

    @TestCase
    func jsonKindBool() {
        var jbool = JsonBool(true)
        var kind = jbool.kind().toString()
        @Assert(kind,"JSON Bool")
    }

    @TestCase
    func jsonKindNull() {
        var jnull = JsonNull()
        var kind = jnull.kind().toString()
        @Assert(kind,"JSON null")
    }

    @TestCase
    func jsonKindArray() {
        var jarray = JsonArray()
        jarray.add(JsonInt(123))
        jarray.add(JsonFloat(123.12))
        jarray.add(JsonBool(true))
        var kind = jarray.kind().toString()
        @Assert(kind,"JSON Array")
    }
}
