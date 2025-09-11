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
func JsonName_UseOldName() {
    let input = #"{"newName":""}"#
    @Assert(NewNameClass().toStreamJson(), input)
    @Assert(NewNameClass().toJson(), input)
}

@Test
func JsonName_UseNewName() {
    let input = #"{"newName":"123"}"#
    @Assert(NewNameClass.fromStreamJson(input).toStreamJson(), input)
    @Assert(NewNameClass.fromJson(input).toJson(), input)
}
