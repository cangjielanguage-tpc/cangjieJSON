/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
macro package cjjson.macros

import std.ast.*
import std.collection.*

class HandleStruct {
    private let sd: StructDecl
    private var structName: Tokens
    private let allFields = ArrayList<FieldInfo>()

    private var withGenericType: Bool = false
    private var genericType: Tokens = Tokens()
    private var allowNull: Bool = false

    public init(sd: StructDecl) {
        this.sd = sd
        this.structName = this.sd.identifier.toTokens()

        if (this.sd.isGenericDecl) {
            this.structName += this.sd.genericParam.toTokens()
        }
    }

    private func handleAttr(attr: Tokens): Unit {
        if (attr.size == 0) {
            return
        }
        var offset: Int64 = 0
        while (offset < attr.size) {
            try {
                let (expr, off) = parseExprFragment(attr, startFrom: offset)
                match (expr) {
                    case ae: AssignExpr =>
                        let key = ae.leftExpr.toTokens().toString()
                        let value = ae.rightExpr
                        if (key == JsonAdapterClassAttr.WITH_GENERIC_TYPE) {
                            if (value.toTokens().size != 1) {
                                diagReport(DiagReportLevel.ERROR, value.toTokens(), "only one generic type is allowed",
                                    "only one generic type is allowed")
                            }
                            this.withGenericType = true
                            this.genericType = value.toTokens()
                        } else {
                            diagReport(DiagReportLevel.ERROR, ae.toTokens(),
                                "only ${JsonAdapterClassAttr.WITH_GENERIC_TYPE} is supported for struct type",
                                "only ${JsonAdapterClassAttr.WITH_GENERIC_TYPE} is supported for struct type")
                        }
                    case re: RefExpr =>
                        let key = re.identifier.value
                        if (key == JsonAdapterClassAttr.ALLOW_NULL) {
                            this.allowNull = true
                        } else {
                            diagReport(DiagReportLevel.ERROR, re.toTokens(),
                                "Unknown key, it should be one of ${JsonAdapterClassAttr.availableAttrs()}",
                                "Unknown key, it should be one of ${JsonAdapterClassAttr.availableAttrs()}")
                        }
                    case _ => diagReport(DiagReportLevel.ERROR, expr.toTokens(),
                        "only ${JsonAdapterClassAttr.WITH_GENERIC_TYPE} is supported for struct type",
                        "only ${JsonAdapterClassAttr.WITH_GENERIC_TYPE} is supported for struct type")
                }
                offset = off
            } catch (e: ParseASTException) {
                diagReport(DiagReportLevel.ERROR, attr,
                    "attributes is illegal, it should looks like [${JsonAdapterClassAttr.WITH_GENERIC_TYPE} = T]",
                    "attributes is illegal")
                break
            }
        }
    }

    // 检查泛型变元是否一致，并且为泛型变元增加接口约束。
    private func handleGenericType(): Unit {
        if (!withGenericType) {
            return
        }

        if (!this.sd.isGenericDecl) {
            diagReport(DiagReportLevel.ERROR, this.sd.identifier.toTokens(),
                "expect to be a generic struct type when using `${JsonAdapterClassAttr.WITH_GENERIC_TYPE}` attribute",
                "expect to be a generic struct")
            return
        }

        let gpTokens = this.sd.genericParam.parameters.toTokens()
        if (gpTokens.size != 1) {
            diagReport(DiagReportLevel.ERROR, gpTokens, "can only have one generic param",
                "can only have one generic param")
            return
        }

        let gp = gpTokens.get(0)
        if (gp.toTokens().toString() != genericType.toString()) {
            diagReport(DiagReportLevel.ERROR, gpTokens,
                "generic param is inconsistent with `${JsonAdapterClassAttr.WITH_GENERIC_TYPE}` attribute",
                "generic param is inconsistent with `${JsonAdapterClassAttr.WITH_GENERIC_TYPE}` attribute")
            return
        }

        let gcList = this.sd.genericConstraint
        let gc = GenericConstraint()
        gc.keyword = Token(TokenKind.WHERE)
        gc.typeArgument = RefType(genericType)
        gc.upperBounds.add(RefType(quote(IJsonAdapter<T>)))

        if (gcList.size == 0) {
            this.sd.genericConstraint.add(gc)
        } else {
            var hasAddStruct = false
            for (item in gcList) {
                let ta = item.typeArgument
                if (ta.toTokens().toString() == genericType.toString()) {
                    for (value in item.upperBounds) {
                        match (value) {
                            case rt: RefType =>
                                if (rt.identifier.toTokens().toString() == "IJsonAdapter") {
                                    hasAddStruct = true
                                    break
                                }
                            case _ => ()
                        }
                    }
                    if (!hasAddStruct) {
                        item.upperBounds.add(RefType(quote(IJsonAdapter<T>)))
                        hasAddStruct = true
                    }
                }
            }
            if (!hasAddStruct) {
                this.sd.genericConstraint.add(gc)
            }
        }
    }

    private func handleSuperTypes() {
        let refType = RefType(quote(IJsonAdapter<$(structName)>))
        var hasAdded = false
        for (item in sd.superTypes) {
            if (item.toTokens().toString() == refType.toTokens().toString()) {
                hasAdded = true
                break
            }
        }
        if (!hasAdded) {
            sd.superTypes.add(refType)
        }
    }

    private func fromJsonValueFunc(): FuncDecl {
        var funcBody = Tokens()

        for (fieldStructTemp1 in allFields) {
            if (fieldStructTemp1.isIgnore) {
                continue
            }
            let identifierStructTemp1 = fieldStructTemp1.vd.identifier
            let jsonNameStructTemp1 = fieldStructTemp1.getJsonName()
            let typeInfoStructTemp1 = fieldStructTemp1.vd.declType

            let assignExpr = if (isOptionType(typeInfoStructTemp1)) {
                let baseType = getOptionBaseType(typeInfoStructTemp1)
                quote(
                    obj.$identifierStructTemp1 = Option<$baseType>.fromJsonValue(jsonObj.get($jsonNameStructTemp1) ?? JsonNull())
                )
            } else {
                quote(
                    obj.$identifierStructTemp1 = $typeInfoStructTemp1.fromJsonValue(jsonObj.get($jsonNameStructTemp1).getOrThrow({=> JsonFieldNotExist($(this.structName.toString()), $jsonNameStructTemp1)}))
                )
            }

            let exprStructTemp1 = if (this.allowNull || fieldStructTemp1.useDefault) {
                // 如果该 class 标记了 allowNull，或者该成员标记了 @JsonDefault，则仅当 json 字符串中包含该字段时，才对成员变量进行解析赋值，否则保持默认值。
                quote(
                    if (jsonObj.containsKey($jsonNameStructTemp1)  && jsonObj.get($jsonNameStructTemp1).getOrThrow().toString() != "null") {
                        $assignExpr
                    }
                )
            } else {
                quote(
                    try {
                        $assignExpr
                    } catch (e: JsonTypeMismatch) {
                        throw JsonTypeMismatch($(this.structName.toString()), $jsonNameStructTemp1, e.message)
                    }
                )
            }

            funcBody.append(exprStructTemp1)
        }

        return FuncDecl(
            quote(
            public static func fromJsonValue(jsonValue: JsonValue): $structName {
                let jsonObj = match (jsonValue) {
                    case obj: JsonObject => obj
                    case _ => throw JsonTypeMismatch("JSON Object", jsonValue.kind().toString())
                }

                var obj = $structName()

                $funcBody
                return obj
            }
        ))
    }

    private func fromJsonFunc(): FuncDecl {
        return FuncDecl(
            quote(
            public static func fromJson(str: String): $structName {
                return fromJsonValue(JsonValue.fromStr(str))
            }
        ))
    }

    private func toJsonValueFunc(): FuncDecl {
        var funcBody = Tokens()

        for (fieldStructTemp in allFields) {
            if (fieldStructTemp.isIgnore) {
                continue
            }
            let jsonNameStructTemp = fieldStructTemp.getJsonName()
            if (fieldStructTemp.isIgnoreNull && isOptionType(fieldStructTemp.vd.declType)) {
                funcBody.append(
                    quote(
                    if (let Some(v) <- $(fieldStructTemp.vd.identifier)) {
                        jsonObj.put($(jsonNameStructTemp), $(fieldStructTemp.vd.identifier).toJsonValue())
                    }
                ))
            } else {
                funcBody.append(
                    quote(
                    jsonObj.put($(jsonNameStructTemp), $(fieldStructTemp.vd.identifier).toJsonValue())
                ))
            }
        }

        return FuncDecl(
            quote(
            public func toJsonValue(): JsonValue {
                let jsonObj = JsonObject()
                $funcBody
                return jsonObj

            }
        ))
    }

    private func toJsonFunc(): FuncDecl {
        return FuncDecl(
            quote(
            public func toJson(): String {
                return toJsonValue().toString()
            }
        ))
    }

    public func doExpend(attr: Tokens): Tokens {
        handleAttr(attr)
        handleGenericType()
        handleSuperTypes()

        // collect all fields
        for (decl in sd.body.decls) {
            match (decl) {
                case vd: VarDecl =>
                    let field = FieldInfo(vd)
                    if (field.isStatic && !field.isIgnore) {
                        diagReport(DiagReportLevel.ERROR, vd.toTokens(), "`static` member variable must use @JsonIgnore",
                            "must use @JsonIgnore")
                    }
                    this.allFields.add(field)
                case _ => ()
            }
        }

        sd.body.decls.add(fromJsonFunc())
        sd.body.decls.add(toJsonFunc())
        sd.body.decls.add(fromJsonValueFunc())
        sd.body.decls.add(toJsonValueFunc())

        return sd.toTokens()
    }
}
