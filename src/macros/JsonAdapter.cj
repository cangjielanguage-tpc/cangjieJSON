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

    return ret
}