extends Node
class_name _pharser

"""
UNUSED
"""

var SPEECH_TYPE = En.SPEECH_TYPE
var speech_list:Array = []
var Noun = En.Noun
var Pronoun = En.Pronoun
var Verb = En.Verb
var Adjective = En.Adjective
var Adverb = En.Adverb
var Conjunction = En.Conjunction
var Preposition = En.Preposition
var Interjection = En.Interjection

func _init(speech_list):
	self.speech_list = speech_list

func _pharser(sentence)->Array:
	var result:Array = []
	var aux_pos = _find_auxilary(sentence)
	print("Auxilary at " + str(aux_pos))
	return result

func _find_auxilary(sentence:Array)->Array:
	var result:Array = []
	var length = sentence.size()
	for i in range(length):
		var s = sentence[i]
		if s is En.SC:
			continue
		elif s is En.SP:
			var sp = s as En.SP
			var pos = sp.type.find(float(SPEECH_TYPE.Verb))
			if pos != -1:
				var et = sp.each_type[pos]
				if et.has(float(Verb.Auxiliary)):
					result.append(i)
		else:
			pass
	
	return result
