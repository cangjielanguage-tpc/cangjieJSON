package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*
import cjjson.*
import cjjson.macros.*
import std.collection.*

@JsonAdapter
public class AnyTypeExample {
    public var data: HashMap<String, AnyType> = HashMap()
}

@JsonAdapter
public class MyObject {
    public var a: Int64 = 0
    public var b: String = ""
    public var c: AnyType = AnyType()
}

@Test
func AnyType_BasicTest() {
    let input = #"
    {
        "data": {
            "bool_value": true,
            "int_value": 123,
            "float_value": 3.1415,
            "string_value": "cangjie",
            "null_value": null,
            "array_value": [1, 2, 3],
            "object_value": {
                "a": 456,
                "b": "level-1",
                "c": {
                    "a": 789,
                    "b": "level-2"
                }
            }
        }
    }"#
    let obj = AnyTypeExample.fromJson(input)

    let bool_value = obj.data.get("bool_value").getOrThrow()
    @Assert(bool_value.isBool())
    @Assert(bool_value.getValue<Bool>(), true)

    let int_value = obj.data.get("int_value").getOrThrow()
    @Assert(int_value.isInt())
    @Assert(int_value.getValue<Int64>(), 123)

    let float_value = obj.data.get("float_value").getOrThrow()
    @Assert(float_value.isFloat())
    @Assert(float_value.getValue<Float64>(), 3.1415)

    let string_value = obj.data.get("string_value").getOrThrow()
    @Assert(string_value.isString())
    @Assert(string_value.getValue<String>(), "cangjie")

    let null_value = obj.data.get("null_value").getOrThrow()
    @Assert(null_value.isNull())

    let array_value = obj.data.get("array_value").getOrThrow()
    @Assert(array_value.isArray())
    @Assert(array_value.getValue<Array<Int64>>(), [1,2,3])

    let object_value = obj.data.get("object_value").getOrThrow()
    @Assert(object_value.isObject())

    let object = object_value.getValue<MyObject>()
    @Assert(object.a, 456)
    @Assert(object.b, "level-1")
    @Assert(object.c.isObject())
    let object_c = object.c.getValue<MyObject>()
    @Assert(object_c.a, 789)
    @Assert(object_c.b, "level-2")
    @Assert(object_c.c.isNull())
}
