extends RefCounted
class_name SBA5_ProgramHigh

func parse_s(sentence:String):
	var splits:PackedStringArray = sentence.split("\n")
	return parse(splits)

func parse(splits:PackedStringArray):
	var script:PackedStringArray
	var tab:String
	var end:String
	var pointer:DS.Pointer = DS.Pointer.new().write(0)
	for i in range(splits.size()):
		var split = splits[i]
		var line:PackedStringArray
		if split.is_empty():
			script.append("\n")
			continue
		pointer.write(0)
		line = splitters(split)
		end = line[-1]
		print(line)
		script.append(
			tab + recode(line, pointer, line.size()-1)
		)
		if end == ":":
			tab += "\t"
		elif end == ".":
			tab = tab.substr(0, -2)
	return "\n".join( script )

func recode(line:PackedStringArray, index:DS.Pointer, limit:int, once:bool = false)->String:
#	print(line)
	var word:String = line[index.data]
	var nextword:String
	var result:String
	if word == "declare":
		index.data += 1
		nextword = line[index.data]
		result = "var " + nextword
		index.data += 1
		if index.data < limit:
			nextword = line[index.data]
			if nextword == "as":
				index.data += 1
				result += ":" + line[index.data]
				index.data += 1
				if index.data < limit:
					nextword = line[index.data]
					if nextword == "to":
						index.data += 1
						result += " = " + line[index.data]
			elif nextword == "to":
				index.data += 1
				result += " = " + line[index.data]
	elif word == "set":
		index.data += 1
		nextword = line[index.data]
		result = nextword
		index.data += 1
		if index.data < limit:
			nextword = line[index.data]
			if nextword == "at":
				index.data += 1
				result += "[" + line[index.data] + "]"
				index.data += 1
				if index.data < limit:
					nextword = line[index.data]
					if nextword == "to":
						index.data += 1
						nextword = line[index.data]
						if nextword == "what":
							nextword = recode(line, index, limit, true)
						result += " = " + nextword
			elif nextword == "to":
				index.data += 1
				nextword = line[index.data]
				if nextword == "what":
					nextword = recode(line, index, limit, true)
				result += " = " + nextword
	elif word == "if":
		index.data += 1
		nextword = line[index.data]
		result = "if " + nextword
		index.data += 1
		if index.data < limit:
			nextword = line[index.data]
			if nextword == "equal":
				index.data += 1
				nextword = line[index.data]
				result += " == " + nextword
			if nextword == "not_equal":
				index.data += 1
				nextword = line[index.data]
				result += " != " + nextword
			if nextword == "less_than":
				index.data += 1
				nextword = line[index.data]
				result += " < " + nextword
			elif nextword == "more_than":
				index.data += 1
				nextword = line[index.data]
				result += " > " + nextword
			elif nextword == "less_equal_than":
				index.data += 1
				nextword = line[index.data]
				result += " <= " + nextword
			elif nextword == "more_equal_than":
				index.data += 1
				nextword = line[index.data]
				result += " >= " + nextword
		result += ":"
	elif word == "return":
		index.data += 1
		if index.data < limit:
			nextword = line[index.data]
			result = "return " + nextword
		else:
			result = "return"
	elif word == "call":
		index.data += 1
		nextword = line[index.data]
		result = nextword + "()"
	elif word == "on":
		index.data += 1
		nextword = line[index.data]
		index.data += 1
		result = nextword + "." + recode(line, index, limit)
	elif word == "what":
		index.data += 1
		nextword = line[index.data]
		index.data += 1
		result = "(" + nextword + " " + recode(line, index, limit, true) + ")"
	elif word == "add":
		index.data += 1
		nextword = line[index.data]
		if nextword == "what":
#			index.data += 1
			result = "+ (" + recode(line, index, limit) + ")"
		else:
			result = "+ " + nextword
	elif word == "min":
		index.data += 1
		nextword = line[index.data]
		if nextword == "what":
#			index.data += 1
			result = "- (" + recode(line, index, limit) + ")"
		else:
			result = "- " + nextword
	elif word == "mul":
		index.data += 1
		nextword = line[index.data]
		if nextword == "what":
#			index.data += 1
			result = "* (" + recode(line, index, limit) + ")"
		else:
			result = "* " + nextword
	elif word == "div":
		index.data += 1
		nextword = line[index.data]
		if nextword == "what":
#			index.data += 1
			result = "/ (" + recode(line, index, limit) + ")"
		else:
			result = "/ " + nextword
	elif word == "mod":
		index.data += 1
		nextword = line[index.data]
		if nextword == "what":
#			index.data += 1
			result = "% (" + recode(line, index, limit) + ")"
		else:
			result = "% " + nextword
	else:
		printerr("uncatched recode for ", word)
	
	if index.data+1 < limit and not once:
		index.data += 1
		result += " " + recode(line, index, limit)
	
	return result

func splitters(sentence:String):
	var result:PackedStringArray
	var split = sentence.split(" ")
	var size:int = split.size()
	var word:String
	var w1:String
	var i:int = 0
	while i < size:
		word = split[i]
		w1 = word[0]
		var value:String
		var pos = "\"[{".find(w1)
		if pos != -1:
			if pos == 1:
				w1 = "]"
			elif pos == 2:
				w1 = "}"
			if word[-1] != w1:
				for j in range(i, size):
					word = split[j]
					value += word
					if word[-1] == w1 or word[-1] in ":;.":
						word = value
						i = j
						break
		result.append(word)
		i += 1
	word = result[-1]
	w1 = word[-1]
	if w1 in ":;.":
		word = word.substr(0, word.length()-1)
		result[-1] = word
		result.append(w1)
	
	return result




