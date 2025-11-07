
extends Area2D

signal mole_hit
signal friend_hit

var is_active = false
# target_type n'est plus vraiment nécessaire, mais on le garde pour la clarté.
var target_type = "mole" 

@onready var mole_unit = $MoleUnit
@onready var friend_unit = $FriendUnit
@onready var visibility_timer = $VisibilityTime


func _ready():
	mole_unit.visible = false
	friend_unit.visible = false
	visibility_timer.timeout.connect(hide_target)
	
	# ---- CHANGEMENT MAJEUR ----
	# On ne se connecte plus à notre propre signal.
	# On se connecte aux signaux de nos ENFANTS !
	mole_unit.input_event.connect(_on_mole_unit_input)
	friend_unit.input_event.connect(_on_friend_unit_input)
	# --------------------------


func show_target(type):
	target_type = type
	is_active = true
	
	if target_type == "mole":
		mole_unit.visible = true
		friend_unit.visible = false
	else:
		friend_unit.visible = true
		mole_unit.visible = false
	
	visibility_timer.start(1.0)


func hide_target():
	is_active = false
	mole_unit.visible = false
	friend_unit.visible = false
	visibility_timer.stop()


# NOUVELLE FONCTION qui ne sera appelée QUE si on clique sur MoleUnit.
func _on_mole_unit_input(_viewport, event, _shape_idx):
	# On vérifie si c'est un clic valide et si la cible est active.
	if event is InputEventMouseButton and event.pressed and is_active:
		emit_signal("mole_hit")
		hide_target()


# NOUVELLE FONCTION qui ne sera appelée QUE si on clique sur FriendUnit.
func _on_friend_unit_input(_viewport, event, _shape_idx):
	# On vérifie si c'est un clic valide et si la cible est active.
	if event is InputEventMouseButton and event.pressed and is_active:
		emit_signal("friend_hit")
		hide_target()
