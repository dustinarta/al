tool
extends EditorScript


func _run():
	var array1 = [[2, 3]]
	print(array1.has([2, 3])) #print true
	
	var array2 = ["Sus"]
	print(array2.has("Sus")) #print true 
	
	var array3 = [ {"key" : 0} ]
	print(array3.has( {"key":0} )) #print false
	
	var array4 = [Label.new()]
	var label1 = Label.new()
	print(array4.has(label1)) #print false
