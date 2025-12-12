# Fichier : animated_icon.gd
extends Control

signal pressed

@onready var hitbox = $Hitbox
@onready var visuals = $Visuals

# NOUVEAU : Une petite "mémoire" pour savoir si on est déjà en train de survoler.
var is_hovering = false

func _ready():
	hitbox.mouse_entered.connect(_on_mouse_entered)
	hitbox.mouse_exited.connect(_on_mouse_exited)
	hitbox.pressed.connect(_on_pressed)
	
	# TRÈS IMPORTANT : Dans l'éditeur, assurez-vous que votre animation "hover"
	# a sa boucle DÉSACTIVÉE (grise).
	visuals.play("idle")

func _on_mouse_entered():
	# Si la souris entre ET qu'on n'était pas déjà en train de survoler...
	if not is_hovering:
		# ...on met à jour notre mémoire...
		is_hovering = true
		# ...et on joue l'animation "hover" une seule fois.
		visuals.play("hover")

func _on_mouse_exited():
	# Si la souris sort ET qu'on était bien en train de survoler...
	if is_hovering:
		# ...on met à jour notre mémoire...
		is_hovering = false
		# ...et on retourne à l'animation de repos.
		visuals.play("idle")

func _on_pressed():
	# L'animation "pressed" ne doit pas boucler non plus.
	visuals.play("pressed")
	emit_signal("pressed")