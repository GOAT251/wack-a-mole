# Dans mole.gd

extends Area2D

# Signaux (ne changent pas)
signal mole_hit
signal friend_hit
signal bomb_hit
signal gold_mole_hit

# Références
@onready var mole_unit = $MoleUnit
@onready var friend_unit = $FriendUnit
@onready var bomb_root = $BombRoot
@onready var gold_mole_unit = $GoldMoleUnit
@onready var visibility_timer = $VisibilityTime
# --- AJOUT : La référence à notre lecteur d'animation ---
@onready var animation_player = $AnimationPlayer

var is_active = false
var status_manager: Node

func _ready():
	visibility_timer.timeout.connect(hide_target)
	
	# Les connexions des signaux "hit" ne changent pas
	mole_unit.hit.connect(_on_mole_unit_hit)
	friend_unit.hit.connect(_on_friend_unit_hit)
	bomb_root.hit.connect(_on_bomb_unit_hit)
	gold_mole_unit.hit.connect(_on_gold_mole_unit_hit)
	
	# On cache tout au démarrage (ne change pas)
	mole_unit.visible = false
	friend_unit.visible = false
	bomb_root.visible = false
	gold_mole_unit.visible = false

# --- MODIFICATION DE CETTE FONCTION ---
func show_target(type):
	if is_active: return
	is_active = true
	
	# On s'assure que tout est caché avant de commencer, c'est plus propre.
	mole_unit.visible = false
	friend_unit.visible = false
	bomb_root.visible = false
	gold_mole_unit.visible = false

	# On joue l'animation d'apparition.
	# L'animation elle-même va positionner et mettre à l'échelle le bon sprite.
	animation_player.play("appear")
	
	# Ensuite, on rend visible l'unité parente (l'Area2D) pour qu'on puisse cliquer dessus.
	match type:
		"mole":
			mole_unit.visible = true
		"friend":
			friend_unit.visible = true
		"bomb":
			bomb_root.visible = true
			if status_manager:
				bomb_root.status_manager = status_manager
		"gold_mole":
			gold_mole_unit.visible = true
	
	# Le timer pour la disparition automatique ne change pas.
	visibility_timer.start()

# Cette fonction n'est PAS encore modifiée.
# Elle va faire disparaître la taupe instantanément. C'est normal pour ce test.
func hide_target():
	if not is_active: return
	is_active = false
	
	mole_unit.visible = false
	friend_unit.visible = false
	bomb_root.visible = false
	gold_mole_unit.visible = false
	
	visibility_timer.stop()

# Les fonctions relais ne changent pas.
func _on_mole_unit_hit():
	emit_signal("mole_hit")
	hide_target()

func _on_friend_unit_hit():
	emit_signal("friend_hit")
	hide_target()

func _on_bomb_unit_hit():
	emit_signal("bomb_hit")
	hide_target()

func _on_gold_mole_unit_hit():
	emit_signal("gold_mole_hit")
	hide_target()
