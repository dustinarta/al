@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var input = {
		"#E" : "End of Sentence", 
		"," : "Comma"
	}
	input.merge( 
		JSON.parse_string(
			FileAccess.open("res://English/data/english.json", FileAccess.READ).get_as_text()
		)
	)
	var output = {
		"#S" : "Start of Sentence", 
		"#E" : "End of Sentence", 
		",E" : "Comma for element", 
		",S" : "Comma for sentence", 
		"NC" : "Noun common", 
		"NP" : "Noun proper", 
		"P_" : "Pronoun", 
		"PP" : "Personal Pronoun", 
		"V_" : "Verb", 
		"VH" : "Verb Helping", 
		"J_" : "Adjective", 
		"BE" : "Adverb for element", 
		"BS" : "Adverb for sentence", 
		"R_" : "Preposition", 
		"CE" : "Conjunction for element", 
		"CS" : "Conjunction for sentence", 
		"IJ" : "Interjection"
	}
#	Transformer.create(
#		"res://Transformer/test memory.json", 8,
#		[
#			"#EOS", ",", "i", "have", "a", "dog"
#		],
#		[
#			"#SOS", "#EOS", "#CE", "#CS", 
#			"NN", "PN", "PP", "VB", "AJ", "AV", "PR", "CE", "CS", "IJ"
#		]
#	)
	Transformer.create(
		"res://Transformer/test memory.json", 8,
		input.keys(),
		output.keys()
	)
	print("done")
