tool
extends EditorScript


func _run():
	var nn = NN.new(2)
	var gen = DL.Genetic.new(nn, 50)
	print(gen.people)
