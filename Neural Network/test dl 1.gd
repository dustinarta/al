tool
extends EditorScript


func _run():
	var nn = NN.new(3)
	nn.add_layers([4, 4, 2], [NN.ACTIVATION.TANH, NN.ACTIVATION.TANH, NN.ACTIVATION.SIGMOID])
#	nn.add_layer(4, NN.ACTIVATION.TANH)
#	nn.add_layer(4, NN.ACTIVATION.TANH)
#	nn.add_layer(2, NN.ACTIVATION.SIGMOID)
#	print(nn)
	
	var gen = DL.Genetic.new(nn, 3)
	print(gen.people)
#	print(gen.nn_info)
	
#	print("not return")
	var score = [2, 5.0, 4]
#	return
	gen.set_score(score)
	gen.generate()
#	print(gen._find_highest(score, 3))
	print(gen.people)
