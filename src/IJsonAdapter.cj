package cjjson

public import stdx.encoding.json.*
public import stdx.serialization.serialization.* 
public import std.io.*
public import cjjson.stream.*

public interface IJsonAdapter<T> <: Serializable<T> & ISerialize {
    static func fromJson(str: String): T
    func toJson(): String
}

public interface  IStreamJsonAdapter<T> <:JsonStreamDeserializable<T> & JsonStreamSerializable {

    public func toStreamJson(): String {
        let stream = ByteBuffer()
        var writer = JsonStreamWriter(stream)
        toJson(writer)
        writer.flush()
        return String.fromUtf8(readToEnd(stream))
    }
    
    static func fromStreamJson(str: String): T {
        fromJson(JsonStreamReader(ByteBuffer(str.toArray())))
    }
}