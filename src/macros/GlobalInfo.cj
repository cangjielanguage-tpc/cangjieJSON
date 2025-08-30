macro package cjjson.macros

import std.collection.*

// 用于记录当前正在进行宏展开的 class/struct/enum 类型的成员列表的嵌套宏信息。
class GlobalInfo {
    private static var instance = GlobalInfo()

    private let jsonIgnoreSet = HashSet<String>()
    private let jsonIgnoreNullSet = HashSet<String>()
    private let jsonNameMap = HashMap<String, String>()

    private init() {
    }

    public static func current(): GlobalInfo {
        return instance
    }

    public func reset() {
        jsonIgnoreSet.clear()
        jsonIgnoreNullSet.clear()
        jsonNameMap.clear()
    }

    public func setJsonIgnore(fieldName: String) {
        jsonIgnoreSet.add(fieldName)
    }
    
    public func isJsonIgnore(fieldName: String): Bool {
        return jsonIgnoreSet.contains(fieldName)
    }

    public func setJsonIgnoreNull(fieldName: String) {
        jsonIgnoreNullSet.add(fieldName)
    }
    
    public func isJsonIgnoreNull(fieldName: String) {
        return jsonIgnoreNullSet.contains(fieldName)
    }

    public func setJsonName(fieldName: String, jsonName: String) {
        jsonNameMap.add(fieldName, jsonName)
    }

    public func getJsonName(fieldName: String): ?String {
        return jsonNameMap.get(fieldName)
    }
}