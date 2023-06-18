@tool
extends RefCounted
class_name SEM

const SPESIAL_CHAR:PackedStringArray =[".", ",", ":", ";", "!", "?"]

var embedding_input:NN3
var embedding_output:NN3
var vec2word:NN3
var vec_count:int
var encoder:MultiLSTM
var decoder:MultiLSTM

var decoder_input:Array

var keys:Dictionary
var path:String

func _init():
	embedding_input = NN3.new()
	encoder = MultiLSTM.new()
	decoder = MultiLSTM.new()
	embedding_output = NN3.new()
	vec2word = NN3.new()

func create(paragraph:PackedStringArray, vec_count:int):
	_init_keys()
	read_word(paragraph)
	self.vec_count = vec_count
	var size = keys.size()
	embedding_input.init([size, vec_count], [NN3.ACTIVATION.NONE], true)
	encoder.init(vec_count)
	decoder.init(vec_count)
	embedding_output.init([size, vec_count], [NN3.ACTIVATION.NONE], true)
	vec2word.init([vec_count, size], [NN3.ACTIVATION.SOFTMAX], true)

func _init_keys():
	keys["\\sos"] = 0
	keys["\\eos"] = 1
	
	for s in range(2, SPESIAL_CHAR.size()+2):
		keys[SPESIAL_CHAR[s-2]] = s

func read_word(paragraph:PackedStringArray):
	for split in paragraph:
		var splits:PackedStringArray = split.split(" ")
		
		for s in splits:
			if SPESIAL_CHAR.has(s[-1]):
				s = s.left(s.length()-1)
				print(s)
			if not keys.has(s):
				keys[s] = keys.size()

func push(input:String, max:int = 100):
	encoder.init_all()
	decoder.init_all()
	var inputs_id = words_to_vectors(input)
	var vector_count
	
	var vectors:Array
#	 = wordid_many_to_vector(inputs_id)
	vector_count = vectors.size()
	var results
#	for en in range(vector_count):
#		print("ini disini")
	
	push_encoder(inputs_id)
	decoder.move_memory(encoder)
	
	var answer_id:PackedInt64Array
	var word_id:int = 0
	var limit = max
	while true:
		vectors = embedding_output.forward_by_id([word_id])
		results = decoder.forward_col([vectors])
		word_id = highest( vec2word.forward(decoder.get_output()) )
		if word_id == 1:
			break
		answer_id.append(word_id)
		limit -= 1
		if limit == 0:
			break
#	results = transpose(results)
#	results = transpose(results[-1])
#	print(results)
#	print(keys.keys()[highest])
	var answer:String = wordid_to_sentence(answer_id)
	return answer

func push_to_id(input:String, max:int = 100):
	encoder.init_all()
	decoder.init_all()
	var inputs_id
	var answer_id:PackedInt64Array
	
	inputs_id = words_to_vectors(input)
	push_encoder(inputs_id)
	decoder.move_memory(encoder)
	answer_id = push_decoder(max)
	
#	results = transpose(results)
#	results = transpose(results[-1])
#	print(results)
#	print(keys.keys()[highest])
	return answer_id

func push_by_id_to_id(inputs_id:PackedInt64Array, max:int = 100):
	encoder.init_all()
	decoder.init_all()
	var answer_id:PackedInt64Array
	
	push_encoder(inputs_id)
	decoder.move_memory(encoder)
	answer_id = push_decoder(max)
	
#	results = transpose(results)
#	results = transpose(results[-1])
#	print(results)
#	print(keys.keys()[highest])
	return answer_id

func push_encoder(vectors:Array):
	var vector
	for v in range(vectors.size()):
		vector = embedding_input.forward_by_id( [vectors[v]] )
		encoder.forward_col( [vector] )

func push_decoder(limit:int)->PackedInt64Array:
	decoder_input = []
	var answer_id:PackedInt64Array
	var vector
	var word_id:int = 0
	for i in range(limit):
		vector = embedding_output.forward_by_id([word_id])
		decoder_input.append(vector)
		decoder.forward_col([vector])
		word_id = highest( vec2word.forward(decoder.get_output()) )
		answer_id.append(word_id)
		if word_id == 1:
			break
		limit -= 1
		if limit == 0:
			break
	print("answer id ", answer_id)
	return answer_id

func wordid_to_vector(id:int):
	return embedding_input.forward_by_id([id])

func wordid_many_to_vector(ids:PackedInt64Array)->Array[PackedFloat64Array]:
	var size = ids.size()
	var vectors:Array[PackedFloat64Array]
	vectors.resize(size)
	for i in range(size):
		vectors[i] = embedding_input.forward_by_id([ids[i]])[-1]
	return vectors

func wordid_to_sentence(word_id:PackedInt64Array):
	var s:String = ""
	var keys = self.keys.keys()
	var values = self.keys.values()
#	print(keys)
#	print(values)
#	print(word_id)
	for k in word_id:
		var at = values.find(float(k))
		print(at)
		s += keys[at] + " "
	return s

func train(input:String, output:String):
	var inputs_id:PackedInt64Array = words_to_vectors(input)
	var outputs_id:PackedInt64Array = words_to_vectors(output)
	outputs_id.append(1)
	var output_len = outputs_id.size()
	var output_false
	
	for c in range(10):
	
		encoder.init_all()
		decoder.init_all()
		
		push_encoder(inputs_id)
		decoder.move_memory(encoder)
		output_false = push_decoder(output_len)
#
#		_train_decoder(output_false, outputs_id)
#		print("returning because debug")
#		return null
		
		var expected:PackedInt64Array
		var expecteds:Array
		expecteds.resize(output_len)
		var key_size = keys.size()
		for i in range(output_len):
			expected = []
			expected.resize(key_size)
			expected.fill(0)
			expected[outputs_id[i]] = 1
			expecteds[i] = expected
		
		var vec2word_input = decoder.get_all_stm_col()
		var decoder_error = transpose( vec2word._train_many_with_expected(vec2word_input, expecteds) )
		var embedding_output_vectors
		
		decoder_input = transpose(decoder_input)
	#	print(decoder_input)
	#	print(decoder_error)
		embedding_output_vectors = decoder.train_with_errors_get_input_error(decoder_input, decoder_error)
		embedding_output_vectors = transpose(embedding_output_vectors)
#		print(embedding_output_vectors)
		var embedding_output_inputs:Array
		var embedding_output_input:Array
		embedding_output_inputs.resize(output_len)
		embedding_output_inputs[0] = []
		embedding_output_inputs[0].resize(key_size)
		embedding_output_inputs[0].fill(0)
		embedding_output_inputs[0][1] = 1
		for i in range(1, output_len):
			embedding_output_input = []
			embedding_output_input.resize(key_size)
			embedding_output_input.fill(0)
			embedding_output_input[outputs_id[i-1]] = 1
			embedding_output_inputs[i] = embedding_output_input
		print(embedding_output_vectors)
		print(embedding_output_inputs)
		for i in range(output_len):
			embedding_output._train_with_error(embedding_output_inputs[i], embedding_output_vectors[i])
#	print()
#	vec2word._train_many_with_expected()

func _train_decoder(output:PackedInt64Array, expected:PackedInt64Array):
	var len = expected.size()
	var expected_array:PackedInt64Array
	var expecteds_array:Array
	expecteds_array.resize(len)
	var key_size = keys.size()
	for i in range(len):
		expected_array = []
		expected_array.resize(key_size)
		expected_array.fill(0)
		expected_array[expected[i]] = 1
		expecteds_array[i] = expected_array
	
	for i in range(1000):
		vec2word._train_many_with_expected(decoder_input, expecteds_array)
#	print(highest(vec2word.forward(decoder_input[0])))
#	print(keys.keys()[highest(vec2word.forward(decoder_input[0]))])
#	print(expecteds_array)

func transpose(data:Array):
	var row_len = data.size()
	var col_len = data[0].size()
	
	for i in range(1, row_len):
		if data[i].size() != col_len:
			printerr("invalid count!")
	var new_data:Array = []
	new_data.resize(col_len)
	for r in range(col_len):
		var new_column:Array = []
		new_column.resize(row_len)
		for c in range(row_len):
			new_column[c] = data[c][r]
		new_data[r] = new_column
	return new_data

func string_to_id(packedstring:PackedStringArray):
	var size:int = packedstring.size()
	var packedid:PackedInt64Array
	packedid.resize(size)
	
	for i in range(size):
		packedid[i] = keys[packedstring[i]]
	
	return packedid

func split_sentence(sentence:String):
	var split:PackedStringArray = []
	var splits:PackedStringArray = sentence.split(" ")
	
	for s in splits:
		if SPESIAL_CHAR.has(s[-1]):
			s = s.left(s.length()-1)
		split.append(s)
	return split

func words_to_vectors(sentence:String)->PackedInt64Array:
	var packedid:PackedInt64Array = []
	var splits:PackedStringArray = sentence.split(" ")
	
	for s in splits:
		var char:String = ""
		if SPESIAL_CHAR.has(s[-1]):
			char = s[-1]
			s = s.left(s.length()-1)
		packedid.append(keys[s])
		if char:
			packedid.append(keys[char])
	return packedid

func highest(packedfloat:PackedFloat64Array):
	var at:int = 0
	
	for i in range(packedfloat.size()):
		if packedfloat[i] > packedfloat[at]:
			at = i
	return at

func _to_dictionary():
	var data:Dictionary
	data["vec_count"] = vec_count
	data["keys"] = keys
	data["embedding_input"] = embedding_input._to_dictionary()
	data["embedding_output"] = embedding_output._to_dictionary()
	data["vec2word"] = vec2word._to_dictionary()
	data["encoder"] = encoder._to_dictionary()
	data["decoder"] = decoder._to_dictionary()
	return data

func save(path:String = self.path):
	FileAccess.open(path, FileAccess.WRITE).store_string(
		JSON.stringify(_to_dictionary(), "\t")
	)

func load(path:String = self.path):
	var data:Dictionary = JSON.parse_string(
		FileAccess.open(path, FileAccess.READ).get_as_text()
	)
	
	vec_count = data["vec_count"]
	keys = data["keys"]
	embedding_input.load_from_dict(data["embedding_input"])
#	print("loading")
	embedding_output.load_from_dict(data["embedding_output"])
#	print("loading")
	vec2word.load_from_dict(data["vec2word"])
#	print("loading")
	encoder.load_from_dict(data["encoder"])
#	print("loading")
	decoder.load_from_dict(data["decoder"])
#	print("loading")
