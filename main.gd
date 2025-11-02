extends Node2D

var score = 0
var mole_holes = []

# NOUVELLE VARIABLE pour le temps
var time_left = 60

@onready var spawn_timer = $SpawnTimer
@onready var score_label = $CanvasLayer/Score 
@onready var grid = $GridContainer

# NOUVEAU RACCOURCI vers notre label de temps
@onready var time_label = $CanvasLayer/TimeLabel
# NOUVEAU RACCOURCI vers notre timer de jeu
@onready var game_timer = $GameTimer


func _ready():
	mole_holes = grid.get_children()

	for hole in mole_holes:
		hole.mole_hit.connect(_on_mole_hit)

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	# NOUVELLE CONNEXION pour le timer du jeu
	game_timer.timeout.connect(_on_game_timer_timeout)


func _on_spawn_timer_timeout():
	var random_hole = mole_holes.pick_random()

	if not random_hole.is_active:
		random_hole.show_mole()


func _on_mole_hit():
	score += 10
	score_label.text = "Score: " + str(score)


# NOUVELLE FONCTION appelée toutes les secondes par le GameTimer
func _on_game_timer_timeout():
	# On diminue le temps restant de 1
	time_left -= 1
	# On met à jour le texte du label
	time_label.text = "Temps: " + str(time_left)
	
	# Si le temps est écoulé...
	if time_left <= 0:
		# On appelle une fonction pour terminer le jeu
		game_over()


# NOUVELLE FONCTION pour gérer la fin du jeu
func game_over():
	# On arrête le timer qui fait apparaître les taupes
	spawn_timer.stop()
	# On arrête le timer du jeu lui-même
	game_timer.stop()
	# On affiche un message dans la console pour l'instant
	print("GAME OVER! Score final: ", score)
	# Plus tard, on pourra afficher un écran de fin ici.
