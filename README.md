# Cangjie JSON 序列化与反序列化库

通过提供以下宏，来简化仓颉代码中 JSON 序列化和反序列化的开发：

- 提供 `@JsonAdapter` 宏用于修饰 class，为其自动生成序列化和反序列化的成员方法；
- 提供 `@JsonName["newName"]` 宏用于修饰 class 里的成员，使其在序列化和反序列化过程中使用别名；
- 提供 `@JsonIgnore` 宏用于修饰 class 里的成员，使其不参与序列化和反序列化；
- 提供 `@JsonIgnoreNull` 宏用于修饰 class 里的成员，如果该成员值为 None，则不进行序列化；反序列化仍然正常执行。


同时对外暴露了如下接口：
- `IJsonAdapter<T>` 接口：序列化和反序列化的接口，使用 `@JsonAdapter` 修饰的 class 默认都实现了该接口；
- `JsonTypeMismatch` 异常类：在反序列化时，如果JSON的数据类型与 class 成员的类型不一致，会抛出该异常；
- `JsonFieldNotExist` 异常类：在反序列化时，如果 class 的成员变量名字，在 JSON 字符串中找不到对应的 key，会抛出该异常。
- `DataModelExtend` 接口：获取 `DataModel` 的类型，仅用于宏展开的代码调用，开发者无需关注。


**完整示例请查阅 `examples` 目录。**

# 1. 接口详细介绍：

## 1.1 `@JsonAdapter` 宏

用于修饰非泛型的 class 类型，使其实现 `IJsonAdapter<T>` 接口，该接口定义如下：

```cangjie
public interface IJsonAdapter<T> <: Serializable<T> {
    static func fromJson(str: String): T
    func toJson(): String
}

// 其中 Serializable<T> 接口定义在仓颉标准库 serialization.serialization 包中，其声明如下：
public interface Serializable<T> {
    func serialize(): DataModel
    static func deserialize(dm: DataModel): T
}
```

示例如下：

```cangjie
@JsonAdapter
public class Basic {
    public var a: Int64 = 0
    public var b: String = ""
    public var c: ?String = None
    public var d: Array<Int64> = Array<Int64>()
    public var e: ArrayList<String> = ArrayList<String>()
    public var f: HashMap<String, Int64> = HashMap<String, Int64>()

    // other member functions
}
```

宏展开之后，对应的代码为：

```cangjie
public class Basic <: IJsonAdapter <Basic> {
    public var a: Int64 = 0
    public var b: String = ""
    public var c: ?String = None
    public var d: Array<Int64> = Array<Int64>()
    public var e: ArrayList<String> = ArrayList<String>()
    public var f: HashMap<String, Int64> = HashMap<String, Int64>()

    public static func deserialize(dataModel: DataModel): Basic {
        ...
    }

    public func serialize(): DataModel {
        ...
    }

    public static func fromJson(str: String): Basic {
        ...
    }

    public func toJson(): String {
        ...
    }
}
```

因此开发者可以通过调用以上方法来进行 JSON 的序列化和反序列化：

```cangjie
let input: String = "{"a\":123,\"b\":\"bbbbb\",\"c\":null,\"d\":[1,2,3],\"e\":[\"s1\",\"s2\",\"s3\"],\"f\":{\"f1\":123,\"f2\":456}}"

// 反序列化为仓颉对象
let b = Basic.fromJson(input)

// 序列化为 String
println(b.toJson())
```

> 【注意】以下类型均已默认实现了 `IJsonAdapter` 接口，可以直接使用：
>   - 全部基础类型：`Int8/16/32/64`、`UInt8/16/32/64`、`Float16/32/64`、`Bool`、`Rune`、`String`
>   - `Option<T>`
>   - `Array<T>`、`ArrayList<T>`、`HashSet<T>`、`HashMap<K, V>`

## 1.2 `@JsonName` 宏

用于修饰 class 里的成员，使其在序列化和反序列化过程中使用新的名字。例如：

```cangjie
@JsonAdapter
public class JsonNameExample {
    @JsonName["newName"]
    public var name: String = ""
}

main() {
    let input = #"{"name": "123"}"#
    JsonNameExample.fromJson(input) // 会抛出 JsonFieldNotExist 异常：'JsonNameExample.newName' not exist


    let input2 = #"{"newName": "123"}"#
    println(JsonNameExample.fromJson(input2).toJson()) // 正常
}
```

## 1.3 `@JsonIgnore` 宏

用于修饰 class 里的成员，使其不参与序列化和反序列化。例如：

```cangjie
// IgnoreClass 没有使用 @JsonAdapter 修饰
public class IgnoreClass {
    public var str = ""
    public var val = 123
}

@JsonAdapter
public class JsonIgnoreExample {
    // 使用 @JsonIgnore 修饰的成员将不参与序列化和反序列化
    @JsonIgnore
    public var a: Int64 = 0

    // static 成员必须使用 @JsonIgnore 修饰
    @JsonIgnore
    public static var sa: Int64 = 0

    // private 成员必须使用 @JsonIgnore 修饰
    @JsonIgnore
    private var pa: Int64 = 0

    // 使用 @JsonIgnore 修饰的成员，其类型无需满足 IJsonAdapter 接口约束
    @JsonIgnore
    public var b: IgnoreClass = IgnoreClass()  

    public var c: Int64 = 0
}

main() {
    let input = #"
    {
        "a": 1,
        "sa": 2,
        "pa": 3,
        "b": {
            "str": "sss",
            "val":456
        },
        "c":789
    }"#
    println(JsonIgnoreExample.fromJson(input).toJson()) // 输出：{"c":789}
}
```

## 1.4 `@JsonIgnoreNull` 宏

用于修饰 class 里的成员，如果该成员值为 None，则不进行序列化；反序列化仍然正常执行。例如：

```cangjie
@JsonAdapter
public class IgnoreNullExample {
    // @JsonIgnoreNull 可以用于修饰非Option类型的成员，但是不会有效果
    @JsonIgnoreNull
    public var a: Int64 = 0

    @JsonIgnoreNull
    public var b: Option<Int64> = 0

    @JsonIgnoreNull
    public var c: Option<String> = ""

    @JsonIgnoreNull
    public var d: Option<ArrayList<Int64>> = None

    @JsonIgnoreNull
    public var e: Option<ArrayList<String>> = None
}

main() {
    // 如果 JSON 字符串中的值为 null，经过反序列化后，再序列化时该字段会被忽略
    let input = #"{"a":1,"b":null,"c":"ccc","d":[4,5,6],"e":null}"#
    let expectOutput = #"{"a":1,"c":"ccc","d":[4,5,6]}"#
    println("input  = " + input)
    println("expect = " + expectOutput)
    println("actual = " + IgnoreNullExample.fromJson(input).toJson())

    // 如果 JSON 字符串中没有对应的字段，经过反序列化后，再序列化时该字段会被忽略
    let input2 = #"{"a":1}"#
    let expectOutput2 = #"{"a":1}"#
    println("input  = " + input2)
    println("expect = " + expectOutput2)
    println("actual = " + IgnoreNullExample.fromJson(input2).toJson())
}
```

# 2. 使用限制

1. 目前仅支持修饰 class 类型，后续会支持 enum 类型
2. `@JsonAdapter` 暂不支持修饰泛型类型
3. `@JsonAdapter`暂不支持修饰通过主构造函数声明成员变量的 class 类型


# 3. 如何集成使用

## Step1：配置并更新依赖

在您代码仓的 `cjpm.toml` 文件中，新增如下源码依赖配置：

```toml
[dependencies]
  cjjson = {git = "https://gitcode.com/Cangjie-TPC/cangjieJSON.git", branch = "dev"}
```

在 `cjpm.toml` 所在目录，执行 `cjpm update` 命令下载对应的代码仓，


## Step2：导入依赖包

在源码中导入以下 package：

```cangjie
import cjjson.*
import cjjson.macros.*
import encoding.json.*
```

## Step3：在代码中使用宏修饰 class 及其成员

例如使用 `@JsonAdapter` 修饰对应的 class 即可。

```cangjie
@JsonAdapter
public class Basic {
    public var a: Int64 = 0
    public var b: String = ""
    public var c: ?String = None
    public var d: Array<Int64> = Array<Int64>()
    public var e: ArrayList<String> = ArrayList<String>()
    public var f: HashMap<String, Int64> = HashMap<String, Int64>()

    // other member functions
}
```
