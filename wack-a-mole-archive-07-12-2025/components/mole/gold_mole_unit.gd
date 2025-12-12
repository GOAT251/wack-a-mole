# Fichier : gold_mole_unit.gd
extends Area2D

signal hit
signal disappeared

@onready var anim_appear = $AnimationAppearGoldMoleUnit
@onready var anim_disappear = $AnimationDisappearGoldMoleUnit
@onready var collision_shape = $GoldMoleCollision

func _ready():
	input_event.connect(_on_input_event)
	reset()

func show_unit():
	visible = true
	anim_appear.play("appear")
	anim_appear.animation_finished.connect(_on_appear_finished, CONNECT_ONE_SHOT)

func hide_unit():
	collision_shape.disabled = true
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

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if not collision_shape.disabled:
			emit_signal("hit")