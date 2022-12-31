tool
extends EditorScript


func _run():
	var data = array_generator()
	var prev = Time.get_ticks_usec()
	
	data.find([64])
	
	print(Time.get_ticks_usec() - prev)

func array_generator()->Array:
	var data = []
	for idx in range(1024):
		data.push_back([idx])
	data.shuffle()
	data.shuffle()
	return data

