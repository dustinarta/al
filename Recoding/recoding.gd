extends RefCounted
class_name Recoding

var path:String = "res://Recoding/recoding_data.json"

var session:Dictionary
var thiscode:String

func session_set(key:String, data):
	session[key] = data

func session_get(key):
	return session[key]

func echo(str:String):
	thiscode += str
