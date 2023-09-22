@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var ap = AP2.new()
	ap.load("res://Attention Parser/2/data.json")
	var res1
	var res2
#	res = ap.read("i have a dog")
#	res = ap.read("the great alexander is a good man")
#	res = ap.read("he move the table")
#	res = ap.parse_phrase(
#		"the dog is running in park".split(" "), 
#		"JA NC VA V_ R_ NC".split(" ")
#	)
#	res1 = ap.read_s("cat is as big as the dog")
#	print(res1)
	
	res1 = ap.parse_phrase_s(
#		"my dog is too big"
#		"he climb the tree and he fell"
#		"my dog and cat are climbing the very big tree in that backyard and almost fell"
#		"cat, dog, and frog are animal"
#		"not only me"
#		"i will be big"
#		"this cat is as big as the dog"
#		"the dog fell as it climb"
#		"if the dog is climbing, it fell"
#		"andy lukito is programmer"
		"where do alex run?"
	)
	print(res1)
	res2 = ap.guess_phrase(res1)
	print(res2)
	res1.apply(res2)
	print(res1)
	
#	ap.Words["the"]["thinker"]
#	ap.learn_base(
#		"is running",
#		"VA V_"
#	)
#	ap.learn(
#		"the thinker is a good man",
#		"NP NP VA JA J_ NC"
#	)
	
#	ap.learn(
#		"myself yourself themself ourself himself herself itself",
#		"P_ P_ P_ P_ P_ P_ P_"
#	)
	
	
#	ap.save("res://Attention Parser/2/data.json")
