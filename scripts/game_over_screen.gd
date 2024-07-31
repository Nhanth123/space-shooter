extends Control


@onready var high_score = $Panel/HighScore
@onready var score = $Panel/Score

func _on_restart_btn_pressed():
	get_tree().reload_current_scene()

func set_score(value):
	score.text = "Score: " + str(value)

func set_high_score(value):
	high_score.text = "Hi-Score: " + str(value)
