macro package cjjson.macros

import std.ast.*
import std.collection.*
import stdx.serialization.serialization.DataModelException
import stdx.serialization.serialization.DataModelInt
import stdx.serialization.serialization.DataModelString
import stdx.serialization.serialization.DataModelStruct
import stdx.encoding.json.JsonObject
import stdx.serialization.serialization.DataModelFloat

class HandleClass {
    private let cd: ClassDecl
    private var className: Tokens
    private let allFields = ArrayList<FieldInfo>()

    private var withSuperClass: Bool = false
    private var superClass: Tokens = Tokens()
    private var withGenericType: Bool = false
    private var genericType: Token = Token()

    private var isOpen: Bool = false    // 表示是否是一个 open 的 class

    public init(cd: ClassDecl) {
        this.cd = cd

        this.className = if (this.cd.isGenericDecl) {
            this.cd.identifier.toTokens() + this.cd.genericParam.toTokens()
        } else {
            this.cd.identifier.toTokens()
        }

        for (item in cd.modifiers) {
            if (item.toTokens().toString() == "open") {
                this.isOpen = true
                break
            }
        }
    }

    private func handleSuperTypes() {
        let refType = RefType(quote(IJsonAdapter<$(className)>))
        var hasAdded = false
        for (item in cd.superTypes) {
            if (item.toTokens().toString() == refType.toTokens().toString()) {
                hasAdded = true
                break
            }
        }
        if (!hasAdded) {
            cd.superTypes.add(refType)
        }
    }

    private func createDeserializeFunc(): FuncDecl {
        var funcBody = Tokens()

        for (field in allFields) {
            if (field.isIgnore) {
                continue
            }
            let identifier = field.vd.identifier
            let jsonName = field.getJsonName()
            let typeInfo = field.vd.declType
            let typeInfoString = typeInfo.toTokens().toString()
            let str = "strVal_" + identifier.value
            let dm = Token(TokenKind.IDENTIFIER, str)

            // 添加字段存在性检查
            funcBody.append(quote(
               let $(dm) = dms.get($jsonName)
               if (!$(dm).isNull()) {
                  try {
            ))

		    // 根据类型生成反序列化代码
            if (isOptionType(typeInfo)) {
                let baseType = getOptionBaseType(typeInfo)
                if (isAnyType(baseType)) { // ?Any 反序列化
                    funcBody.append(quote(
                        obj.$identifier = JsonUtil.parseModel($(dm))
                    ))
                } else {
                    funcBody.append(quote(
                        obj.$identifier = Option<$baseType>.deserialize($(dm))
                    ))
                }
            } else if (isHashMapStringAnyType(typeInfo)) { // 为 HashMap<String, Any> 生成反序列化代码
                funcBody.append(quote(
                    obj.$identifier = JsonUtil.deserializeHashMapStringAny($(dm))
                ))
            } else if (isHashMapStringStringType(typeInfo)) { // 为 HashMap<String, String> 生成反序列化代码
              funcBody.append(quote(
                    obj.$identifier = JsonUtil.deserializeHashMapStringString($(dm))
                ))
            }else if (isSeqAnyType(typeInfo)) { // 为 Array<Any>、ArrayList<Any> 生成反序列化代码，统一反序列化为 Array<Any>
                funcBody.append(quote(
                    obj.$identifier = JsonUtil.deserializeArrayAny($(dm))
                ))
            } else if (isAnyType(typeInfo)) { // 为 Any 生成反序列化代码
                funcBody.append(quote(
                    obj.$identifier = JsonUtil.deserializeAny($(dm))
                ))
            } else {
                if (typeInfoString == "String") {
                    funcBody.append(quote(
                        match ($(dm)) {
                        	case dmInt: DataModelInt => obj.$identifier = dmInt.getValue().toString()
                            case dmFloat: DataModelFloat => obj.$identifier = dmFloat.getValue().toString()
                            case dmObj: DataModelStruct => obj.$identifier = $(dm).toJson().toString()
                            case _ => obj.$identifier = String.deserialize($(dm))
                        }
                    ))
                } else if (isNumberType(typeInfo)) {
                    funcBody.append(
                        quote(
                    obj.$identifier = $typeInfo.fromJson($(dm).toJson().toJsonString())
                ))
                } else {
                    funcBody.append(quote(
                        obj.$identifier = $typeInfo.deserialize($(dm))
                    ))
                }
            }

            // 添加类型不匹配的异常处理
            funcBody.append(quote(
                    } catch (e: DataModelException) {
                        throw JsonTypeMismatch($(this.className.toString()), $jsonName, $(typeInfoString), $(dm).toJsonType())
                    }
                }
            ))
        }


        let exceptionString = "${className.toString()}: not a DataModelStruct"

        if (withSuperClass) {
            funcBody.append(quote(
                $superClass.deserializeTo(obj, dms)
            ))
        }

        return FuncDecl(quote(
            public static func deserialize(dataModel: DataModel): $className {
                var dms: DataModelStruct = match(dataModel) {
                    case data: DataModelStruct => data
                    case _ => throw Exception($exceptionString)
                }
                let obj = $className()

                $funcBody

                return obj
            }
        ))
    }

    private func createDeserializeToFunc(): FuncDecl {
        var funcBody = Tokens()

        for (field in allFields) {
            if (field.isIgnore) {
                continue
            }
            let identifier = field.vd.identifier
            let jsonName = field.getJsonName()
            let typeInfo = field.vd.declType
            let typeInfoString = typeInfo.toTokens().toString()

            let callFn = if (isOptionType(typeInfo)) {
                let baseType = getOptionBaseType(typeInfo)
                if (isAnyType(baseType)) { // ?Any 反序列化
                    quote(obj.$identifier = JsonUtil.parseModel(dms.get($jsonName)))
                } else {
                    quote(obj.$identifier = Option<$baseType>.deserialize(dms.get($jsonName)))
                }
            } else if (isHashMapStringAnyType(typeInfo)) { // 为 HashMap<String, Any> 生成反序列化代码
                quote(obj.$identifier = JsonUtil.deserializeHashMapStringAny(dms.get($jsonName)))
            } else if (isSeqAnyType(typeInfo)) { // 为 Array<Any>、ArrayList<Any> 生成反序列化代码，统一反序列化为 Array<Any>
                quote(obj.$identifier = JsonUtil.deserializeArrayAny(dms.get($jsonName)))
            } else if (isAnyType(typeInfo)) { // 为 Any 生成反序列化代码
                quote(obj.$identifier = JsonUtil.deserializeAny(dms.get($jsonName)))
            } else if (isHashMapStringStringType(typeInfo)) { // 为 HashMap<String, String> 生成反序列化代码
                quote(obj.$identifier = JsonUtil.deserializeHashMapStringString(dms.get($jsonName)))
            }else {
                quote(obj.$identifier = $typeInfo.deserialize(dms.get($jsonName)))
            }

            funcBody.append(quote(
                try {
                    $callFn
                } catch (e: DataModelException) {
                    let dm = dms.get($jsonName)
                    if (dm.isNull()) {
                        throw JsonFieldNotExist($(this.className.toString()), $jsonName)
                    } else {
                        throw JsonTypeMismatch($(this.className.toString()), $jsonName, $(typeInfoString), dm.toJsonType())
                    }
                }
            ))
        }

        if (withSuperClass) {
            funcBody.append(quote(
                $superClass.deserializeTo(obj, dms)
            ))
        }

        return FuncDecl(quote(
            public static func deserializeTo(obj: $className, dms: DataModelStruct): Unit {
                $funcBody
            }
        ))
    }

    private func createSerializeFunc(): FuncDecl {
        var funcBody = Tokens()

        for (field in allFields) {
            if (field.isIgnore) {
                continue
            }
            let jsonName = field.getJsonName()
            if (field.isIgnoreNull && isOptionType(field.vd.declType)) {
                funcBody.append(quote(
                    if (let Some(v) <- $(field.vd.identifier)) {
                        dms.add(field($(jsonName), $(field.vd.identifier)))
                    }
                ))
            } else {
                funcBody.append(quote(
                    // dms.add(field($(jsonName), $(field.vd.identifier)))
                    dms.add(Field($(jsonName), JsonUtil.toModel($(field.vd.identifier)) ?? throw Exception("Failed to serialize field: " + $(jsonName))))
                ))
            }
        }

        let openModifier = if (isOpen) {
            quote(open)
        } else {
            quote()
        }

        if (withSuperClass) {
            funcBody.append(quote(
                super.serializeTo(dms)
            ))
        }

        return FuncDecl(quote(
            public $openModifier func serialize(): DataModel {
                let dms = DataModelStruct()
                $funcBody
                return dms
            }
        ))
    }

    private func createSerializeToFunc(): FuncDecl {
        var funcBody = Tokens()

        for (field in allFields) {
            if (field.isIgnore) {
                continue
            }
            let jsonName = field.getJsonName()
            if (field.isIgnoreNull && isOptionType(field.vd.declType)) {
                funcBody.append(quote(
                    if (let Some(v) <- $(field.vd.identifier)) {
                        dms.add(field($(jsonName), $(field.vd.identifier)))
                    }
                ))
            } else {
                funcBody.append(quote(
                    //dms.add(field($(jsonName), $(field.vd.identifier)))
                    dms.add(Field($(jsonName), JsonUtil.toModel($(field.vd.identifier)) ?? throw Exception("Failed to serialize field: " + $(jsonName))))

                ))
            }
        }

        let openModifier = if (isOpen) {
            quote(open)
        } else {
            quote()
        }

        if (withSuperClass) {
            funcBody.append(quote(
                super.serializeTo(dms)
            ))
        }

        return FuncDecl(quote(
            public $openModifier func serializeTo(dms: DataModelStruct): Unit {
                $funcBody
            }
        ))
    }

    private func createFromJsonFunc(): FuncDecl {
        return FuncDecl(quote(
            public static func fromJson(str: String): $className {
                let dm = DataModel.fromJson(JsonValue.fromStr(str))
                return $className.deserialize(dm)
            }
        ))
    }

    private func createToJsonFunc(): FuncDecl {
        let openModifier = if (isOpen) {
            quote(open)
        } else {
            quote()
        }

        return FuncDecl(quote(
            public $openModifier func toJson(): String {
                return this.serialize().toJson().toString()
            }
        ))
    }

    private func handleAttr(attr: Tokens): Unit {
        if (attr.size == 0) {
            return
        }
        var offset: Int64 = 0
        while (offset < attr.size) {
            try {
                let (expr, off) = parseExprFragment(attr, startFrom: offset)
                expr.dump()
                match (expr) {
                    case ae: AssignExpr =>
                        let key = ae.leftExpr.toTokens().toString()
                        let value = ae.rightExpr
                        if (key == JsonAdapterClassAttr.WITH_SUPER_CLASS) {
                            // let ty = RefExpr(value.toTokens())

                            // if (value.toTokens().size != 1) {
                            //     diagReport(DiagReportLevel.ERROR, value.toTokens(),
                            //         "only one super class is allowed",
                            //         "only one super class is allowed")
                            // }
                            this.withSuperClass = true
                            this.superClass = value.toTokens()
                        } else if (key == JsonAdapterClassAttr.WITH_GENERIC_TYPE) {
                            if (value.toTokens().size != 1) {
                                diagReport(DiagReportLevel.ERROR, value.toTokens(),
                                    "only one generic type is allowed",
                                    "only one generic type is allowed")
                            }
                            this.withGenericType = true
                            this.genericType = value.toTokens().get(0)
                        } else {
                            diagReport(DiagReportLevel.ERROR, key.toTokens(),
                            "Unknown key, it should be one of ${JsonAdapterClassAttr.availableAttrs()}",
                            "Unknown key, it should be one of ${JsonAdapterClassAttr.availableAttrs()}")
                        }
                    case _ =>
                        diagReport(DiagReportLevel.ERROR, expr.toTokens(),
                            "expect AssignExpr, and key should be one of ${JsonAdapterClassAttr.availableAttrs()}",
                            "expect AssignExpr, and key should be one of ${JsonAdapterClassAttr.availableAttrs()}")
                }
                offset = off
            } catch (e: ParseASTException) {
                diagReport(DiagReportLevel.ERROR, attr,
                    "attributes is illegal, it should looks like [${JsonAdapterClassAttr.WITH_SUPER_CLASS} = Xxx; ${JsonAdapterClassAttr.WITH_GENERIC_TYPE} = T]",
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

        if (!this.cd.isGenericDecl) {
            diagReport(DiagReportLevel.ERROR, this.cd.identifier.toTokens(),
                "expect to be a generic class type when using `${JsonAdapterClassAttr.WITH_GENERIC_TYPE}` attribute",
                "expect to be a generic class")
            return
        }

        let gpTokens = this.cd.genericParam.parameters.toTokens()
        if (gpTokens.size != 1) {
            diagReport(DiagReportLevel.ERROR, gpTokens,
                "can only have one generic param",
                "can only have one generic param")
            return
        }

        let gp = gpTokens.get(0)
        if (gp.toTokens().toString() != genericType.toTokens().toString()) {
            diagReport(DiagReportLevel.ERROR, gpTokens,
                "generic param is inconsistent with `${JsonAdapterClassAttr.WITH_GENERIC_TYPE}` attribute",
                "generic param is inconsistent with `${JsonAdapterClassAttr.WITH_GENERIC_TYPE}` attribute")
            return
        }

        let gcList = this.cd.genericConstraint
        let gc = GenericConstraint()
        gc.keyword = Token(TokenKind.WHERE)
        gc.typeArgument = RefType(genericType.toTokens())
        gc.upperBounds.add(RefType(quote(IJsonAdapter<T>)))

        if (gcList.size == 0) {
            this.cd.genericConstraint.add(gc)
        } else {
            var hasAdd = false
            for (item in gcList) {
                let ta = item.typeArgument
                if (ta.toTokens().toString() == genericType.toTokens().toString()) {
                    for (value in item.upperBounds) {
                        match(value) {
                            case rt: RefType =>
                                if (rt.identifier.toTokens().toString() == "IJsonAdapter") {
                                    hasAdd = true
                                    break
                                }
                            case _ => ()
                        }
                    }
                    if (!hasAdd) {
                        item.upperBounds.add(RefType(quote(IJsonAdapter<T>)))
                        hasAdd = true
                    }
                }
            }
            if (!hasAdd) {
                this.cd.genericConstraint.add(gc)
            }
        }

        println("class = ${this.cd.toTokens().toString()}")

    }

    public func doExpend(attr: Tokens): Tokens {
        handleAttr(attr)

        handleGenericType()

        handleSuperTypes()

        // collect all fields
        for (decl in cd.body.decls) {
            match (decl) {
                case vd: VarDecl =>
                    let field = FieldInfo(vd)
                    if ( field.isStatic && !field.isIgnore) {
                        diagReport(DiagReportLevel.ERROR, vd.toTokens(),
                            "`static` member variable must use @JsonIgnore",
                            "must use @JsonIgnore")
                    }
                     this.allFields.add(field)
                case _ => ()
            }
        }

        cd.body.decls.add(createFromJsonFunc())
        cd.body.decls.add(createToJsonFunc())

        cd.body.decls.add(createSerializeFunc())
        cd.body.decls.add(createDeserializeFunc())

        // 只有在有可能被继承的情况下，才需要生成这2个方法，用于子类调用父类的对应方法。
        if (this.isOpen) {
            cd.body.decls.add(createSerializeToFunc())
            cd.body.decls.add(createDeserializeToFunc())
        }

        return cd.toTokens()
    }
}

