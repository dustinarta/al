@tool
extends RefCounted
class_name CompilerEngine

func _init():
    pass

class Rules:
    var keyword:String
    var front:String
    var back:String
    var keep_escape:bool
    var type:SYNTAXTYPE

    enum SYNTAXTYPE {
        KEYWORD,
        OPEN,
        CLOSE,
        OPENCLOSE
    }