extends Area2D

# --- AJOUT N°1 : Le signal pour la bombe ---
signal mole_hit
signal friend_hit
signal bomb_hit

var is_active = false
# target_type n'est plus vraiment nécessaire, mais on le garde pour la clarté.
var target_type = "mole" 

@onready var mole_unit = $MoleUnit
@onready var friend_unit = $FriendUnit
# --- AJOUT N°2 : La référence à la bombe ---
@onready var bomb_unit = $BombRoot
@onready var visibility_timer = $VisibilityTime


func _ready():
	mole_unit.visible = false
	friend_unit.visible = false
	# --- AJOUT N°3 : Cacher la bombe au démarrage ---
	bomb_unit.visible = false
	visibility_timer.timeout.connect(hide_target)
	
	# ---- MODIFICATION MAJEURE ----
	# On se connecte maintenant aux signaux de nos TROIS enfants !
	mole_unit.input_event.connect(_on_unit_input)
	friend_unit.input_event.connect(_on_unit_input)
	bomb_unit.input_event.connect(_on_unit_input)
	# --------------------------


func show_target(type):
	target_type = type
	is_active = true
	
	# --- MODIFICATION : Gérer les 3 cas ---
	mole_unit.visible = (type == "mole")
	friend_unit.visible = (type == "friend")
	bomb_unit.visible = (type == "bomb")
	
	visibility_timer.start() # J'ai enlevé la durée, elle est réglée dans l'inspecteur


func hide_target():
	is_active = false
	mole_unit.visible = false
	friend_unit.visible = false
	# --- AJOUT N°4 : Cacher aussi la bombe ---
	bomb_unit.visible = false
	visibility_timer.stop()


# --- MODIFICATION : On fusionne les deux fonctions en une seule ---
# Cette fonction est maintenant appelée par N'IMPORTE QUELLE unité cliquée.
func _on_unit_input(_viewport, event, _shape_idx):
	# On vérifie si c'est un clic valide et si la cible est active.
	if event is InputEventMouseButton and event.pressed and is_active:
		# On utilise le 'target_type' pour savoir quel signal envoyer.
		match target_type:
			"mole":
				emit_signal("mole_hit")
			"friend":
				emit_signal("friend_hit")
			"bomb":
				emit_signal("bomb_hit")
		
		hide_target()
