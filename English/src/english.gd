tool
extends Node

"""
This is a script for singleton of "English"
"""

enum NOUN {
	COMMON
	PROPER
	IDEA
	COLLECTIVE
}

enum PRONOUN {
	RELATIVE 
	INDEFINITE 
	DEMONSTRATIVE
	POSSESIVE
	INTENSIVE 
}

var data :Dictionary

func read(sentence :String)->Array:
	var each = parse(sentence.to_lower())
	var results:Array
	results.append(each)
	results.append(find_speech(each))
	
	report_null([each, results[1]])
	
	return results

func init(path = "res://English/dataset-key.json"):
	var f = File.new()
	f.open(path, File.READ)
	var s = f.get_as_text()
	data = JSON.parse(s).result as Dictionary
	
	f.close()

func find_speech(words:Array)->Array:
	var result = []
	result.resize(words.size())
	
	for i in range(words.size()):
		var key = words[i]
		if key is SC:
			result[i] = key
			continue
		if data.has(key):
			result[i] = data[key]
#	print(result)
	return result

func parse(sentence:String):
	var each = sentence.split(" ")
	var res:Array
	
	for s in each:
		var is_sc = false
		var fc:String #first index char
		var lc:String #last index char
		var f:int #first index
		var l:int #last index
		var size = s.length()
#		print(s + " " + str(size))
		
		for j in range(size):
			fc = s[j]
			match(fc):
				"(", "[", "{", "\"", "'":
					res.append(SC.new(fc))
				_:
					f = j
					break
#		print(f)
		var back:Array
		for j in range(size-1, 0, -1):
			lc = s[j]
			match(lc):
				"/", ")", "]", "}", "\"", "'", ",", ".", ";", ":":
					back.append(SC.new(lc))
				_:
					l = j
					break
			
		res.append(s.substr(f, l-f+1))
		res.append_array(back)
		
	return res

func report_null(result)->void:
	var words = result[0] as Array
	var type = result[1] as Array
	var size = words.size()
	
	var missing:Array = []
	var pos:int = 0
	while(pos < size):
		pos = type.find(null, pos)
		if pos == -1:
			break
		else:
			missing.push_back(words[pos])
			pos += 1
			
	if missing.size() == 0:
		print("No missing")
	else:
		print("Missing: " + str(missing))


func _to_string():
	var result = "English Singleton : {\n"
	result += "\tword count = " + str(data.size())
	result += "\n}"
	return result
	
class SC:
	var c:String
	
	func _init(c:String = ""):
		self.c = c
	
	func _to_string():
		return "SP: \"" + c + "\""
