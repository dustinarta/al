@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var var1:Array[Array] = [[1, 2], [3, 4], [5, 6], [7, 8], [9, 10], [11, 12]]
	var var2:Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
	var putaran:int = 10000
	var start:int = Time.get_ticks_msec()
	var result:int
	for i in range(putaran):
		for j in range(var1.size()):
			var k_len = var1[j].size()
			for k in range(k_len):
				result += var1[j][k]
	print(result)
	print(float(Time.get_ticks_msec()-start)/1000)
	
	result = 0
	start = Time.get_ticks_msec()
	for i in range(putaran):
		for j in range(6):
			for k in range(2):
				result += var2[j*2 + k]
	print(result)
	print(float(Time.get_ticks_msec()-start)/1000)
