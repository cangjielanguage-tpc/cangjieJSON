package cjjson
 
import cjjson.stream.*

// 用于表示任意类型。
public class AnyType <: IJsonAdapter<AnyType> & IStreamJsonAdapter<AnyType> {
    public var jsonValue: JsonValue = JsonNull()
    public var jsonValueStream: Any = 0 

    public init(value: JsonValue){
        this.jsonValue = value
    }

    public init(){}

    public func isArray(): Bool {
        if (let JsonKind.JsArray <- jsonValue.kind()) {
            return true
        }
        return false
    }

    public func isBool(): Bool {
        if (let JsonKind.JsBool <- jsonValue.kind()) {
            return true
        }
        return false
    }

    public func isFloat(): Bool {
        if (let JsonKind.JsFloat <- jsonValue.kind()) {
            return true
        }
        return false
    }

    public func isInt(): Bool {
        if (let JsonKind.JsInt <- jsonValue.kind()) {
            return true
        }
        return false
    }

    public func isNull(): Bool {
        if (let JsonKind.JsNull <- jsonValue.kind()) {
            return true
        }
        return false
    }

    public func isObject(): Bool {
        if (let JsonKind.JsObject <- jsonValue.kind()) {
            return true
        }
        return false
    }

    public func isString(): Bool {
        if (let JsonKind.JsString <- jsonValue.kind()) {
            return true
        }
        return false
    }

    // 如果类型不匹配，会抛出异常。
    public func getValue<T>(): T where T <: IJsonAdapter<T> {
        try {
            T.deserialize(DataModel.fromJson(jsonValue))
        } catch (e: DataModelException) {
            throw JsonGetValueException("AnyType.getValue<T>() failed: ${e.message}")
        }
    }

    public static func deserialize(dataModel: DataModel): AnyType {
        let obj = AnyType()
        obj.jsonValue = dataModel.toJson()
        return obj
    }

    public func serialize(): DataModel {
        return DataModel.fromJson(jsonValue)
    }

    public static func fromJson(str: String): AnyType {
        let obj = AnyType()
        obj.jsonValue = JsonValue.fromStr(str)
        return obj
    }
    public func toJson(): String {
        return jsonValue.toString()
    }

    public func toJson(writer: JsonStreamWriter) {
        JsonUtil.toModelStream(jsonValueStream, writer)
    }

    public static func fromJson(reader: JsonStreamReader): AnyType {
        let obj = AnyType()
        obj.jsonValueStream =  JsonUtil.streamFromJsonForAny(reader)
        return obj
    }

}
