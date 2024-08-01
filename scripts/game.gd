extends Node2D

@export var enemy_scenes : Array[PackedScene] = []

@onready var player_spawn_position = $PlayerSpawnPosition
@onready var laser_container = $LaserContainer
@onready var timer  = $EnemySpawnerTimer
@onready var enemy_container = $EnemyContainer
@onready var hud = $UILayer/HUD
@onready var game_over_screen = $UILayer/GameOverScreen
@onready var parallax_background = $ParallaxBackground

@onready var laser_sound = $SFX/LaserSound
@onready var hit_sound = $SFX/HitSound
@onready var explode_sound = $SFX/ExplodeSound

var player =  null
var score := 0:
	set(value):
		score = value
		hud.label_score = score

var high_score

var scroll_speed = 100


func _ready():
	var save_file = FileAccess.open("user://save.data", FileAccess.READ)
	if save_file != null:
		high_score = save_file.get_32()
	else:
		high_score = 0
		save_game()
	
	score = 0
	player = get_tree().get_first_node_in_group("player_group")
	assert(player!=null)
	player.global_position = player_spawn_position.global_position
	player.laser_shot.connect(_on_player_laser_shot)
	player.killed.connect(_on_player_killed)

func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	
	if timer.wait_time > 0.5:
		timer.wait_time -= delta * 0.005
	elif timer.wait_time < 0.5:
		timer.wait_time = 0.5
	
	parallax_background.scroll_offset.y += delta * scroll_speed
	if parallax_background.scroll_offset.y >= 960:
		parallax_background.scroll_offset.y = 0

func _on_player_laser_shot(laser_scene, location):
	var laser = laser_scene.instantiate()
	laser.global_position = location
	laser_container.add_child(laser)
	
	laser_sound.play()

func _on_enemy_spawner_timer_timeout():
	var e = enemy_scenes.pick_random().instantiate()
	e.global_position = Vector2(randf_range(50, 540), -50)
	e.killed.connect(_on_enemy_killed)
	e.hit.connect(_on_enemy_hit)
	enemy_container.add_child(e)
	
func _on_enemy_killed(points):
	hit_sound.play()
	score += points
	if high_score < score:
		high_score = score

func _on_player_killed():
	explode_sound.play()
	game_over_screen.set_score(score)
	game_over_screen.set_high_score(high_score)
	save_game()
	await get_tree().create_timer(0.75).timeout
	game_over_screen.visible = true

func save_game():
	var save_file = FileAccess.open("user://save.data", FileAccess.WRITE)
	save_file.store_32(high_score)
	
func _on_enemy_hit():
	hit_sound.play()
