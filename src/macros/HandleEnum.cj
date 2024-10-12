macro package cjjson.macros

import std.ast.*

class HandleEnum {
    public HandleEnum(
        let ed: EnumDecl
    ) {}

    public func toTokens(): Tokens {
        return Tokens()
    }
}