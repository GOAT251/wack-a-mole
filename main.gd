extends Node2D

var score = 0
var mole_holes = []
var time_left = 60

@onready var spawn_timer = $Timers/SpawnTimer
@onready var game_timer = $Timers/GameTimer
@onready var grid = $World/GridContainer
@onready var ui = $UI


func _ready():
	mole_holes = grid.get_children()

	for hole in mole_holes:
		# On doit maintenant connecter DEUX signaux pour chaque trou !
		hole.mole_hit.connect(_on_mole_hit)
		hole.friend_hit.connect(_on_friend_hit) # NOUVELLE CONNEXION

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	game_timer.timeout.connect(_on_game_timer_timeout)
	
	# On met à jour l'UI une première fois au début du jeu
	ui.update_score(score)
	ui.update_time(time_left)


func _on_spawn_timer_timeout():
	var random_hole = mole_holes.pick_random()

	if not random_hole.is_active:
		# NOUVELLE LOGIQUE : on choisit au hasard ce qu'on va montrer.
		# randf() donne un nombre aléatoire entre 0.0 et 1.0.
		if randf() > 0.2: # 80% de chance d'avoir une taupe
			# On appelle la nouvelle fonction en lui précisant le type
			random_hole.show_target("mole")
		else: # 20% de chance d'avoir un ami
			random_hole.show_target("friend")


func _on_mole_hit():
	score += 10
	ui.update_score(score)


# NOUVELLE FONCTION pour gérer la pénalité quand on frappe un ami.
func _on_friend_hit():
	score -= 50 # Grosse pénalité !
	# On s'assure que le score ne devient pas négatif
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
	print("GAME OVER! Score final: ", score)
