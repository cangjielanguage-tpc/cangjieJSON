# Cangjie json 序列化与反序列化库

提供 @JsonAdapter 宏，用于为 class 自动实现如下 `IJsonAdapter<T>` 接口，使其可以进行 json 序列化和反序列化。

```cangjie
public interface IJsonAdapter<T> <: Serializable<T> {
    static func fromJson(str: String): T
    func toJson(): String
}
```

## 主要特性：

- 默认支持仓颉全部的基础类型：Int8/16/32/64、UInt8/16/32/64、Float16/32/64、Bool、Rune、String
- 支持 `Option<T>`
- 支持 `Array<T>`、`ArrayList<T>`、`HashSet<T>`、`HashMap<K, V>`。

### 使用限制

1. 目前仅支持修饰 class 类型，后续会支持 struct、enum 类型
2. 暂不支持 `@JsonAdapter` 修饰泛型类型
3. 暂不支持`@JsonAdapter` 修饰通过主构造函数声明成员变量的 class 类型

### 下一步计划

1. 提供 `@JsonAlias["alias"]` 宏修饰成员变量，使其在序列化和反序列化过程中使用别名
2. 提供 `@JsonIgnore` 宏修饰成员变量，使其在序列化和反序列化过程中忽略掉
3. 提供 `@JsonIgnoreNull` 宏修饰成员变量，使其在序列化过程中，如果值为 None，则不进行序列化

## 集成配置

```
[dependencies]
  cjjson = {git = "https://gitcode.com/Cangjie-TPC/cangjieJSON.git", branch = "dev"}
```

## 如何使用

导入相关符号：

```cangjie
import cjjson.*
import cjjson.macros.*
import encoding.json.*
```

使用 @JsonAdapter 修饰对应的 class 即可。

## 示例

```cangjie
import std.collection.*
import cjjson.*
import cjjson.macros.*
import encoding.json.*


@JsonAdapter
public class Basic <: ToString {
    public var a: Int64 = 0
    public var b: String = ""
    public var c: ?String = None
    public var d: Array<Int64> = Array<Int64>()
    public var e: ArrayList<String> = ArrayList<String>()
    public var f: HashMap<String, Int64> = HashMap<String, Int64>()

    public func toString(): String {
        var ret = ""
        ret += "a = ${a}\n"
        ret += "b = ${b}\n"
        ret += "c = ${c}\n"
        ret += "d = ${d}\n"
        ret += "e = ${e}\n"
        ret += "f = ${f}\n"
        return ret
    }
}

main(): Int64 {
    let input: String = "{\"a\":123,\"b\":\"bbbbb\",\"c\":null,\"d\":[1,2,3],\"e\":[\"s1\",\"s2\",\"s3\"],\"f\":{\"f1\":123,\"f2\":456}}"
    let b = Basic.fromJson(input)
    println(b.toString())
    println(b.serialize().toJson().toString())
    return 0
}
```

