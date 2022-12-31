extends HBoxContainer

onready var popup = $btnAddSpeech.get_popup()
onready var label = $labelSpeech

signal clean

var this_speech_int:int
export(Array, String) var this_speech_string

enum SPEECH_TYPE {
	Noun = 1,
	Pronoun = 2,
	Verb = 4,
	Adjective = 8,
	Adverb = 16,
	Conjunction = 32,
	Preposition = 64,
	Article = 128,
	Interjection = 256
}

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("clean", self, "_clean")
	for key in SPEECH_TYPE.keys():
		popup.add_item(key)
	
func _clean():
	label.text = ""
	this_speech_int = 0
	this_speech_string = ""

func _on_btnAddSpeech_item_selected(index):
#	print(SPEECH_TYPE.keys()[index])
	var speech_value = SPEECH_TYPE.values()[index]
	if not this_speech_int & speech_value:
		this_speech_int += speech_value
		this_speech_string.push_back(SPEECH_TYPE.keys()[index])
	label.text = str(this_speech_string)
