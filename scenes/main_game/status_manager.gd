extends Node

# Signal qui préviendra le jeu quand l'état de gel du joueur change.
signal player_frozen_state_changed(is_frozen)

# Le timer est interne et géré uniquement par ce manager.
@onready var freeze_timer = Timer.new()

var is_frozen = false

func _ready():
	# On configure le timer une bonne fois pour toutes.
	freeze_timer.one_shot = true
	freeze_timer.timeout.connect(_on_freeze_timer_timeout)
	add_child(freeze_timer)

# C'est la fonction que les autres managers appelleront.
# On peut lui passer une durée pour être flexible plus tard.
func apply_freeze(duration):
	# On ne peut pas être gelé si on l'est déjà.
	if is_frozen:
		return
	
	print("StatusManager: Joueur ENRACINÉ pour ", duration, " secondes.")
	is_frozen = true
	freeze_timer.wait_time = duration
	freeze_timer.start()
	emit_signal("player_frozen_state_changed", true)

func _on_freeze_timer_timeout():
	print("StatusManager: Joueur n'est plus enraciné.")
	is_frozen = false
	emit_signal("player_frozen_state_changed", false)