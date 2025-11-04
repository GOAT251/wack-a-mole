extends Node2D

const EndScreenScene = preload("res://end_screen.tscn")

var score = 0
var mole_holes = []

# --- Variables de Niveau ---
var time_left = 60
var target_score = 200
# NOUVELLE VARIABLE pour les vies
var lives = 3

@onready var spawn_timer = $Timers/SpawnTimer
@onready var game_timer = $Timers/GameTimer
@onready var grid = $World/GridContainer
@onready var ui = $UI


func _ready():
	# ... (le code de connexion des signaux ne change pas)
	mole_holes = grid.get_children()
	for hole in mole_holes:
		hole.mole_hit.connect(_on_mole_hit)
		hole.friend_hit.connect(_on_friend_hit)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	game_timer.timeout.connect(_on_game_timer_timeout)
	
	# On met à jour l'affichage initial de l'UI, y compris les vies
	ui.update_score(score)
	ui.update_time(time_left)
	ui.update_lives(lives)


func _on_spawn_timer_timeout():
	var random_hole = mole_holes.pick_random()
	if not random_hole.is_active:
		if randf() > 0.2:
			random_hole.show_target("mole")
		else:
			random_hole.show_target("friend")


func _on_mole_hit():
	score += 60
	ui.update_score(score)


# LA LOGIQUE DE PÉNALITÉ CHANGE ICI
func _on_friend_hit():
	# On ne perd plus de points, on perd une vie
	lives -= 1
	# On met à jour l'affichage des vies
	ui.update_lives(lives)
	
	# Si on n'a plus de vie, c'est game over immédiatement
	if lives <= 0:
		game_over()


func _on_game_timer_timeout():
	time_left -= 1
	ui.update_time(time_left)
	
	# La défaite par le temps est toujours une condition de fin
	if time_left <= 0:
		game_over()


func game_over():
	spawn_timer.stop()
	game_timer.stop()
	
	var end_screen_instance = EndScreenScene.instantiate()
	
	# La condition de victoire reste la même : atteindre le score.
	# Mais on peut aussi perdre en n'ayant plus de vies.
	var player_won = (score >= target_score) and (lives > 0)
	
	end_screen_instance.set_message(player_won)
	end_screen_instance.restart_game.connect(restart_game)
	add_child(end_screen_instance)


func restart_game():
	get_tree().reload_current_scene()
