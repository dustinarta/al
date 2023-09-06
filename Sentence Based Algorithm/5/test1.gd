@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var sba = SBA5.new()
	var ap = AP2_2.new()
	ap.init_ap()
	var res1 = ap.read_s2("if the dog is climbing, it fell")
	print(res1)
	sba.conclude(res1, null)
#	print(clause2)
#	print(sba.clause_equal(clause1, clause2))
#	sba.clauses.append(
#		ap.read_s("i have a dog").clauses[0].to_dict()
#	)
#	sba.save()
