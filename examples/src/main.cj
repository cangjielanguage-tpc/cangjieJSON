package examples
import std.collection.*

// 导入相关依赖包
import cjjson.*
import cjjson.macros.*
import encoding.json.*
@JsonAdapter
public class Basic {
    public var a: Int64 = 0
    public var b: String = ""
    public var c: ?String = None
    public var d: Array<Int64> = Array<Int64>()
    public var e: ArrayList<String> = ArrayList<String>()
    public var f: HashMap<String, Int64> = HashMap<String, Int64>()

    // other member functions
}

main() {
    test_JsonAdapter()

    test_JsonName()

    test_JsonIgnore()

    test_JsonIgnoreNull()
}