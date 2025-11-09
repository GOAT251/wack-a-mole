# Dans bomb_root.gd

extends Area2D

signal hit

var status_manager: Node

func _ready():
	input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if status_manager:
			# --- CORRECTION ICI ---
			# REMPLACEZ "apply_root" par "apply_freeze"
			status_manager.apply_freeze(6.0) 
		
		emit_signal("hit")