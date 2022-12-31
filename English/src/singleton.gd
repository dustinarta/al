tool
extends Node

"""
This is a script for singleton of "English"
"""

var data :Dictionary

func read(sentence :String)->Array:
	sentence = sentence.to_lower()
	var each = sentence.split(" ")
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
		if data.has(key):
			result[i] = data[key]
	
	return result

func report_null(result)->void:
	var words = result[0] as Array
	var type = result[1] as Array
	var size = words.size()
	
	var missing = []
	var pos = 0
	while(pos < size):
		pos = type.find(null, pos+1)
		if pos == -1:
			break
		else:
			missing.push_back(words[pos])
			
	if missing.size() == 0:
		print("No missing")
	else:
		print("Missing: " + str(missing))
