macro package cjjson.macros

import std.ast.*
import std.collection.*

class HandleClass {
    private let cd: ClassDecl
    private var modifiers: Tokens
    private var className: Token
    private var superTypes: Tokens
    private var body: Tokens
    private let allFields = ArrayList<FieldInfo>()
    
    public init(cd: ClassDecl) {
        this.cd = cd
        this.modifiers = cd.modifiers.toTokens()
        this.className = cd.identifier
        this.superTypes = cd.superTypes.toTokens()
        this.body = cd.body.decls.toTokens()
    }

    private func addSuperTypes() {
        if (this.superTypes.size == 0) {
            superTypes = quote(IJsonAdapter<$(this.className)>)
        } else {
            superTypes = quote($(cd.superTypes) & IJsonAdapter<$(this.className)>)
        }
    }

    private func createDeserializeFunc(): Tokens {
        var funcBody = Tokens()

        for (field in allFields) {
            if (field.isIgnore) {
                continue
            }
            let identifier = field.vd.identifier
            let jsonName = field.getJsonName()
            let typeInfo = field.vd.declType
            let typeInfoString = typeInfo.toTokens().toString()

            if (isOptionType(typeInfo)) {
                let baseType = getOptionBaseType(typeInfo)
                funcBody.append(quote(
                    try {
                        obj.$identifier = Option<$baseType>.deserialize(dms.get($jsonName))
                    } catch (e: DataModelException) {
                        let dm = dms.get($jsonName)
                        if (dm.isNull()) {
                            throw JsonFieldNotExist($(this.className.value), $jsonName)
                        } else {
                            throw JsonTypeMismatch($(this.className.value), $jsonName, $(typeInfoString), dm.toJsonType())
                        }
                    }
                ))
            } else {
                funcBody.append(quote(
                    try {
                        obj.$identifier = $typeInfo.deserialize(dms.get($jsonName))
                    } catch (e: DataModelException) {
                        let dm = dms.get($jsonName)
                        if (dm.isNull()) {
                            throw JsonFieldNotExist($(this.className.value), $jsonName)
                        } else {
                            throw JsonTypeMismatch($(this.className.value), $jsonName, $(typeInfoString), dm.toJsonType())
                        }
                    }
                ))
            }
        }

        let exceptionString = "${className.value}: not a DataModelStruct"

        return quote(
            public static func deserialize(dataModel: DataModel): $className {
                var dms: DataModelStruct = match(dataModel) {
                    case data: DataModelStruct => data
                    case _ => throw Exception($exceptionString)
                }
                let obj = $className()

                $funcBody
                return obj
            }
        )
    }

    private func createSerializeFunc(): Tokens {
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
                    dms.add(field($(jsonName), $(field.vd.identifier)))
                ))
            }
        }

        return quote(
            public func serialize(): DataModel {
                let dms = DataModelStruct()
                $funcBody
                return dms
            }
        )
    }

    private func createFromJsonFunc(): Tokens {
        return quote(
            public static func fromJson(str: String): $className {
                let dm = DataModel.fromJson(JsonValue.fromStr(str))
                return $className.deserialize(dm)
            }
        )
    }

    private func createToJsonFunc(): Tokens {
        return quote(
            public func toJson(): String {
                return this.serialize().toJson().toString()
            }
        )
    }

    public func toTokens(): Tokens {
        addSuperTypes()

        // collect all fields
        for (decl in cd.body.decls) {
            match (decl) {
                case vd: VarDecl =>
                    let field = FieldInfo(vd)
                    if ((field.isPrivate || field.isStatic) && !field.isIgnore) {
                        diagReport(DiagReportLevel.ERROR, vd.toTokens(),
                            "`private` or `static` member variable must use @JsonIgnore",
                            "must use @JsonIgnore")
                    }
                     this.allFields.append(field)
                case _ => ()
            }
        }

        body += createDeserializeFunc()
        body += createSerializeFunc()
        body += createFromJsonFunc()
        body += createToJsonFunc()

        return quote(
            $modifiers class $className <: $superTypes {
                $body
            }
        )
    }
}

class FieldInfo {
    public var isIgnore: Bool
    public var isIgnoreNull: Bool
    public var jsonName: ?String
    public var typeNode: ?TypeNode = None

    public var isPrivate: Bool = false
    public var isStatic: Bool = false

    public FieldInfo(
        public let vd: VarDecl
    ) {
        let identifierString = vd.identifier.value
        isIgnore = GlobalInfo.current().isJsonIgnore(identifierString)
        isIgnoreNull = GlobalInfo.current().isJsonIgnoreNull(identifierString)
        jsonName = GlobalInfo.current().getJsonName(identifierString)
        // println("FieldInfo: get '${identifierString}' with '${jsonName}'")

        // 没有用 @JsonIgnore 标记的成员，检查是否显式的声明了其类型
        if (!isIgnore) {
            try {
                typeNode = vd.declType
            } catch (e: ASTException) {
                diagReport(DiagReportLevel.ERROR, vd.identifier.toTokens(),
                    "filed without @JsonIgnore must explicitly declare its type",
                    "must explicitly declare its type")
            }
        }

        for(mod in vd.modifiers) {
            match (mod.toTokens().toString()) {
                case "private" => isPrivate = true
                case "static" => isStatic = true
                case _ => ()
            }
        }
    }

    public func getJsonName(): String {
        if (let Some(v) <- jsonName) {
            return v
        } else {
            unwrapRawIdentifier(vd.identifier)
        }
    }
}