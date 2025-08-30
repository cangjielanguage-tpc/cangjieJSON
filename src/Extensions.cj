package cjjson

import std.collection.*
import stdx.encoding.json.*
import std.convert.*

extend Int64 <: IJsonAdapter<Int64> {
    public static func fromJson(str: String): Int64 {
        let dataModel = DataModel.fromJson(JsonValue.fromStr(str))
        match (dataModel) {
        	case d :DataModelInt => Int64.deserialize(dataModel)
        	case d: DataModelString => Int64.parse(String.deserialize(dataModel))
            case _ => throw createExp("Int64", str)
        }
    }

    public func toJson(): String {
        return this.toString()
    }
}

extend Int32 <: IJsonAdapter<Int32> {
    public static func fromJson(str: String): Int32 {
        let dataModel = DataModel.fromJson(JsonValue.fromStr(str))
        match (dataModel) {
        	case d :DataModelInt => Int32.deserialize(dataModel)
        	case d: DataModelString => Int32.parse(String.deserialize(dataModel))
            case _ => throw createExp("Int32", str)
        }
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend Int16 <: IJsonAdapter<Int16> {
    public static func fromJson(str: String): Int16 {
        let dataModel = DataModel.fromJson(JsonValue.fromStr(str))
        match (dataModel) {
        	case d :DataModelInt => Int16.deserialize(dataModel)
        	case d: DataModelString => Int16.parse(String.deserialize(dataModel))
            case _ => throw createExp("Int16", str)
        }
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend Int8 <: IJsonAdapter<Int8> {
    public static func fromJson(str: String): Int8 {
        let dataModel = DataModel.fromJson(JsonValue.fromStr(str))
        match (dataModel) {
        	case d :DataModelInt => Int8.deserialize(dataModel)
        	case d: DataModelString => Int8.parse(String.deserialize(dataModel))
            case _ => throw createExp("Int8", str)
        }
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend UInt64 <: IJsonAdapter<UInt64> {
    public static func fromJson(str: String): UInt64 {
        let dataModel = DataModel.fromJson(JsonValue.fromStr(str))
        match (dataModel) {
        	case d :DataModelInt => UInt64.deserialize(dataModel)
        	case d: DataModelString => UInt64.parse(String.deserialize(dataModel))
            case _ => throw createExp("UInt64", str)
        }
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend UInt32 <: IJsonAdapter<UInt32> {
    public static func fromJson(str: String): UInt32 {
        let dataModel = DataModel.fromJson(JsonValue.fromStr(str))
        match (dataModel) {
        	case d :DataModelInt => UInt32.deserialize(dataModel)
        	case d: DataModelString => UInt32.parse(String.deserialize(dataModel))
            case _ => throw createExp("UInt32", str)
        }
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend UInt16 <: IJsonAdapter<UInt16> {
    public static func fromJson(str: String): UInt16 {
        let dataModel = DataModel.fromJson(JsonValue.fromStr(str))
        match (dataModel) {
        	case d :DataModelInt => UInt16.deserialize(dataModel)
        	case d: DataModelString => UInt16.parse(String.deserialize(dataModel))
            case _ => throw createExp("UInt16", str)
        }
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend UInt8 <: IJsonAdapter<UInt8> {
    public static func fromJson(str: String): UInt8 {
        let dataModel = DataModel.fromJson(JsonValue.fromStr(str))
        match (dataModel) {
        	case d :DataModelInt => UInt8.deserialize(dataModel)
        	case d: DataModelString => UInt8.parse(String.deserialize(dataModel))
            case _ => throw createExp("UInt8", str)
        }
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend Float64 <: IJsonAdapter<Float64> {
    public static func fromJson(str: String): Float64 {
        let dataModel = DataModel.fromJson(JsonValue.fromStr(str))
        match (dataModel) {
        	case d :DataModelFloat => Float64.deserialize(dataModel)
            case d :DataModelInt => Float64.deserialize(dataModel)
        	case d: DataModelString => Float64.parse(String.deserialize(dataModel))
            case _ => throw createExp("Float64", str)
        }
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend Float32 <: IJsonAdapter<Float32> {
    public static func fromJson(str: String): Float32 {
        let dataModel = DataModel.fromJson(JsonValue.fromStr(str))
        match (dataModel) {
        	case d :DataModelFloat => Float32.deserialize(dataModel)
            case d :DataModelInt => Float32.deserialize(dataModel)
        	case d: DataModelString => Float32.parse(String.deserialize(dataModel))
            case _ => throw createExp("Float32", str)
        }
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend Float16 <: IJsonAdapter<Float16> {
    public static func fromJson(str: String): Float16 {
        let dataModel = DataModel.fromJson(JsonValue.fromStr(str))
        match (dataModel) {
        	case d :DataModelFloat => Float16.deserialize(dataModel)
            case d :DataModelInt => Float16.deserialize(dataModel)
        	case d: DataModelString => Float16.parse(String.deserialize(dataModel))
            case _ => throw createExp("Float16", str)
        }
    }
    public func toJson(): String {
        return this.toString()
    }
}

extend String <: IJsonAdapter<String> {
    public static func fromJson(str: String): String {
//        let dm = DataModel.fromJson(JsonValue.fromStr(str))
//        match (dm) {
//        	case dmInt: DataModelInt => Int64.deserialize(dm).toString()
//            case _ => String.deserialize(dm)
//        }
        return String.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.serialize().toJson().toString()
    }
}

extend Rune <: IJsonAdapter<Rune> {
    public static func fromJson(str: String): Rune {
        return Rune.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
    }
    public func toJson(): String {
        return this.serialize().toJson().toString()
    }
}

extend Bool <: IJsonAdapter<Bool> {
    public static func fromJson(str: String): Bool {
        let dm = DataModel.fromJson(JsonValue.fromStr(str))
        match (dm) {
        	case dmInt: DataModelInt => Int64.deserialize(dm) != 0
            case _ => Bool.deserialize(dm)
        }
//        return Bool.deserialize(DataModel.fromJson(JsonValue.fromStr(str)))
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

private func createExp(clazz: String, str: String):Exception {
    Exception("转化${clazz}失败: str: ${str}")
}
