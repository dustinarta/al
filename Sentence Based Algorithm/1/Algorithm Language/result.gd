extends PanelContainer

@onready var label_type = $VBoxContainer/Label
@onready var label_speech = $VBoxContainer/Label2


func _ready():
	pass
	
func set_up(phrase:English.Phrase):
	label_type.text = En.PHRASE_TYPE.keys()[phrase.type]
	label_speech.text = str(phrase.speech)
