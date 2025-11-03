extends Node2D

const EndScreenScene = preload("res://end_screen.tscn")

var score = 0
var mole_holes = []
var time_left = 10 # Réglé à 10 pour les tests
var target_score = 200

@onready var spawn_timer = $Timers/SpawnTimer
@onready var game_timer = $Timers/GameTimer
@onready var grid = $World/GridContainer
@onready var ui = $UI


func _ready():
	# On récupère directement les taupes, car ce sont les enfants du GridContainer
	mole_holes = grid.get_children()

	# On connecte les signaux de chaque taupe
	for hole in mole_holes:
		hole.mole_hit.connect(_on_mole_hit)
		hole.friend_hit.connect(_on_friend_hit)

	# On connecte les timers
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	game_timer.timeout.connect(_on_game_timer_timeout)
	
	# On met à jour l'affichage initial de l'UI
	ui.update_score(score)
	ui.update_time(time_left)


# Le reste du code ne change pas.

func _on_spawn_timer_timeout():
	if mole_holes.is_empty():
		return
		
	var random_hole = mole_holes.pick_random()
	if not random_hole.is_active:
		if randf() > 0.2:
			random_hole.show_target("mole")
		else:
			random_hole.show_target("friend")


func _on_mole_hit():
	score += 10
	ui.update_score(score)


func _on_friend_hit():
	score -= 50
	if score < 0:
		score = 0
	ui.update_score(score)


func _on_game_timer_timeout():
	time_left -= 1
	ui.update_time(time_left)
	
	if time_left <= 0:
		game_over()


func game_over():
	spawn_timer.stop()
	game_timer.stop()
	
	var end_screen_instance = EndScreenScene.instantiate()
	
	var player_won = score >= target_score
	end_screen_instance.set_message(player_won)
	
	end_screen_instance.restart_game.connect(restart_game)
	
	add_child(end_screen_instance)


func restart_game():
	get_tree().reload_current_scene()
