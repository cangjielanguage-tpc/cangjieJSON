package cjjson

public interface DataModelExtend {
    func isNull(): Bool
    func toJsonType(): String
}

extend DataModel <: DataModelExtend {
    public func isNull(): Bool {
        let typeName = this.toJsonType()
        return typeName == "null" || typeName == "UNKNOWN"
    }

    public func toJsonType(): String {
        match (this) {
            case b: DataModelBool => "JSON bool"
                case f: DataModelFloat => "JSON number (int)"
                case i: DataModelInt => "JSON number (float)"
                case seq: DataModelSeq => "JSON array"
                case str: DataModelString => "JSON string"
                case obj: DataModelStruct => "JSON object"
                case n: DataModelNull => "null"
                case _ => "UNKNOWN"
        }
    }
}