extends Node

# Signal pour le gel (existant)
signal player_frozen_state_changed(is_frozen)
# Signal pour le bonus de score (existant)
signal score_multiplier_changed(is_active)

@onready var freeze_timer = Timer.new()
@onready var score_timer = Timer.new()

var is_frozen = false

func _ready():
	freeze_timer.one_shot = true
	freeze_timer.timeout.connect(_on_freeze_timer_timeout)
	add_child(freeze_timer)
	
	score_timer.one_shot = true
	score_timer.timeout.connect(_on_score_timer_timeout)
	add_child(score_timer)

# --- Fonctions pour le gel (ne changent pas) ---
func apply_freeze(duration):
	if is_frozen: return
	print("StatusManager: Joueur ENRACINÉ pour ", duration, " secondes.")
	is_frozen = true
	freeze_timer.wait_time = duration
	freeze_timer.start()
	emit_signal("player_frozen_state_changed", true)

func _on_freeze_timer_timeout():
	print("StatusManager: Joueur n'est plus enraciné.")
	is_frozen = false
	emit_signal("player_frozen_state_changed", false)

# --- Fonctions pour le bonus de score (MODIFIÉES) ---
func apply_score_multiplier(duration):
	# MODIFICATION : On a supprimé la sécurité "if not score_timer.is_stopped()".
	# Maintenant, on peut relancer la fonction même si le bonus est déjà actif.
	
	print("StatusManager: Bonus SCORE X2 réinitialisé pour ", duration, " secondes.")
	
	# Si le bonus n'était pas encore actif, on envoie le signal pour activer l'icône, etc.
	if score_timer.is_stopped():
		emit_signal("score_multiplier_changed", true)

	# On met à jour la durée et on (re)démarre le timer.
	score_timer.wait_time = duration
	score_timer.start()

func _on_score_timer_timeout():
	print("StatusManager: Bonus SCORE X2 terminé.")
	emit_signal("score_multiplier_changed", false)