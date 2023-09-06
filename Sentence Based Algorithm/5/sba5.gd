extends RefCounted
class_name SBA5

var clauses:Array

func _init():
	pass

func init():
	pass

func save(path:String = "res://Sentence Based Algorithm/5/data.json"):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"clauses": clauses
	}, "\t", false))
	file.close()

func conclude(statement:AP2_2.Sentence, condition:AP2_2.Sentence):
	var statement_request = statement.find_clause("independent")
	var statement_
	

func clause_equal(clause1:AP2_2.Clause, clause2:AP2_2.Clause)->bool:
	var clause_data1 = clause1.data
	var clause_data2 = clause2.data
	if clause_data1.size() != clause_data2.size():
		return false
	for c in range(clause_data1.size()):
		var clause_part1 = clause_data1[c]
		var clause_part2 = clause_data2[c]
		if clause_part1["@"] == clause_part2["@"]:
			if clause_part1["word"] != clause_part2["word"]:
				return false
	return true
