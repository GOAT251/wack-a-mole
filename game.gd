extends Node2D

const EndScreenScene = preload("res://end_screen.tscn")

# NOTE: J'ai remis la durée du niveau 1 à 60s pour les tests, 
# vous pouvez la remettre à 10 si vous le souhaitez.
const LEVEL_RULES = {
	0: {"time_left": 60, "target_score": 200, "spawn_speed": 1.0, "friend_chance": 0.2},
	1: {"time_left": 45, "target_score": 350, "spawn_speed": 0.8, "friend_chance": 0.3}
}

var score = 0
var mole_holes = []
var time_left = 0
var lives = 3

@onready var spawn_timer = $Timers/SpawnTimer
@onready var game_timer = $Timers/GameTimer
@onready var level_container = $LevelContainer
@onready var ui = $UI

func _ready():
	var level_index = GameManager.current_level_index
	var level_scene = GameManager.LEVELS[level_index]
	var level_instance = level_scene.instantiate()
	level_container.add_child(level_instance)

	var grid = level_instance.get_node("GridContainer")
	mole_holes.clear()
	for hole in grid.get_children():
		mole_holes.append(hole)
		hole.mole_hit.connect(_on_mole_hit)
		hole.friend_hit.connect(_on_friend_hit)

	var rules = LEVEL_RULES[level_index]
	score = 0
	time_left = rules["time_left"]
	lives = 3

	spawn_timer.wait_time = rules["spawn_speed"]
	spawn_timer.start()
	game_timer.start()

	game_timer.timeout.connect(_on_game_timer_timeout)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	ui.update_score(score)
	ui.update_time(time_left)
	ui.update_lives(lives)

func _on_spawn_timer_timeout():
	if mole_holes.is_empty():
		return
	var random_hole = mole_holes.pick_random()
	if not random_hole.is_active:
		var rules = LEVEL_RULES[GameManager.current_level_index]
		if randf() > rules["friend_chance"]:
			random_hole.show_target("mole")
		else:
			random_hole.show_target("friend")

func _on_mole_hit():
	score += 10
	ui.update_score(score)

func _on_friend_hit():
	lives -= 1
	ui.update_lives(lives)
	if lives <= 0:
		game_over()

func _on_game_timer_timeout():
	time_left -= 1
	ui.update_time(time_left)
	if time_left <= 0:
		game_over()

# --- MODIFICATIONS CI-DESSOUS ---

func game_over():
	spawn_timer.stop()
	game_timer.stop()
	
	var rules = LEVEL_RULES[GameManager.current_level_index]
	var player_won = score >= rules["target_score"] and lives > 0
	var has_next_level = GameManager.current_level_index < GameManager.LEVELS.size() - 1
	
	var end_screen = EndScreenScene.instantiate()
	end_screen.set_message(player_won, has_next_level)
	
	# CHANGEMENT 1: Les signaux de l'écran de fin sont maintenant connectés
	# à des fonctions INTERNES à cette scène (game.gd).
	end_screen.next_level.connect(_on_next_level_requested)
	end_screen.restart_game.connect(_on_restart_requested)
	
	add_child(end_screen)


# CHANGEMENT 2: Création de deux nouvelles fonctions pour gérer les signaux.
# C'est maintenant la scène de jeu qui appelle le GameManager, pas l'écran de fin.

# Cette fonction est appelée par le signal 'next_level' de l'écran de fin.
func _on_next_level_requested():
	GameManager.go_to_next_level()

# Cette fonction est appelée par le signal 'restart_game' de l'écran de fin.
func _on_restart_requested():
	print("--- DANS game.gd: Signal 'restart_game' REÇU ! On va appeler le GameManager.")
	GameManager.restart_game()

# L'ancienne fonction restart_game() a été renommée en _on_restart_requested()
# pour plus de clarté, mais son contenu reste le même.