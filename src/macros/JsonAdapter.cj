macro package cjjson.macros

import std.ast.*

public macro JsonAdapter(input: Tokens): Tokens {
    var ret = input

    let decl = parseDecl(input)
    match (decl) {
        case cd: ClassDecl =>
            ret = HandleClass(cd).toTokens()
        case ed: EnumDecl =>
            ret = HandleEnum(ed).toTokens()
        case _ =>
            diagReport(DiagReportLevel.ERROR, input, "Can only be used on ClassDecl or EnumDecl", "Expected ClassDecl or EnumDecl")
    }

    // 展开完一个class之后，需要重置全局信息，以便下一个展开下一个class 时全局数据保证是空的
    GlobalInfo.current().reset()

    return ret
}