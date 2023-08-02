@tool
extends EditorScript


func _run():
	var t = Transformer.new()
	t.load("res://Transformer/test memory.json")
	#t.positional_encoding(4, 4)
#	print(t.positional_encoding(4, 8))
#	print(t.words_to_vectors("i have a dog"))
	print(t.encode("i have a dog"))
	t.setup_decoder()
	print(t.decode())
#	print(t.decode())
#	print(t.decode())
#	print(t.decoder_result)
#	t.save("res://Transformer/test memory.json")
