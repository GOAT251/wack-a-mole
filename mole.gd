extends Area2D

signal mole_hit
signal friend_hit

var is_active = false
var target_type = "mole"

@onready var mole_sprite = $MoleSprite
# ---- LA FAUTE DE FRAPPE EST CORRIGÉE ICI ----
@onready var friend_sprite = $FriendSprite
# ---------------------------------------------
@onready var visibility_timer = $VisibilityTime


func _ready():
	mole_sprite.visible = false
	friend_sprite.visible = false
	visibility_timer.timeout.connect(hide_target)
	input_event.connect(_on_input_event)


func show_target(type):
	target_type = type
	is_active = true
	
	if target_type == "mole":
		mole_sprite.visible = true
	else:
		friend_sprite.visible = true
	
	visibility_timer.start(1.2)


func hide_target():
	is_active = false
	mole_sprite.visible = false
	friend_sprite.visible = false
	visibility_timer.stop()


# Version de débogage la plus détaillée possible
func _on_input_event(_viewport, event, _shape_idx):
	print("--- NOUVEAU TEST DE CLIC ---")
	print("Type de cible actuel: ", target_type)
	print("is_active est: ", is_active)

	# Étape 1: On vérifie si c'est bien un événement de souris.
	var is_mouse_button = event is InputEventMouseButton
	print("1. Est-ce un clic de souris ? -> ", is_mouse_button)

	# Si ce n'est même pas un clic de souris, on s'arrête là.
	if not is_mouse_button:
		print(">>> ÉCHEC: Ce n'est pas un événement de souris. On ignore.")
		return

	# Si on arrive ici, c'est que c'est bien un clic de souris.
	# Étape 2: On vérifie si le bouton est "pressé" (et non "relâché").
	var is_pressed = event.pressed
	print("2. Est-ce que le bouton est 'pressé' ? -> ", is_pressed)

	# Étape 3: On vérifie notre propre variable.
	print("3. Est-ce que 'is_active' est vrai ? -> ", is_active)

	# Maintenant, on fait le test final.
	if is_pressed and is_active:
		print(">>> SUCCÈS: Toutes les conditions sont VRAIES. Le clic est valide.")
		if target_type == "mole":
			emit_signal("mole_hit")
		else:
			emit_signal("friend_hit")
		
		hide_target()
	else:
		print(">>> ÉCHEC FINAL: Une des conditions 2 ou 3 est fausse. Le clic est ignoré.")
