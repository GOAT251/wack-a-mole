extends Area2D

# Signal qui sera émis quand la taupe est touchée.
signal mole_hit

# Variable pour savoir si la taupe est active et peut être touchée.
var is_active = false

# Raccourcis vers les nœuds enfants pour un accès facile.
@onready var mole_sprite = $MoleSprite
@onready var visibility_timer = $VisibilityTime


# Fonction d'initialisation, appelée une seule fois au début.
func _ready():
	# On s'assure que le sprite est invisible au démarrage.
	mole_sprite.visible = false
	# On connecte le signal "timeout" du timer à notre fonction pour se cacher.
	visibility_timer.timeout.connect(hide_mole)
	# On connecte le signal d'input (clic/toucher) à notre fonction de gestion.
	input_event.connect(_on_input_event)


# Fonction pour faire apparaître la taupe.
# Elle sera appelée par la scène principale (main.gd).
func show_mole():
	is_active = true
	mole_sprite.visible = true
	# On lance le compte à rebours avant de disparaître.
	visibility_timer.start(1.0)


# Fonction pour cacher la taupe.
func hide_mole():
	is_active = false
	mole_sprite.visible = false
	# On arrête le timer (au cas où on est caché par un clic et non par le temps).
	visibility_timer.stop()


# Fonction appelée automatiquement quand un input est détecté sur notre Area2D.
# On ajoute les underscores pour dire à Godot qu'on n'utilise pas ces variables.
func _on_input_event(_viewport, event, _shape_idx):
	# On vérifie si l'input est un clic de souris pressé ET si la taupe est active.
	if event is InputEventMouseButton and event.pressed and is_active:
		# Ligne de débogage pour être sûr que cette partie du code s'exécute.
		print("La taupe a été frappée ! Émission du signal 'mole_hit'.")
		
		# On émet le signal pour que la scène principale soit prévenue.
		emit_signal("mole_hit")
		
		# On se cache immédiatement.
		hide_mole()