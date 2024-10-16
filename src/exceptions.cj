package cjjson

public class JsonDecodingException <: Exception {
    public init(className: String, fieldName: String, expectedType: String, actualType: String) {
        super("'${className}.${fieldName}' mismatch type, expect '${expectedType}', actually got '${actualType}'")
    }
}