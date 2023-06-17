@tool
extends EditorScript


func _run():
	var result
	var input:Array[PackedFloat64Array] = [
		[0.1, -0.2, 0.3, 0.7, -1],
		[0.0, 0.4, -0.1, -0.5, 0.2]
	]
	var output:Array[PackedFloat64Array] = [
		[1, 0, 0, 0, 0],
		[0, 0, 1, 0, 0]
	]
	var nn = NN3.new()
	nn.init([5, 5], [NN3.ACTIVATION.SOFTMAX], true)
	result = nn.forward(input[0])
	print(nn.forward_result[-1])
	result = nn.forward(input[1])
	print(nn.forward_result[-1])
	nn.backward_many(input, output, 100)
	result = nn.forward(input[0])
	print(nn.forward_result[-1])
	result = nn.forward(input[1])
	print(nn.forward_result[-1])
#	print("ahaha")
