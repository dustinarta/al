@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	DAT.init()
#	DAT.init_words(512)
#	DAT.add_words(
#		[
#			"<SOS>",
#			"<PAD>",
#			"<EOS>"
#		]
#	)
	DAT.add_words_with_sentence("i have a cat, horse, and dog")
	DAT.save()
	DAT.encode([0])
