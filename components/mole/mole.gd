extends Area2D

signal mole_hit
signal friend_hit
signal bomb_hit

var is_active = false
var target_type = "mole" 

@onready var mole_unit = $MoleUnit
@onready var friend_unit = $FriendUnit
@onready var bomb_unit = $BombRoot
@onready var visibility_timer = $VisibilityTime

func _ready():
	# On s'assure que tout est invisible au démarrage
	mole_unit.visible = false
	friend_unit.visible = false
	bomb_unit.visible = false

	# On connecte le timer qui fait disparaître la taupe
	visibility_timer.timeout.connect(hide_target)
	
	# On connecte les zones de clic
	mole_unit.input_event.connect(_on_unit_input)
	friend_unit.input_event.connect(_on_unit_input)
	bomb_unit.input_event.connect(_on_unit_input)

func show_target(type):
	target_type = type
	is_active = true
	
	# On gère quel sprite est visible
	mole_unit.visible = (type == "mole")
	friend_unit.visible = (type == "friend")
	bomb_unit.visible = (type == "bomb")
	
	# --- CETTE LIGNE EST LA PLUS IMPORTANTE POUR VOTRE BUG ---
	# Elle démarre le compte à rebours pour la disparition automatique.
	visibility_timer.start()

func hide_target():
	is_active = false
	mole_unit.visible = false
	friend_unit.visible = false
	bomb_unit.visible = false
	visibility_timer.stop() # On arrête le timer pour être propre

func _on_unit_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and is_active:
		match target_type:
			"mole":
				emit_signal("mole_hit")
			"friend":
				emit_signal("friend_hit")
			"bomb":
				emit_signal("bomb_hit")
		
		# On se cache immédiatement après un clic réussi
		hide_target()