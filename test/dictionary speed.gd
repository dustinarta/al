tool
extends EditorScript


func _run():
	var long_name = "_n"
	var dictionary = {long_name : 90}
	
	var past_time = Time.get_ticks_usec()
	
	for i in range(10000):
		dictionary[long_name] = 0
		
	print(Time.get_ticks_usec() - past_time)
