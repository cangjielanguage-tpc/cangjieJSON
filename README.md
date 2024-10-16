# Cangjie JSON 序列化与反序列化库

提供 @JsonAdapter 宏，用于为 class 自动实现 `IJsonAdapter<T>` 接口（见下方源码），使其可以进行 JSON 序列化和反序列化。

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

## 主要特性：

- 提供 `@JsonAdapter` 用于修饰非泛型的 class 类型，为其自动生成 JSON 序列化及反序列化的接口；
- 以下类型均已默认实现了 `IJsonAdapter` 接口，可以直接使用：
    - 全部基础类型：`Int8/16/32/64`、`UInt8/16/32/64`、`Float16/32/64`、`Bool`、`Rune`、`String`
    - `Option<T>` 
    - `Array<T>`、`ArrayList<T>`、`HashSet<T>`、`HashMap<K, V>`

### 使用限制

1. 目前仅支持修饰 class 类型，后续会支持 struct、enum 类型
2. 暂不支持 `@JsonAdapter` 修饰泛型类型
3. 暂不支持`@JsonAdapter` 修饰通过主构造函数声明成员变量的 class 类型

### 下一步计划

1. 提供 `@JsonAlias["alias"]` 宏修饰成员变量，使其在序列化和反序列化过程中使用别名
2. 提供 `@JsonIgnore` 宏修饰成员变量，使其在序列化和反序列化过程中忽略掉
3. 提供 `@JsonIgnoreNull` 宏修饰成员变量，使其在序列化过程中，如果值为 None，则不进行序列化

## 如何使用

首先，在您代码仓的 `cjpm.toml` 文件中，新增如下源码依赖配置：

```toml
[dependencies]
  cjjson = {git = "https://gitcode.com/Cangjie-TPC/cangjieJSON.git", branch = "dev"}
```

然后，在您 `cjpm.toml` 所在目录，执行 `cjpm update` 命令下载对应的代码仓，

最后，在源码中导入以下 package：

```cangjie
import cjjson.*
import cjjson.macros.*
import encoding.json.*
```

并使用 `@JsonAdapter` 修饰对应的 class 即可。

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

### 完整示例如下

详细可参考 examples/ 目录下的示例。

```cangjie
package examples

import std.collection.*

import cjjson.*
import cjjson.macros.*
import encoding.json.*

@JsonAdapter
public class Basic {
    public var a: Int64 = 0
    public var b: String = ""
    public var c: ?String = None
    public var d: Array<Int64> = Array<Int64>()
    public var e: ArrayList<String> = ArrayList<String>()
    public var f: HashMap<String, Int64> = HashMap<String, Int64>()
}

@JsonAdapter
public class Parent {
    public var list: ArrayList<Basic> = ArrayList() //Basic使用了@JsonAdapter，因此可以作为ArrayList的泛型参数
}

main(): Int64 {
    let input: String = "{\"a\":123,\"b\":\"bbbbb\",\"c\":null,\"d\":[1,2,3],\"e\":[\"s1\",\"s2\",\"s3\"],\"f\":{\"f1\":123,\"f2\":456}}"
    let b = Basic.fromJson(input)
    println(b.toJson())

    let input2: String = "{\"list\": [{\"a\":123,\"b\":\"bbbbb\",\"c\":null,\"d\":[1,2,3],\"e\":[\"s1\",\"s2\",\"s3\"],\"f\":{\"f1\":123,\"f2\":456}}]}"
    let p = Parent.fromJson(input2)
    println(p.toJson())
    return 0
}
```
