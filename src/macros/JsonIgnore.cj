macro package cjjson.macros

import std.ast.*

public macro JsonIgnore(input: Tokens): Tokens {
    assertParentContext("JsonAdapter")

    let decl = parseDecl(input)
    match (decl) {
        case vd: VarDecl =>
            GlobalInfo.current().setJsonIgnore(vd.identifier.value)
        case _ =>
            diagReport(DiagReportLevel.ERROR, input, "Can only be used on VarDecl", "Expected VarDecl")
    }

    return input
}