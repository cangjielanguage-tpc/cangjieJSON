package cjjson

public class JsonTypeMismatch <: Exception {
    public init(className: String, fieldName: String, expectedType: String, actualType: String) {
        super("'${className}.${fieldName}' mismatch type, expect '${expectedType}', actually got '${actualType}'")
    }
}

public class JsonFieldNotExist <: Exception {
    public init(className: String, fieldName: String) {
        super("'${className}.${fieldName}' not exist")
    }
}

public class JsonGetValueException <: Exception {
    public init(message: String) {
        super(message)
    }
}