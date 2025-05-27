package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*
import cjjson.*
import cjjson.macros.*
import std.collection.*

// 支持多种类型
@JsonAdapter
public class Basic {
    // 支持所有整数类型
    public var i8: Int8 = 0
    public var i16: Int16 = 0
    public var i32: Int32 = 0
    public var i64: Int64 = 0
    public var u8: UInt8 = 0
    public var u16: UInt16 = 0
    public var u32: UInt32 = 0
    public var u64: UInt64 = 0

    // 支持所有的整数类型
    public var f16: Float16 = 0.0
    public var f32: Float32 = 0.0
    public var f64: Float64 = 0.0

    // 支持Bool类型
    public var b: Bool = false

    // 支持String类型
    public var str: String = ""

    // 支持Option类型
    public var optNone: ?String = None
    public var optSome: ?Int64 = None

    // 支持 Array、ArrayList、HashSet类型（对应JSON Array）
    public var arr: Array<Int64> = Array()
    public var arrList: ArrayList<String> = ArrayList()
    public var hashSet: HashSet<Int64> = HashSet()

    // 支持 HashMap 类型（对应JSON Object类型）
    public var hashMap: HashMap<String, String> = HashMap()

    // 支持 AnyType 类型（对应任意的JSON值）
    public var any: AnyType = AnyType()
}



@Test
class BasicTest {
    @TestCase
    func fromJson() {
        let input = #"
            {
                "i8": 127,
                "i16": -32768,
                "i32": 2147483647,
                "i64": 9223372036854775807,
                "u8": 255,
                "u16": 65535,
                "u32": 4294967295,
                "u64": 9223372036854775807,
                "f16": 1.5,
                "f32": 3.1415927,
                "f64": 2.718281828459045,
                "b": true,
                "str": "Hello, World!",
                "optNone": null,
                "optSome": 42,
                "arr": [
                    1,
                    2,
                    3,
                    4
                ],
                "arrList": [
                    "apple",
                    "banana",
                    "orange"
                ],
                "hashSet": [
                    100,
                    101
                ],
                "hashMap": {
                    "key1": "value1",
                    "key2": "value2"
                },
                "any": {
                    "nested": {
                        "data": [
                            1,
                            "two",
                            false
                        ],
                        "info": "This is any type data"
                    }
                }
            }
            "#
        let b = Basic.fromJson(input)
        @Assert(b.i8, 127)
        @Assert(b.i16, -32768)
        @Assert(b.i32, 2147483647)
        @Assert(b.i64, 9223372036854775807)
        @Assert(b.u8, 255)
        @Assert(b.u16, 65535)
        @Assert(b.u32, 4294967295)
        @Assert(b.u64, 9223372036854775807) // JsonInt对应的类型是 Int64，所以值不能超过 Int64.MAX
        @Assert(b.f16, 1.5)
        @Assert(b.f32, 3.1415927)
        @Assert(b.f64, 2.718281828459045)
        @Assert(b.b, true)
        @Assert(b.str, "Hello, World!")
        @Assert(b.optNone.isNone())
        @Assert(b.optSome.getOrThrow(), 42)
        @Assert(b.arr.size, 4)
        @Assert(b.arr[0], 1)
        @Assert(b.arr[1], 2)
        @Assert(b.arr[2], 3)
        @Assert(b.arr[3], 4)
        @Assert(b.arrList.size, 3)
        @Assert(b.arrList[0], "apple")
        @Assert(b.arrList[1], "banana")
        @Assert(b.arrList[2], "orange")
        @Assert(b.hashSet.size, 2)
        @Assert(b.hashSet.contains(100))
        @Assert(b.hashSet.contains(101))
        @Assert(b.hashMap.size, 2)
        @Assert(b.hashMap.contains("key1"))
        @Assert(b.hashMap.contains("key2"))
        @Assert(b.hashMap.get("key1").getOrThrow(), "value1")
        @Assert(b.hashMap.get("key2").getOrThrow(), "value2")
        @Assert(b.any.isObject())
        let anyObj = b.any.jsonValue
        let nested = anyObj.getJsonObject("nested")
        let data = nested.getArrayValue("data")
        @Assert(data.size, 3)
        @Assert(data[0].asInt().getValue(), 1)
        @Assert(data[1].asString().getValue(), "two")
        @Assert(data[2].asBool().getValue(), false)
        @Assert(nested.getStringValue("info"), "This is any type data")
    }

    @TestCase
    func toJson() {
        let b = Basic()
        b.i8 = 1
        b.i16 = -2
        b.i32 = 3
        b.i64 = -4
        b.u8 = 5
        b.u16 = 6
        b.u32 = 7
        b.u64 = 8
        b.f16 = 16.5 // 二进制中是有限位数的浮点数可以精确存储，没有精度丢失
        b.f32 = 32.25 // 二进制中是有限位数的浮点数可以精确存储，没有精度丢失
        b.f64 = 64.125 // 二进制中是有限位数的浮点数可以精确存储，没有精度丢失
        b.b = true
        b.str = "Hello, Cangjie!"
        b.optNone = None
        b.optSome = 9
        b.arr = [10, 11, 12]
        b.arrList = ArrayList<String>(["one", "two", "three"])
        b.hashSet = HashSet([20, 21, 22, 23, 24, 25])
        b.hashMap = HashMap([
            ("key1", "value1"),
            ("key2", "value2"),
            ("key3", "value3")
        ])
        let anyObj = JsonObject()
        anyObj.put("data", JsonArray([JsonInt(100), JsonString("success"), JsonBool(true)]))
        anyObj.put("error", JsonString("succeed"))
        b.any = AnyType(anyObj)
        let expectJson = #"{"i8":1,"i16":-2,"i32":3,"i64":-4,"u8":5,"u16":6,"u32":7,"u64":8,"f16":16.5,"f32":32.25,"f64":64.125,"b":true,"str":"Hello, Cangjie!","optNone":null,"optSome":9,"arr":[10,11,12],"arrList":["one","two","three"],"hashSet":[20,21,22,23,24,25],"hashMap":{"key1":"value1","key2":"value2","key3":"value3"},"any":{"data":[100,"success",true],"error":"succeed"}}"#
        @Assert(b.toJson(), expectJson)
    }
}
