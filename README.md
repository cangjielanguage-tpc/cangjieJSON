# Cangjie JSON 序列化与反序列化库

通过提供以下宏，来简化仓颉代码中 JSON 序列化和反序列化的开发：

- 提供 `@JsonAdapter` 宏用于修饰 class，为其自动生成序列化和反序列化的成员方法；
- 提供 `@JsonName["newName"]` 宏用于修饰 class 里的成员，使其在序列化和反序列化过程中使用别名；
- 提供 `@JsonIgnore` 宏用于修饰 class 里的成员，使其不参与序列化和反序列化；
- 提供 `@JsonIgnoreNull` 宏用于修饰 class 里的成员，如果该成员值为 None，则不进行序列化；反序列化仍然正常执行。
- 提供 `AnyType` 类型，用于表示任意可能的 JSON 类型（bool、int、float、string、array、object、null）。

同时对外暴露了如下接口：
- `IJsonAdapter<T>` 接口：序列化和反序列化的接口，使用 `@JsonAdapter` 修饰的 class 默认都实现了该接口；
- `JsonTypeMismatch` 异常类：在反序列化时，如果JSON的数据类型与 class 成员的类型不一致，会抛出该异常；
- `JsonFieldNotExist` 异常类：在反序列化时，如果 class 的成员变量名字，在 JSON 字符串中找不到对应的 key，会抛出该异常。
- `JsonGetValueException` 异常类，调用 `AnyType` 的 `getValue<T>()` 方法时，如果类型不匹配，会抛出该异常。
- ~~`DataModelExtend` 接口：获取 `DataModel` 的类型，仅用于宏展开的代码调用，开发者无需关注。~~

> 备注：ChangeNote 请点击[此处](./ChangList.md)查看。

## 1. 使用限制

- 目前仅支持修饰 class 类型，暂不支持 enum 类型
- `@JsonAdapter`修饰的class，必须要有一个无参的构造函数。

## 2. 如何集成使用

### 2.1 配置并更新依赖

#### 方式1：git 源码依赖

在您工程的 `cjpm.toml` 文件中，新增如下源码依赖配置：

```toml
[dependencies]
  [dependencies.cjjson]
    git = "https://gitcode.com/Cangjie-TPC/cangjieJSON.git"
    branch = "dev"
```

或者使用特定的 tag 版本：

```toml
[dependencies]
  [dependencies.cjjson]
    git = "https://gitcode.com/Cangjie-TPC/cangjieJSON.git"
    tag = "tag_v0.0.3"
```

在您工程的 cjpm.toml 文件所在目录，执行 `cjpm update` 命令即可同步更新本仓源码。

#### 方式2：本地源码依赖

如果不希望通过 git 依赖本仓，您也可以直接下载本仓库的全量源码（包括本仓库的 cjpm.toml 配置文件），然后在您工程的 cjpm.toml 文件中添加本地模块依赖。

假如您将本仓库下载到您工程的 cjpm.toml 的**上一层目录**中，并且目录名字为 cangjieJSON，那么在您工程的 `cjpm.toml` 文件中，新增如下配置即可：

```toml
[dependencies]
  [dependencies.cjjson]
    path = "../cangjieJSON" # 相对路径、绝对路径均可，建议使用相对路径。
    version = "1.0.0"
```

### 2.2 导入依赖包

在源码中导入以下 package：

```cangjie
import cjjson.*         // 所有对外接口，以及宏展开依赖的的接口
import cjjson.macros.*  // 宏定义
```

> **注意：请尽量以 `.*` 的方式导入这两个包的所有符号。**

### 2.3 在代码中使用宏修饰 class 及其成员

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
}
```

然后便可直接调用这个类的相关方法完成与 JSON 字符串的互相转换：

```cangjie
let input: String = #"
{
    "a": 123,
    "b": "bbbbb",
    "c": null,
    "d": [1,2,3],
    "e": ["s1","s2","s3"],
    "f": {
        "f1":123,
        "f2":456
    }
}"#

let obj = Basic.fromJson(input)  // JSON 字符串反序列化为 Basic 对象

let jsonString: String = obj.toJson() // Basic 对象序列化为 JSON 字符串
```

> 更多详细示例请查阅 `examples` 目录或 `src/test` 目录。

## 3. 接口详细介绍：

### 3.1 `@JsonAdapter` 宏

用于修饰 class 类型（支持泛型），使其实现 `IJsonAdapter<T>` 接口，`IJsonAdapter<T>`的接口定义如下：

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

    // other member functions

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
let input: String = #"{"a":123,"b":"bbbbb","c":null,"d":[1,2,3],"e":["s1","s2","s3"],"f":{"f1":123,"f2":456}}"#

// 反序列化为仓颉对象
let b = Basic.fromJson(input)

// 序列化为 JSON 字符串
println(b.toJson())
```

> **注意**
>
> 以下类型均已默认实现了 `IJsonAdapter` 接口，可以直接使用：
>
>   - 全部基础类型：`Int8/16/32/64`、`UInt8/16/32/64`、`Float16/32/64`、`Bool`、`Rune`、`String`
>   - `Option<T>`
>   - `Array<T>`、`ArrayList<T>`、`HashSet<T>`、`HashMap<K, V>`

#### 3.1.1 `withSuperClass` 属性

默认情况下，`@JsonAdapter` 修饰的 class **只能针对自身的成员变量进行序列化和反序列化，并不包含其父类里的成员变量**。

在子类的序列化和反序列化的过程中，为了使其包含父类的成员变量，`@JsonAdapter` 支持一个可选的 `withSuperClass` 属性，用于指定父类类型。

> 注意：在这种情况下，父类也必须使用 `@JsonAdapter` 修饰。

示例如下：

```cangjie
// 如果需要被继承，需要添加 open 访问修饰符。
@JsonAdapter
public open class Parent {
    public var a: Int64 = 0
}

// 指定父类类型为 Parent，表明父类的成员也将被序列化和反序列化。
@JsonAdapter[withSuperClass = Parent]
public class Child <: Parent {
    public var b: String = ""
}

main() {
    let input = #"{"a":123,"b":"hello"}"#

    let c: Child = Child.fromJson(input)
    println(c.a) // 输出 123
    println(c.b) // 输出 hello
}
```

#### 3.1.2 `withGenericType` 属性

实际上，`@JsonAdapter` 可以用于修饰一个泛型类，但是**该泛型类型不能参与序列化和反序列化的过程**（比如，@JsonIgnore 修饰的成员变量的类型可以使用该泛型类型）。

如果泛型类型需要参与序列化和反序列化的过程，`@JsonAdapter` 提供了一个可选的 `withGenericType` 属性用于指定其泛型变元。

> 注意：
>
> 1. `withGenericType` 目前最多支持 1 个泛型变元。
> 2. `withGenericType` 指定的泛型变元，会自动添加 `where T <: IJsonAdapter<T>` 的泛型约束。

示例如下：

```cangjie
@JsonAdapter
public class MyData {
    public var a: Int64 = 0
    public var b: String = ""
}

// 指定泛型变元 T，支持类型为 T 的成员参与序列化和反序列化，并自动为其添加 IJsonAdapter<T> 泛型约束。
@JsonAdapter[withGenericType = T]
public class Result<T> {
    public var data: ?T = None
}

main() {
    let input = #"{"data":{"a":123,"b":"hello"}}"#
    let res = Result<MyData>.fromJson(input)
    println(res.toJson()) // 输出：{"data":{"a":123,"b":"hello"}}
}
```

### 3.2 `@JsonName` 宏

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

### 3.3 `@JsonIgnore` 宏

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

### 3.4 `@JsonIgnoreNull` 宏

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

### 3.5 AnyType 类型

`AnyType` 可用于表示任意可能的 JSON 类型（bool、int、float、string、array、object、null）。其接口定义如下：

```cangjie
public class AnyType <: IJsonAdapter<AnyType> {
    // 原始的 JsonValue 值。
    public var jsonValue: JsonValue = JsonNull()

    // 判断 AnyType 的类型
    public func isArray(): Bool
    public func isBool(): Bool
    public func isFloat(): Bool
    public func isInt(): Bool
    public func isNull(): Bool
    public func isObject(): Bool
    public func isString(): Bool

    // 转换为对应的 T 类型，如果类型不匹配，会抛出异常。
    public func getValue<T>(): T where T <: IJsonAdapter<T>

    // 实现 IJsonAdapter 接口的 4 个方法
    public static func deserialize(dataModel: DataModel): AnyType
    public func serialize(): DataModel
    public static func fromJson(str: String): AnyType
    public func toJson(): String
}
```

具体使用示例可参考[单元测试用例源码](./src/test/AnyType_test.cj)
