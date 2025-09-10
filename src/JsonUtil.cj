/**
 * Created on 2025/3/30
 */
package cjjson

import std.collection.*
import stdx.encoding.json.*
import std.convert.*
import cjjson.stream.*


public interface ISerialize {
    func serialize(): DataModel
}

public class JsonUtil {

    public static func toJsonString(obj: Any): ?String {
        return toModel(obj)?.toJson().toString() ?? None
    }

    /**
     * 将 Any 转为 DataModel
     *
     * 禁止套娃：
     * ```cangjie
     *     let map = HashMap<String, Any>()
     *     map.add("map", map) // Map 套娃
     *
     *     let arr = Array<Any>([1, 2.2, "3", Option<Any>.None])
     *     arr[3] = arr        // Array 套娃
     *
     *     let list = ArrayList<Any>()
     *     list.append(list)   // List 套娃
     * ```
     *
     * @param parentNode - 上层节点对象，用于判断是否套娃
     * @param value - 待解析的对象
     */
    public static func toModel(obj: Any, parent!: ?Any = None): ?DataModel {
        return match (obj) {
            case v: ISerialize  => v.serialize()
            case v: Option<Any> => match (v) {
                case Some(v) => toModel(v, parent: obj) ?? return None
                case None    => DataModelNull()
            }
            case v: Collection<Any> =>
                if (checkRefEq(v, parent)) {
                    return None // 禁止套娃
                }
                let dms = DataModelSeq()
                for (item in v) {
                    let model = toModel(item, parent: obj) ?? return None
                    dms.add(model)
                }
                dms
            case v: Map<String, Any> =>
                if (checkRefEq(v, parent)) {
                    return None // 禁止套娃
                }
                let dms = DataModelStruct()
                for ((k,vv) in v) {
                    let model = toModel(vv, parent: obj) ?? return None
                    dms.add(Field(k, model))
                }
                dms
            case _ => None
        }
    }

    public static func checkRefEq(thisAny: Any, thatAny: ?Any): Bool {
        if (let Some(thatObj) <- thatAny) {
            if (let Some(thatObj) <- (thatObj as Object)) {
                if (let Some(thisObj) <- (thisAny as Object)) {
                    return refEq(thisObj, thatObj) // 判断对象是否相同
                }
            }
        }
        return false
    }

    public static func deserializeHashMapStringAny(dm: DataModel): HashMap<String, Any> {
        return parseStruct(dm as DataModelStruct ?? throw Exception("Excepect DataModelStruct to deserialize HashMap<String, Any>")) ?? throw Exception("Failed to deserialize HashMap<String, Any>")
    }
     public static func deserializeHashMapStringString(dm: DataModel): HashMap<String, String> {
        return parseForMapStringString(dm as DataModelStruct ?? throw Exception("Excepect DataModelStruct to deserialize HashMap<String, String>")) ?? throw Exception("Failed to deserialize HashMap<String, String>")
    }

    public static func deserializeArrayAny(dm: DataModel): Array<Any> {
        return parseSeq(dm as DataModelSeq ?? throw Exception("Excepect DataModelSeq to deserialize Array<Any>")) ?? throw Exception("Failed to deserialize Array<Any>")
    }

    public static func deserializeAny(dm: DataModel): Any {
        return parseModel(dm) ?? throw Exception("Failed to deserialize Any")
    }

    public static func parseStruct(dms: DataModelStruct): ?HashMap<String, Any> {
        let map = HashMap<String, Any>()
        for (i in dms.getFields()) {
            let key = i.getName()
            let v = parseModel(i.getData()) ?? return None // 字段无法反序列化，则整个 Map 无法反序列化
            map.add(key, v)
        }
        return map
    }

    public static func parseForMapStringString(dms: DataModelStruct): ?HashMap<String, String> {
        let map = HashMap<String, String>()
        for (i in dms.getFields()) {
            let key = i.getName()
            let v = parseModel(i.getData()) ?? return None // 字段无法反序列化，则整个 Map 无法反序列化
            let toStringValue = (v as ToString) ?? return None //字段无法toString，整个map无法反序列化
            map.add(key, toStringValue.toString())
        }
        return map
    }

    public static func parseSeq(dms: DataModelSeq): ?Array<Any> {
        let items = dms.getItems()
        let arr = Array<Any>(items.size, repeat: unsafe { zeroValue<Any>() })
        for (i in 0..arr.size) {
            arr[i] = parseModel(items[i]) ?? return None // 元素无法反序列化，则整个 Array 无法反序列化
        }
        return arr
    }

    public static func parseModel(dm: DataModel): ?Any {
        return match (dm) {
            case v: DataModelBool   => v.getValue()
            case v: DataModelInt    => v.getValue()
            case v: DataModelFloat  => v.getValue()
            case v: DataModelString => v.getValue()
            // case v: DataModelNull   => Some(Option<Any>.None) // 表示读到值，但值为 None, cjc bug 时而编译报错
            case v: DataModelSeq    => parseSeq(v) ?? None
            case v: DataModelStruct => parseStruct(v) ?? None
            case _ => None
        }
    }




public static func toModelStream (obj: Any, w:JsonStreamWriter, parent!: ?Any = None):Unit {
        return match (obj) {
            case v: JsonStreamSerializable  => v.toJson(w)
            case v: Option<Any> => match (v) {
                case Some(v) => toModelStream(v, w,parent: obj)
                case None    => var df = w.writeValue("null")
            }
            case v: Collection<Any> =>
                if (checkRefEq(v, parent)) {
                    return  // 禁止套娃
                }
                w.startArray()
                for (item in v) {
                    toModelStream(item, w,parent: obj)
                }
                w.endArray()
            case v: Map<String, Any> =>
                if (checkRefEq(v, parent)) {
                    return  // 禁止套娃
                }
                w.startObject()
                for ((key, value) in v) {
                     w.writeName(key)
                     toModelStream(value, w,parent: obj)
                }
                w.endObject()
            case _ => throw Exception("dddd")
        }
    }

    public static func toAnyStream (obj: ArrayList<Any>, w:JsonStreamWriter, parent!: ?Any = None):Unit {
        return match (obj) {
            case v: JsonStreamSerializable  => v.toJson(w)
            case v: Option<Any> => match (v) {
                case Some(v) => toModelStream(v, w,parent: obj)
                case None    => var df = w.writeValue("null")
            }
            case v: Collection<Any> =>
                if (checkRefEq(v, parent)) {
                    return  // 禁止套娃
                }
                w.startArray()
                for (item in v) {
                    toModelStream(item, w,parent: obj)
                }
                w.endArray()
            case v: Map<String, Any> =>
                if (checkRefEq(v, parent)) {
                    return  // 禁止套娃
                }
                w.startObject()
                for ((key, value) in v) {
                     w.writeName(key)
                     toModelStream(value, w,parent: obj)
                }
                w.endObject()
            case _ => throw Exception("dddd")
        }
    }

    public static func streamFromJsonForOptionAny(reader: JsonStreamReader): ?Any {
        var peek = reader.peek().getOrThrow()
        match (peek) {
            case BeginArray =>
                              var list = ArrayList<Any>()
                              reader.startArray()
                              while (let Some(v) <- reader.peek()) {
                                if (v != EndArray) {
                                    list.add(streamFromJsonForOptionAny(reader))
                                } else {
                                    break
                                }
                              }
                              reader.endArray()
                              return list
            case BeginObject => 
                                var map = HashMap<String, Any>()
                                reader.startObject()
                                while (let Some(v) <- reader.peek()) {
                                    if (v != EndObject) {
                                         map.add(reader.readName(), streamFromJsonForOptionAny(reader))
                                    } else {
                                        break
                                    }
                                }
                                reader.endObject()
                                return map
            case JsonString =>  return reader.readValue<String>()
            case JsonNumber =>  var bby = reader.readValueBytes()
                                 for (i in 0..bby.size) {
                                    if (bby[i] == 46) {
                                        return Float64.parse( unsafe { String.fromUtf8Unchecked(bby) })
                                    }
                                 }
                                return Int64.parse( unsafe { String.fromUtf8Unchecked(bby) })
            case JsonBool =>    return reader.readValue<Bool>()
            case JsonNull =>    return None
            case _ => throw Exception("暂不支持反序列化该类型")
        }
    }


    public static func streamFromJsonForAny(reader: JsonStreamReader): Any {
        var peek = reader.peek().getOrThrow()
        match (peek) {
            case BeginArray =>
                                var list = ArrayList<Any>()
                                reader.startArray()
                                while (let Some(v) <- reader.peek()) {
                                    if (v != EndArray) {
                                        list.add(streamFromJsonForAny(reader))
                                    }else {
                                        break
                                    }
                                }
                                reader.endArray()
                                return list
            case BeginObject => 
                                var map = HashMap<String, Any>()
                                reader.startObject()
                                while (let Some(v) <- reader.peek()) {
                                    if (v != EndObject) {
                                        map.add(reader.readName(), streamFromJsonForAny(reader))
                                    } else {
                                        break
                                    }
                                }
                                reader.endObject()
                                return map

            case JsonString =>  return reader.readValue<String>()
            case JsonNumber =>  var bby = reader.readValueBytes()
                                 for (i in 0..bby.size) {
                                    if (bby[i] == 46) {
                                        return Float64.parse( unsafe { String.fromUtf8Unchecked(bby) })
                                    }
                                 }
                                return Int64.parse( unsafe { String.fromUtf8Unchecked(bby) })
            case JsonBool =>    return reader.readValue<Bool>()
            case JsonNull =>    return reader.readValue<Option<Int64>>()
            case _ => throw Exception("暂不支持反序列化该类型")
        }
    }



    public static func streamFromJsonForArryAny(reader: JsonStreamReader): Array<Any> {
        var peek = reader.peek().getOrThrow()
        match (peek) {
            case BeginArray =>
                              var list = ArrayList<Any>()
                              reader.startArray()
                              while (let Some(v) <- reader.peek()) {
                                if (v != EndArray) {
                                    list.add(streamFromJsonForAny(reader))
                                } else {
                                    break
                                }
                              }
                              reader.endArray()
                              return unsafe {list.getRawArray()}
            case _ => throw Exception("暂不支持反序列化该类型")
        }

    }



    public static func streamFromJsonForListAny(reader: JsonStreamReader): ArrayList<Any> {
        var peek = reader.peek().getOrThrow()
        match (peek) {
            case BeginArray =>
                              var list = ArrayList<Any>()
                              reader.startArray()
                              while (let Some(v) <- reader.peek()) {
                                if (v != EndArray) {
                                    list.add(streamFromJsonForAny(reader))
                                } else {
                                    break
                                }
                              }
                              reader.endArray()
                              return list
            case _ => throw Exception("暂不支持反序列化该类型")
        }
    }


    public static func streamFromJsonForHashMapAny(reader: JsonStreamReader): HashMap<String, Any> {
        var peek = reader.peek().getOrThrow()
        match (peek) {
            case BeginObject => 
                                var map = HashMap<String, Any>()
                                reader.startObject()
                                while (let Some(v) <- reader.peek()) {
                                    if (v != EndObject) {
                                        map.add(reader.readName(), streamFromJsonForAny(reader))
                                    } else {
                                        break
                                    }
                                }
                                reader.endObject()
                                return map
            case _ => throw Exception("暂不支持反序列化该类型")
        }

    }



}
