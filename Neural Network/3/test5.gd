@tool
extends EditorScript


func _run():
	var result
	var input = [0.1, -0.2, 0.3, 0.7, -1]
	var nn = NN3.new()
	nn.init([5, 5], [NN3.ACTIVATION.SOFTMAX], true)
	result = nn.forward(input)
	print(nn.forward_result)
	print(result)
	nn.backward(input, [1, 0, 0, 0, 0], 100)
	result = nn.forward(input)
	print(result)
#	print("ahaha")
