# Fichier : mole_unit.gd
extends Area2D

signal hit
signal disappeared

@onready var anim_appear = $AnimationAppearMole
@onready var anim_disappear = $AnimationDisappearMole
@onready var collision_shape = $MoleCollision

func _ready():
	input_event.connect(_on_input_event)
	reset()

func show_unit():
	visible = true
	anim_appear.play("appear")
	# On dit au moteur : "Quand cette animation est finie, appelle la fonction _on_appear_finished".
	anim_appear.animation_finished.connect(_on_appear_finished, CONNECT_ONE_SHOT)

func hide_unit():
	collision_shape.disabled = true
	anim_disappear.play("disappear")
	# On dit au moteur : "Quand cette animation est finie, appelle la fonction _on_disappear_finished".
	anim_disappear.animation_finished.connect(_on_disappear_finished, CONNECT_ONE_SHOT)

func _on_appear_finished(_anim_name):
	# L'animation est finie, on peut maintenant être cliqué.
	collision_shape.disabled = false

func _on_disappear_finished(_anim_name):
	# L'animation est finie, on se cache et on prévient qu'on a terminé le cycle.
	reset()
	emit_signal("disappeared")

func reset():
	visible = false
	collision_shape.disabled = true

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if not collision_shape.disabled:
			emit_signal("hit")