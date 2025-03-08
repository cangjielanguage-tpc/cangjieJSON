# tag_v0.0.2（2025-03-09）

【新增】为 `@JsonAdapter` 宏新增2个属性：

- `withSuperClass = Xxx`：用于支持子类在进行 JSON 序列化和反序列化时，将父类（比如 `Xxx`）的成员变量也进行序列化和反序列化。
- `withGenericType = T`：用于给指定的泛型变元（比如 `T`）添加 `where T <: IJsonAdapter<T>` 泛型约束，以支持泛型类型的成员也可以自动进行 JSON 序列化和反序列化。

# tag_v0.0.1（2024-12-23）

首版本，通过提供以下宏，来简化仓颉代码中 JSON 序列化和反序列化的开发：

- 提供 `@JsonAdapter` 宏用于修饰 class，为其自动生成序列化和反序列化的成员方法；
- 提供 `@JsonName["newName"]` 宏用于修饰 class 里的成员，使其在序列化和反序列化过程中使用别名；
- 提供 `@JsonIgnore` 宏用于修饰 class 里的成员，使其不参与序列化和反序列化；
- 提供 `@JsonIgnoreNull` 宏用于修饰 class 里的成员，如果该成员值为 None，则不进行序列化；反序列化仍然正常执行。
