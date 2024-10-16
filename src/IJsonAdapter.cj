package cjjson

public import encoding.json.*
public import encoding.json.JsonNull
public import serialization.serialization.*

public interface IJsonAdapter<T> <: Serializable<T> {
    static func fromJson(str: String): T
    func toJson(): String
}
