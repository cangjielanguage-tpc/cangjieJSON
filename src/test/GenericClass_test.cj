/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package cjjson.test

import std.unittest.*
import std.unittest.testmacro.*
import cjjson.*
import cjjson.macros.*

// 泛型父类，并使用 withGenericType 属性标记泛型
@JsonAdapter[withGenericType = T]
public open class GenericParent<T> {
    public var parentData: ?T = None
}

// 泛型子类，继承了泛型父类
@JsonAdapter[withSuperClass = GenericParent<T> ; withGenericType = T]
public class GenericChild<T> <: GenericParent<T> {
    public var childData: ?T = None
}

@Test
class GenericClassTest {
    @TestCase
    func genericChild() {
        let input = #"{"parentData":{"d1":1,"d2":2},"childData":{"d1":11,"d2":22}}"#
        let c = GenericChild<SimpleData>.fromJson(input)

        @Assert(c.parentData.getOrThrow().d1, 1)
        @Assert(c.parentData.getOrThrow().d2, 2)
        @Assert(c.childData.getOrThrow().d1, 11)
        @Assert(c.childData.getOrThrow().d2, 22)
    }
}
