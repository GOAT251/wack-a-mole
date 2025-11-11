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

# --- AJOUT N°1 : Les références à VOS AnimationPlayers ---
@onready var mole_anim_appear = $MoleUnit/AnimationAppearMole
@onready var mole_anim_disappear = $MoleUnit/AnimationDisappearMole
@onready var friend_anim_appear = $FriendUnit/AnimationAppearFriend
@onready var friend_anim_disappear = $FriendUnit/AnimationDisappearFriend
@onready var bomb_anim_appear = $BombRoot/AnimationAppearBombRoot
@onready var bomb_anim_disappear = $BombRoot/AnimationDisappearBombRoot
@onready var gold_mole_anim_appear = $GoldMoleUnit/AnimationAppearGoldMoleUnit
@onready var gold_mole_anim_disappear = $GoldMoleUnit/AnimationDisappearGoldMoleUnit
# -----------------------------------------------------------

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

	# --- AJOUT N°2 : On joue la bonne animation d'apparition ---
	match type:
		"mole":
			mole_anim_appear.play("appear")
		"friend":
			friend_anim_appear.play("appear")
		"bomb":
			bomb_anim_appear.play("appear")
		"gold_mole":
			gold_mole_anim_appear.play("appear")
	# ---------------------------------------------------------
	
	# Ensuite, on rend visible l'unité parente (l'Area2D) pour qu'on puisse cliquer dessus.
	# Cette partie ne change pas.
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

# --- MODIFICATION DE CETTE FONCTION ---
func hide_target():
	if not is_active: return
	
	# On se marque comme inactif immédiatement pour éviter les double-clics.
	is_active = false
	visibility_timer.stop()

	# --- AJOUT N°3 : On joue la bonne animation de disparition ---
	# On regarde quelle unité était visible pour savoir quelle animation jouer.
	if mole_unit.visible:
		mole_anim_disappear.play("disappear")
	elif friend_unit.visible:
		friend_anim_disappear.play("disappear")
	elif bomb_root.visible:
		bomb_anim_disappear.play("disappear")
	elif gold_mole_unit.visible:
		gold_mole_anim_disappear.play("disappear")
	# ------------------------------------------------------------
	
	# On ne cache plus les sprites manuellement. L'animation s'en chargera.

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