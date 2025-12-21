# Fichier : friend_unit.gd
extends Area2D

signal hit
signal disappeared

# MODIFICATION 1 : On ajoute un "drapeau" pour se souvenir si on a été touché.
var was_hit_by_player = false

@onready var anim_appear = $AnimationAppearFriend
@onready var anim_disappear = $AnimationDisappearFriend
@onready var collision_shape = $FriendCollision
@onready var poof_effect = get_parent().get_node("PoofEffect")
@onready var sprite_visuel = $FriendSprite

func _ready():
	input_event.connect(_on_input_event)
	reset()

func show_unit():
	visible = true
	anim_appear.play("appear")
	anim_appear.animation_finished.connect(_on_appear_finished, CONNECT_ONE_SHOT)

func hide_unit():
	collision_shape.disabled = true
	
	# MODIFICATION 3 : LA LOGIQUE CLÉ EST ICI.
	# On vérifie si le drapeau a été levé.
	if was_hit_by_player:
		# Si OUI (on a été touché), on disparaît INSTANTANÉMENT...
		reset()
		# ...et on prévient mole.gd que le cycle est terminé.
		emit_signal("disappeared")
	else:
		# Si NON (c'est un timeout), on joue l'animation de disparition normale.
		anim_disappear.play("disappear")
		anim_disappear.animation_finished.connect(_on_disappear_finished, CONNECT_ONE_SHOT)

func _on_appear_finished(_anim_name):
	collision_shape.disabled = false

func _on_disappear_finished(_anim_name):
	reset()
	emit_signal("disappeared")

func reset():
	visible = false
	collision_shape.disabled = true
	# On s'assure de baisser le drapeau à chaque fois qu'on se réinitialise.
	was_hit_by_player = false

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if not collision_shape.disabled:
			
			# MODIFICATION 2 : Quand on est touché, on lève le drapeau.
			was_hit_by_player = true
			
			# On joue l'effet "poof" comme avant.
			poof_effect.global_position = sprite_visuel.global_position
			poof_effect.visible = true
			poof_effect.play("poof")
			
			# On envoie le signal "hit" comme avant.
			emit_signal("hit")