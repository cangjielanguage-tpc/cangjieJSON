macro package cjjson.macros

import std.ast.*
import std.collection.*

class HandleClass {
    private let cd: ClassDecl
    private var modifiers: Tokens
    private var className: Token
    private var superTypes: Tokens
    private var body: Tokens
    private let allFields: ArrayList<VarDecl>
    
    public init(cd: ClassDecl) {
        this.cd = cd
        this.modifiers = cd.modifiers.toTokens()
        this.className = cd.identifier
        this.superTypes = cd.superTypes.toTokens()
        this.body = cd.body.decls.toTokens()
        this.allFields = ArrayList<VarDecl>()
    }

    private func addSuperTypes() {
        if (this.superTypes.size == 0) {
            superTypes = quote(IJsonAdapter<$(this.className)>)
        } else {
            superTypes = quote($(cd.superTypes) & IJsonAdapter<$(this.className)>)
        }
    }

    private func isPrivateVarDecl(vd: VarDecl): Bool {
        for(mod in vd.modifiers) {
            if (mod.toTokens().toString() == "private") {
                return true
            }
        }
        return false
    }

    private func createDeserializeFunc(): Tokens {
        var funcBody = Tokens()

        for (field in allFields) {
            let identifier = field.identifier
            let identifierString = unwrapRawIdentifier(identifier)
            let typeInfo = field.declType
            let typeInfoString = typeInfo.toTokens().toString()

            if (isOptionType(typeInfo)) {
                let baseType = getOptionBaseType(typeInfo)
                funcBody.append(quote(
                    try {
                        obj.$identifier = Option<$baseType>.deserialize(dms.get($identifierString))
                    } catch (e: DataModelException) {
                        let dm = dms.get($identifierString)
                        let actualType = match(dm) {
                            case b: DataModelBool => "Bool"
                            case f: DataModelFloat => "Float64"
                            case i: DataModelInt => "Int64"
                            case seq: DataModelSeq => "ArrayList"
                            case str: DataModelString => "String"
                            case obj: DataModelStruct => "class"
                            case n: DataModelNull => throw JsonFieldNotExist($(this.className.value), $identifierString)
                            case _ => "UNKNOWN"
                        }
                        throw JsonTypeMismatch($(this.className.value), $identifierString, $(typeInfoString), actualType)
                    }
                ))
            } else {
                funcBody.append(quote(
                    try {
                        obj.$identifier = $typeInfo.deserialize(dms.get($identifierString))
                    } catch (e: DataModelException) {
                        let dm = dms.get($identifierString)
                        let actualType = match(dm) {
                            case b: DataModelBool => "Bool"
                            case f: DataModelFloat => "Float64"
                            case i: DataModelInt => "Int64"
                            case seq: DataModelSeq => "ArrayList"
                            case str: DataModelString => "String"
                            case obj: DataModelStruct => "class"
                            case n: DataModelNull => throw JsonFieldNotExist($(this.className.value), $identifierString)
                            case _ => "UNKNOWN"
                        }
                        throw JsonTypeMismatch($(this.className.value), $identifierString, $(typeInfoString), actualType)
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
            let identifierString = unwrapRawIdentifier(field.identifier)
            funcBody.append(quote(
                dms.add(field($(identifierString), $(field.identifier)))
            ))
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
                    if (isPrivateVarDecl(vd)) {
                        diagReport(DiagReportLevel.WARNING, vd.toTokens(), 
                            "`private` members will be ignored when serializing or deserializing",
                            "`private` members will be ignored when serializing or deserializing")
                    } else {
                        this.allFields.append(vd)
                    }
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