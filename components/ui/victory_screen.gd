extends CanvasLayer

# Déclaration des signaux que cet écran envoie.
signal restart_level
signal return_to_map

# Références aux boutons. Le chemin est correct pour votre structure.
# $TextureRect -> enfant du CanvasLayer
# /RestartButton -> enfant du TextureRect
@onready var restart_button = $TextureRect/RestartButton
@onready var menu_button = $TextureRect/MenuButton

func _ready():
	# Connexion des signaux des boutons.
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

# Fonction pour le bouton "Recommencer".
func _on_restart_pressed():
	emit_signal("restart_level")
	queue_free()

# Fonction pour le bouton "Menu".
func _on_menu_pressed():
	emit_signal("return_to_map")
	queue_free()
