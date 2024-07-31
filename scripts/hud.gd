extends Control

@onready var label_score = $LabelScore:
	set(value):
		label_score.text = "SCORE: " + str(value)
