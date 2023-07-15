extends Node
class_name SCS

func _init():
	pass

func init():
	pass

func sentence_combine(sen1, sen2):
	pass

func sentence_conclude(rule, main):
	pass

class Sentence:
	static var keys:Dictionary
	var words_str:PackedStringArray
	var words_id:PackedInt64Array
	
	func _init():
		pass
	
	func init(sentence:String):
		var splits:PackedStringArray = sentence.split(" ")
		for s in splits:
			words_str.append(s)
			words_id.append( keys[s] )
		return self
