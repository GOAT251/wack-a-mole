# Fichier : effect_icon_manager.gd
extends Node

# --- On précharge les ressources ---
const ROOT_EFFECT_ICON = preload("res://assets/images/patte taupe racine2.png")
const SCORE_X2_ICON = preload("res://assets/images/icone X2.jpg")

# --- Références aux Nœuds qu'on doit contrôler ---
# On les récupère depuis notre parent, l'UI.
@onready var effect_icon_1 = get_parent().get_node("StateContainer/EffectSlot1/EffectIcon1")
@onready var effect_icon_2 = get_parent().get_node("StateContainer/EffectSlot2/EffectIcon2")

# --- Notre cerveau mémorise l'état des bonus ---
var is_root_active = false
var is_x2_active = false

# --- Les fonctions publiques que l'UI va appeler ---
func set_root_status(is_active: bool):
	is_root_active = is_active
	_update_icons()

func set_x2_status(is_active: bool):
	is_x2_active = is_active
	_update_icons()

# --- La fonction "maîtresse" privée qui fait tout le travail ---
func _update_icons():
	# Étape 1 : On efface tout.
	effect_icon_1.texture = null
	effect_icon_2.texture = null
	
	# Étape 2 : On fait la liste des effets actifs.
	var active_icons = []
	if is_root_active:
		active_icons.append(ROOT_EFFECT_ICON)
	if is_x2_active:
		active_icons.append(SCORE_X2_ICON)
		
	# Étape 3 : On place les icônes dans les slots disponibles.
	if active_icons.size() >= 1:
		effect_icon_1.texture = active_icons[0]
	
	if active_icons.size() >= 2:
		effect_icon_2.texture = active_icons[1]