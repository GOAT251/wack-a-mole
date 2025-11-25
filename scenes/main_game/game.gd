extends Node2D

const VictoryScreenScene = preload("res://components/ui/victory_screen.tscn")
const DefeatScreenScene = preload("res://components/ui/defeat_screen.tscn")

var current_level_data

# Variables de score
var score = 0
var score_multiplier = 1

# Références
@onready var level_container = $LevelContainer
@onready var ui = $UI
@onready var lives_manager = $LivesManager
@onready var time_manager = $TimeManager
@onready var spawn_manager = $SpawnManager
@onready var status_manager = $StatusManager
@onready var bomb_manager = $BombManager
@onready var freeze_shield = $FreezeShield
@onready var fx_layer = $FXLayer 

func _ready():

	for child in level_container.get_children():
		child.call_deferred("queue_free")

	var level_path = GameProgress.current_level_to_play
	if level_path.is_empty():
		get_tree().change_scene_to_file("res://components/world_map/world_map.tscn")
		return

	var level_scene = load(level_path)
	var level_instance = level_scene.instantiate()
	level_container.add_child(level_instance)
	current_level_data = level_instance

	score = 0
	score_multiplier = 1
	ui.update_score(score)

	lives_manager.reset()
	time_manager.start_countdown(current_level_data.time_left)
	spawn_manager.level_data = current_level_data
	spawn_manager.start_spawning()

	var grid = level_instance.get_node("GridContainer")
	for child in grid.get_children():
		if child.has_method("set"):
			child.set("status_manager", status_manager)

		if child.has_signal("mole_hit"):
			child.mole_hit.connect(_on_mole_hit)
		if child.has_signal("friend_hit"):
			child.friend_hit.connect(_on_friend_hit)
		if child.has_signal("bomb_hit"):
			child.bomb_hit.connect(_on_bomb_hit)
		if child.has_signal("gold_mole_hit"):
			child.gold_mole_hit.connect(_on_gold_mole_hit)

	lives_manager.lives_updated.connect(ui.update_lives)
	lives_manager.no_more_lives.connect(game_over)
	time_manager.time_updated.connect(ui.update_time)
	time_manager.time_is_up.connect(game_over)
	status_manager.player_frozen_state_changed.connect(_on_player_frozen_state_changed)
	
	status_manager.score_multiplier_changed.connect(_on_score_multiplier_changed)


# --- NOUVEAU : Gestion des clics pour l'animation du marteau ---
func _input(event):
	# On vérifie si c'est un clic gauche de souris pressé
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		spawn_hammer_effect()

# --- NOUVEAU : Fonction pour faire apparaître l'effet ---
func spawn_hammer_effect():
	# 1. On vérifie si le singleton PlayerData existe et si un marteau est équipé
	if PlayerData.equipped_hammer and PlayerData.equipped_hammer.animation_scene:
		
		# 2. On instancie la scène d'animation liée au marteau
		var effect_instance = PlayerData.equipped_hammer.animation_scene.instantiate()
		
		# 3. On la place à la position globale de la souris
		effect_instance.global_position = get_global_mouse_position()
		
		# 4. CHANGEMENT ICI : On l'ajoute sur le FXLayer (Calque 10) au lieu de la racine
		# Cela force l'animation à être dessinée PAR DESSUS les taupes.
		fx_layer.add_child(effect_instance)


# --- Logique de jeu ---

func add_points(points):
	score += points * score_multiplier
	ui.update_score(score)

func _on_mole_hit():
	add_points(10)

func _on_friend_hit():
	lives_manager.remove_lives(1)

func _on_bomb_hit():
	pass

func _on_gold_mole_hit():
	add_points(30)
	status_manager.apply_score_multiplier(6.0)

func _on_player_frozen_state_changed(is_frozen):
	freeze_shield.visible = is_frozen
	ui.display_root_effect(is_frozen)

func _on_score_multiplier_changed(is_active):
	if is_active:
		score_multiplier = 2
	else:
		score_multiplier = 1
	
	ui.display_x2_effect(is_active)

func game_over():
	spawn_manager.stop_spawning()
	time_manager.stop_countdown()

	var player_won = score >= current_level_data.target_score and lives_manager.lives > 0
	
	var end_screen 
	if player_won:
		GameProgress.level_completed(GameProgress.current_level_to_play)
		end_screen = VictoryScreenScene.instantiate()
	else:
		end_screen = DefeatScreenScene.instantiate()
	
	add_child(end_screen)
	end_screen.restart_level.connect(_on_restart_level_requested)
	end_screen.return_to_map.connect(_on_return_to_map_requested)

func _on_return_to_map_requested():
	get_tree().change_scene_to_file("res://components/world_map/world_map.tscn")

func _on_restart_level_requested():
	get_tree().reload_current_scene()
