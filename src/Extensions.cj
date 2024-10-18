package cjjson

import std.collection.*
import encoding.json.*

extend Int64 <: IJsonAdapter<Int64> {
    public static func fromJson(str: String): Int64 {
        return Int64.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend Int32 <: IJsonAdapter<Int32> {
    public static func fromJson(str: String): Int32 {
        return Int32.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend Int16 <: IJsonAdapter<Int16> {
    public static func fromJson(str: String): Int16 {
        return Int16.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend Int8 <: IJsonAdapter<Int8> {
    public static func fromJson(str: String): Int8 {
        return Int8.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend UInt64 <: IJsonAdapter<UInt64> {
    public static func fromJson(str: String): UInt64 {
        return UInt64.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend UInt32 <: IJsonAdapter<UInt32> {
    public static func fromJson(str: String): UInt32 {
        return UInt32.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend UInt16 <: IJsonAdapter<UInt16> {
    public static func fromJson(str: String): UInt16 {
        return UInt16.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend UInt8 <: IJsonAdapter<UInt8> {
    public static func fromJson(str: String): UInt8 {
        return UInt8.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend Float64 <: IJsonAdapter<Float64> {
    public static func fromJson(str: String): Float64 {
        return Float64.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend Float32 <: IJsonAdapter<Float32> {
    public static func fromJson(str: String): Float32 {
        return Float32.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend Float16 <: IJsonAdapter<Float16> {
    public static func fromJson(str: String): Float16 {
        return Float16.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend String <: IJsonAdapter<String> {
    public static func fromJson(str: String): String {
        return String.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend Rune <: IJsonAdapter<Rune> {
    public static func fromJson(str: String): Rune {
        return Rune.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend Bool <: IJsonAdapter<Bool> {
    public static func fromJson(str: String): Bool {
        return Bool.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend<T> Option<T> <: IJsonAdapter<Option<T>> where T <: IJsonAdapter<T> {
    public static func fromJson(str: String): Option<T> {
        let dm = DataModel.fromJson(JsonValue.fromStr(str))
        return Option<T>.deserialize(dm)
    }
    public func toJson(): String {
        return this.serialize().toJson().toString()
    }
}

extend<T> Array<T> <: IJsonAdapter<Array<T>> where T <: IJsonAdapter<T> {
    public static func fromJson(str: String): Array<T> {
        let dm = DataModel.fromJson(JsonValue.fromStr(str))
        return Array<T>.deserialize(dm)
    }
    public func toJson(): String {
        return this.serialize().toJson().toString()
    }
}

extend<T> ArrayList<T> <: IJsonAdapter<ArrayList<T>> where T <: IJsonAdapter<T> {
    public static func fromJson(str: String): ArrayList<T> {
        let dm = DataModel.fromJson(JsonValue.fromStr(str))
        return ArrayList<T>.deserialize(dm)
    }
    public func toJson(): String {
        return this.serialize().toJson().toString()
    }
}

extend<T> HashSet<T> <: IJsonAdapter<HashSet<T>> where T <: IJsonAdapter<T> & Hashable & Equatable<T> {
    public static func fromJson(str: String): HashSet<T> {
        let dm = DataModel.fromJson(JsonValue.fromStr(str))
        return HashSet<T>.deserialize(dm)
    }
    public func toJson(): String {
        return this.serialize().toJson().toString()
    }
}

extend<K, V> HashMap<K, V> <: IJsonAdapter<HashMap<K, V>> where K <: Hashable & Equatable<K> & IJsonAdapter<K>, V <: IJsonAdapter<V> {
    public static func fromJson(str: String): HashMap<K, V> {
        let dm = DataModel.fromJson(JsonValue.fromStr(str))
        return HashMap<K, V>.deserialize(dm)
    }
    public func toJson(): String {
        return this.serialize().toJson().toString()
    }
}
