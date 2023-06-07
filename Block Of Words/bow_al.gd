@tool
extends Node

const Block = BOW.Block
const path = "res://Block Of Words/code.txt"
const HEADER = "!!"

var sourcecode:String
var code

func init(path:String = ""):
	if path == "":
		printerr("Expected path!")
	sourcecode = FileAccess.open(path, FileAccess.READ).get_as_text()
	code = _load(sourcecode)

func run():
	pass


func _load(code:String):
	var block = Block.new()
	var lines:Array = code.split("\n")
	lines = filter(lines)
	var lines2 = filter2(lines)
	print("lines 2 ", lines2)
	
	return parse(lines2[0])

func parse(eachs:PackedStringArray):
	var result:Block = Block.new()
	result.words.append(HEADER)
	print(eachs)
	
	const parseindex = {
		"this" = 0,
		"that" = 0,
		"sentence" = 0,
		"is" = 1,
		"be" = 1,
		"do" = 1,
		"if" = 2,
		"has" = 1,
		"type" = 0,
		"." = -1,
		":" = -1,
		"," = -1,
		";" = -1,
		question = 0,
		subject = 0,
		object = 0,
		object2 = 0,
		verb = 0,
		verb2 = 0,
		descripton = 0,
		emptydescripton = 0,
		adverb = 0
	}
	
	var functionindex:Array[Callable] = [_eat_var, _eat_fun, _eat_con]
	
	var i = 0
	var limit = eachs.size()
	while i < limit:
		var each = eachs[i]
		var choice = parseindex[each]
		var child
		if choice == -1:
			child = Block.new(each)
		else:
			child = functionindex[choice].call(eachs, i)
		print(i)
		i += child.total()
		result.add_child(child)
	
	return result

func _eat_var(stringarray:PackedStringArray, index:int)->Block:
	var result:Block
	var child
	var this = stringarray[index]
#	if this == "this":
#		child = Block.new(this)
#	index += 1
#	this = stringarray[index]
	if this == "sentence":
		result = Block.new(this).set_type1(Instruction.Var)
		index += 1
		this = stringarray[index]
		if this == "type":
			child = Block.new(this)
			if child != null:
				result.set_atchild(0).add_child(child).set_atparent(0)
	elif this == "type":
		result = Block.new(this).set_type1(Instruction.Var)
		index += 1
		this = stringarray[index]
		if BOW.SENTENCE_PART.has(this.to_upper()):
			child = Block.new(this)
			result.set_atchild(0).add_child(child).set_atparent(0)
	return result

func _eat_fun(stringarray:PackedStringArray, index:int)->Block:
	var result:Block
	var child
	var this = stringarray[index]
	if false:
		pass
	else:
		result = Block.new(this).set_type1(Instruction.Fun)
	return result

func _eat_con(stringarray:PackedStringArray, index:int)->Block:
	var result:Block
	var this = stringarray[index]
	result = Block.new(this)
	return result

enum Instruction {
	Var,
	Fun,
	Con
}

enum VariableType {
	Sentence,
	Value,
	Regitser,
	Type
}

func filter(packedstring:PackedStringArray)->PackedStringArray:
	var result:PackedStringArray = packedstring.duplicate()
	var counter = 0
	for s in range(packedstring.size()-1, -1, -1):
		result[s] = result[s].strip_edges()
		if result[s].length() == 0:
			result.remove_at(s)
			counter += 1
	return result

func filter2(packedstring:PackedStringArray)->Array:
	var result:Array = []
	var size:int = packedstring.size()
	var lines:Array[PackedStringArray]
	lines.resize(size)
	
	for i in range(size):
		lines[i] = packedstring[i].split(" ")
	print(" this is ", lines)
	
	for i in range(size):
		var line:PackedStringArray
		var thisline = lines[i]
		for j in range(thisline.size()):
			var string = thisline[j]
			var s = string[-1]
			if [":", ",", ";", "."].has(s):
				string = string.substr(0, string.length()-1)
				line.append(string)
				line.append(s)
			else:
				line.append(string)
		result.append(line)
	print(" return ", result)
	return result


