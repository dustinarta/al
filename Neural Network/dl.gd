extends Reference

class_name DL

class Backpropagation:
	static func train(nn:NN, inputs:Array, target:Array, count:int = 1000, rate:float = 0.5):
		var result
		var errors
		var error
		var layers = nn.layers
		var last_errors
		var layer
		var w
		
		for c in range(count):
			result = nn.forward(inputs)
			errors = nn.error_point2(result, target)
			last_errors = errors[-1]
			layer = layers[-1]
	#		each neuron in the last layer
			for j in range(layer.size()):
				error = errors[-1][j]
				var curent_result = result[-1][j]
				w = layer[j]["w"]
	#			each weight
	#			print(w)
				for i in range(w.size()):
					var activation = result[-2][i]
					w[i] -= error * nn.derivative(curent_result, layer[j]["a"]) * activation * rate
				layer[j]["b"] -= error * rate
	#			print(w)
			
	#		each hidden layer
			for k in range(layers.size()-2, -1, -1):
				layer = layers[k]
				last_errors = errors[k]
				for j in range(layer.size()):
					error = errors[k][j]
					var curent_result = result[k+1][j]
					w = layer[j]["w"]
	#				each weight
	#				print(w)
					for i in range(w.size()):
						var activation = result[k][i]
						w[i] -= error * nn.derivative(curent_result, layer[j]["a"]) * activation * rate
					layer[j]["b"] -= error * rate
	#				print(w)
	
	static func train2(nn:NN, inputs:Array, target:Array, count:int = 1000, rate:float = 0.5):
		var result
		var errors
		var error
		var layers = nn.layers
		var last_errors
		var layer
		var w
		
		if inputs.size() != target.size():
			printerr("Different size of inputs: " + str(inputs.size()) + " with target: " + str(target.size()))
			return null
		
		var datalen = inputs.size()
		
		for c in range(count):
			var index = c % datalen
			result = nn.forward( inputs[index] )
			errors = nn.error_point2(result, target[index])
			last_errors = errors[-1]
			layer = layers[-1]
	#		each neuron in the last layer
			for j in range(layer.size()):
				error = errors[-1][j]
				var curent_result = result[-1][j]
				w = layer[j]["w"]
				var var1 = error * nn.derivative(curent_result, layer[j]["a"])
	#			each weight
	#			print(w)
				for i in range(w.size()):
					var activation = result[-2][i]
					w[i] -= var1 * activation * rate
				layer[j]["b"] -= var1 * rate
	#			print(w)
			
	#		each hidden layer
			for k in range(layers.size()-2, -1, -1):
				layer = layers[k]
				last_errors = errors[k]
				for j in range(layer.size()):
					error = errors[k][j]
					var curent_result = result[k+1][j]
					w = layer[j]["w"]
					var var1 = error * nn.derivative(curent_result, layer[j]["a"])
	#				each weight
	#				print(w)
					for i in range(w.size()):
						var activation = result[k][i]
						w[i] -= var1 * activation * rate
					layer[j]["b"] -= var1 * rate
	#				print(w)

class Genetic:
	
	var people:Array setget set_people, get_people
	var population:int setget set_population, get_population
	var generation:int setget set_generation, get_generation
	var nn_info:Dictionary
	var _score:Array
	
	func set_score(scores:Array) -> void:
		if (scores.size() == _score.size()):
			_score = scores.duplicate(true)
		else:
			printerr("Must be the same size!")
	
	func _init(nn:NN, _population:int = 10):
		population = _population
		people.resize(_population)
		_score.resize(_population)
		
		nn_info["i"] = nn.input
		nn_info["c"] = nn.layers.size()
		nn_info["l"] = []
		nn_info["l"].resize(nn_info["c"])
		var l = nn_info["l"]
		var layers = nn.layers
		
		for i in range(nn_info["c"]):
			l[i] = {"n" : layers[i].size(), "w" : layers[i][0]["w"].size()}
		
		for i in range(population):
			var new_nn = NN.new(nn.input, nn.layers, str(i+1))
			new_nn.init_weight() 
			people[i] = new_nn
	
	func generate(selection: = 2, mutation: = 0.1):
		_crossover(selection)
		_mutation(mutation)
		
	func _crossover(selection: = 2):
		var best = _find_highest(_score, selection)
		var bestnn:Array
		var best_packednn:Array
		bestnn.resize(selection)
		best_packednn.resize(selection)
		
		for i in range(selection):
			bestnn[i] = people[best[i]]
		
#		each best nn
		for k in range(selection):
			var new_nn = []
			new_nn.resize( nn_info["c"] )
			var now_nn:NN = bestnn[k]
#			each layer
			for j in range(nn_info["c"]):
				var layer = now_nn.layers[j]
				var weights:Array
#				each neouron
				for i in range(nn_info["l"][j]["n"]):
					weights.append(layer[i]["w"])
				new_nn[j] = weights
			best_packednn[k] = new_nn
		
#		each neural network
		for k in range(selection, population):
			var p = people[k]
#			each layer
			for j in range(nn_info["c"]):
				var info_layer = nn_info["l"][j]
				var now_best_layer = []
				for i in range(selection):
					now_best_layer.append(best_packednn[i][j])
#				each neuron
				for q in range(info_layer["n"]):
					var w = p.layers[j][q]["w"]
					var now_best_neuron = []
					for i in range(selection):
						now_best_neuron.append(now_best_layer[i][q])
#					each weight
					for i in range(info_layer["w"]):
						var choice = randi() % (selection)
						w[i] = now_best_neuron[ choice ][i]
	
	func _mutation(rate:= 0.1):
		pass
	
	func _find_highest(score, count) -> Array:
		var picked:Array
		var score_len = score.size()
		picked.resize(count)
		
		for j in range(count):
			var highest = 0
			for i in range(score_len):
				if(picked.has(i)):
					continue
				elif(score[i] > score[highest]):
					highest = i
			picked[j] = highest
		
		return picked
	
		
	func set_population(value):
		print("Not alowed to set")
		
	func get_population() -> int:
		return population
		
	func set_people(value):
		print("Not alowed to set")
		
	func get_people() -> Array:
		return people
	
	func set_generation(value):
		print("Not alowed to set")
		
	func get_generation() -> int:
		return generation
