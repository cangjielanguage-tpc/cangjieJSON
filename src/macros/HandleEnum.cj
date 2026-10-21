macro package cjjson.macros

import std.ast.*

class HandleEnum {
    public HandleEnum(let ed: EnumDecl) {}

    public func doExpend(attr: Tokens): Tokens {
        if (attr.size > 0) {
            diagReport(DiagReportLevel.ERROR, attr, "@JsonAdapter does NOT support attributes for EnumDecl",
                "attributes not supported for Enum")
        }

        return Tokens()
    }
}
