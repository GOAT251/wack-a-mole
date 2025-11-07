extends Node2D

# --- MODIFICATION 1 : Pré-charger les deux nouvelles scènes ---
const VictoryScreenScene = preload("res://components/ui/victory_screen.tscn")
const DefeatScreenScene = preload("res://components/ui/defeat_screen.tscn")

# --- Variables de la partie en cours ---
var score: int = 0
var lives: int = 3
var time_left: int = 0

# Référence au script du niveau qui sera chargé
var current_level_data

# --- Références aux nœuds de la scène ---
@onready var spawn_timer = $Timers/SpawnTimer
@onready var game_timer = $Timers/GameTimer
@onready var level_container = $LevelContainer
@onready var ui = $UI

func _ready():
	# 1. Demander au GameProgress quel niveau on doit charger
	var level_path = GameProgress.current_level_to_play
	if level_path.is_empty():
		# Sécurité: si on arrive ici par erreur, on retourne au menu
		get_tree().change_scene_to_file("res://components/world_map/world_map.tscn") # Assurez-vous que ce chemin est correct
		return

	# 2. Charger et instancier la "cartouche" de niveau
	var level_scene = load(level_path)
	var level_instance = level_scene.instantiate()
	level_container.add_child(level_instance)
	
	# On garde une référence au script du niveau pour lire ses règles
	current_level_data = level_instance

	# 3. Initialiser le jeu avec les règles contenues dans la cartouche
	score = 0
	lives = 3
	time_left = current_level_data.time_left
	
	spawn_timer.wait_time = current_level_data.spawn_speed
	spawn_timer.start()
	game_timer.start()
	game_timer.timeout.connect(_on_game_timer_timeout)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	# 4. Connecter les signaux de toutes les taupes du niveau chargé
	var grid = level_instance.get_node("GridContainer")
	for child in grid.get_children():
		if child.has_signal("mole_hit"):
			child.mole_hit.connect(_on_mole_hit)
			child.friend_hit.connect(_on_friend_hit)

	# 5. Mettre à jour l'UI avec les valeurs de départ
	ui.update_score(score)
	ui.update_time(time_left)
	ui.update_lives(lives)

func _on_spawn_timer_timeout():
	var grid = current_level_data.get_node("GridContainer")
	var mole_holes = grid.get_children()
	var interactive_holes = []
	for hole in mole_holes:
		if hole.has_signal("mole_hit"):
			interactive_holes.append(hole)
	
	if interactive_holes.is_empty():
		return
	
	var random_hole = interactive_holes.pick_random()
	if not random_hole.is_active:
		if randf() > current_level_data.friend_chance:
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

func game_over():
	spawn_timer.stop()
	game_timer.stop()

	var player_won = score >= current_level_data.target_score and lives > 0
	
	var end_screen 
	
	if player_won:
		GameProgress.level_completed(GameProgress.current_level_to_play)
		end_screen = VictoryScreenScene.instantiate()
	else:
		end_screen = DefeatScreenScene.instantiate()
	
	add_child(end_screen)
	
	# La ligne "end_screen.set_message(player_won)" a été supprimée.
	
	end_screen.restart_level.connect(_on_restart_level_requested)
	end_screen.return_to_map.connect(_on_return_to_map_requested)


# Cette fonction gère le signal "return_to_map".
func _on_return_to_map_requested():
	get_tree().change_scene_to_file("res://components/world_map/world_map.tscn") # Assurez-vous que ce chemin est correct

# Cette fonction gère le signal "restart_level".
func _on_restart_level_requested():
	get_tree().reload_current_scene()
