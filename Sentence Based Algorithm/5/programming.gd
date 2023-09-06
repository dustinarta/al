extends RefCounted
class_name SBA5_Program

var lines:PackedStringArray

func _init():
	pass

func init():
	pass

func write(sentence:String):
	var split = sentence.split("\n")
	if lines.is_empty():
		lines.append_array(split)
	else:
		lines[-1] += split[0]
		lines.append_array(split.slice(1))

static func generatelabel(length:int = 5)->String:
	var name:String
	var alphabet = "abcdefghijklmnopqrstuvwxyz"
	var vocal = "aeiou"
	var nonvocal = "bcdfghjklmnpqrstvwxyz"
	
	for i in range(length):
		var letter:String = alphabet[randi()%26]
		var word:String = letter
		if letter in vocal:
			word += nonvocal[randi()%21]
		else:
			word += vocal[randi()%5]
			if randi() % 1:
				word += nonvocal[randi()%21]
		name += word
	
	return name
