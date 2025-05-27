package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*

import cjjson.*
import cjjson.macros.*
import std.collection.*

@JsonAdapter
public class NewNameClass {
    @JsonName["newName"]
    public var name: String = ""
}

@Test
class JsonNameTest {
    @TestCase
    func useOldName() {
        let input = #"{"name":"123"}"#
        @ExpectThrows[JsonFieldNotExist](NewNameClass.fromJson(input))
    }

    @TestCase
    func useNewName() {
        let input = #"{"newName":"123"}"#
        let obj = NewNameClass.fromJson(input)
        @Assert(obj.name, "123")
    }
}