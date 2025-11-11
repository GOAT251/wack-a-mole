extends Area2D

# 1. On déclare TOUS les signaux possibles
signal mole_hit
signal friend_hit
signal bomb_hit
signal gold_mole_hit

var is_active = false
var target_type = "mole"

# 2. On référence TOUS les conteneurs d'unités
@onready var mole_unit = $MoleUnit
@onready var friend_unit = $FriendUnit
@onready var bomb_unit = $BombRoot
@onready var gold_mole_unit = $GoldMoleUnit
@onready var visibility_timer = $VisibilityTime

func _ready():
	# On cache tout au démarrage, PROPREMENT.
	hide_all()
	
	# On connecte le timer pour qu'il cache tout à la fin de sa durée.
	visibility_timer.timeout.connect(hide_all)
	
	# ON RETOURNE À VOTRE LOGIQUE ORIGINALE QUI FONCTIONNAIT.
	# La racine Area2D écoute les clics. C'est tout.
	input_event.connect(_on_input_event)

func show_target(type):
	target_type = type
	is_active = true
	
	# On affiche le bon élément et on cache les autres
	mole_unit.visible = (type == "mole")
	friend_unit.visible = (type == "friend")
	bomb_unit.visible = (type == "bomb")
	gold_mole_unit.visible = (type == "gold_mole")
	
	# On démarre le timer avec une durée fixe pour être sûr.
	visibility_timer.start(1.0)

# Une seule fonction pour tout cacher.
func hide_all():
	is_active = false
	mole_unit.visible = false
	friend_unit.visible = false
	bomb_unit.visible = false
	gold_mole_unit.visible = false
	visibility_timer.stop()

# La SEULE fonction qui gère les clics.
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and is_active:
		# En fonction du type actif, on envoie UN SEUL signal.
		match target_type:
			"mole":
				emit_signal("mole_hit")
			"friend":
				emit_signal("friend_hit")
			"bomb":
				emit_signal("bomb_hit")
			"gold_mole":
				emit_signal("gold_mole_hit")
		
		# On cache la cible après le clic.
		hide_all()