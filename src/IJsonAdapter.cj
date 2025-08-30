package cjjson

public import stdx.encoding.json.*
public import stdx.serialization.serialization.*

public interface IJsonAdapter<T> <: Serializable<T> & ISerialize {
    static func fromJson(str: String): T
    func toJson(): String
}
