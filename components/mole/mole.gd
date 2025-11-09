# Dans mole.gd

extends Area2D

# Signaux que le trou relaie vers l'extérieur.
signal mole_hit
signal friend_hit
signal bomb_hit

@onready var mole_unit = $MoleUnit
@onready var friend_unit = $FriendUnit
@onready var bomb_root = $BombRoot # Nom corrigé
@onready var visibility_timer = $VisibilityTime

var is_active = false
# --- AJOUT : Variable pour recevoir la référence du StatusManager ---
var status_manager: Node

func _ready():
	visibility_timer.timeout.connect(hide_target)
	
	# Le chef d'orchestre écoute ses musiciens.
	mole_unit.hit.connect(_on_mole_unit_hit)
	friend_unit.hit.connect(_on_friend_unit_hit)
	bomb_root.hit.connect(_on_bomb_unit_hit) # Nom corrigé
	
	# On cache tout au démarrage.
	mole_unit.visible = false
	friend_unit.visible = false
	bomb_root.visible = false # Nom corrigé

func show_target(type):
	if is_active: return
	is_active = true
	
	match type:
		"mole":
			mole_unit.visible = true
		"friend":
			friend_unit.visible = true
		"bomb":
			bomb_root.visible = true # Nom corrigé
			# --- AJOUT : On passe la référence au script de la bombe ---
			# On suppose que le script attaché à BombRoot s'appelle BombRoot.gd
			# et qu'il a une variable 'status_manager'.
			if status_manager:
				bomb_root.status_manager = status_manager
	
	visibility_timer.start()

func hide_target():
	if not is_active: return
	is_active = false
	
	mole_unit.visible = false
	friend_unit.visible = false
	bomb_root.visible = false # Nom corrigé
	
	visibility_timer.stop()

# --- Fonctions relais ---
func _on_mole_unit_hit():
	emit_signal("mole_hit")
	hide_target()

func _on_friend_unit_hit():
	emit_signal("friend_hit")
	hide_target()

func _on_bomb_unit_hit():
	emit_signal("bomb_hit")
	hide_target()