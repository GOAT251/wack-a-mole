# Fichier : effect_icon_manager.gd
extends Node

# --- On précharge les ressources ---
const ROOT_EFFECT_ICON = preload("res://assets/images/patte taupe racine2.png")
const SCORE_X2_ICON = preload("res://assets/images/icone X2.jpg")

# --- Références aux Nœuds qu'on doit contrôler ---
# J'utilise les noms que vous m'avez confirmés.
@onready var effect_icon_1 = get_parent().get_node("StateContainer/EffectSlot1/EffectIcon1")
@onready var effect_icon_2 = get_parent().get_node("StateContainer/EffectSlot2/EffectIcon2")

# --- Notre cerveau mémorise l'état des bonus ---
var is_root_active = false
var is_x2_active = false

# --- Les fonctions publiques que l'UI va appeler (ne changent pas) ---
func set_root_status(is_active: bool):
	is_root_active = is_active
	_update_icons()

func set_x2_status(is_active: bool):
	is_x2_active = is_active
	_update_icons()

# --- LA FONCTION "MAÎTRESSE" CORRIGÉE ---
func _update_icons():
	# On crée une liste de slots disponibles.
	var available_slots = [effect_icon_1, effect_icon_2]
	
	# On commence par tout effacer pour être propre.
	for slot in available_slots:
		slot.texture = null
	
	# Maintenant, on place les icônes actives dans les premiers slots libres.
	# C'est cette logique qui va tout changer.
	if is_x2_active:
		# Si X2 est actif, il prend le premier slot disponible.
		if not available_slots.is_empty():
			var first_slot = available_slots.pop_front() # On prend et on retire le premier slot
			first_slot.texture = SCORE_X2_ICON
			
	if is_root_active:
		# Si Root est actif, il prend le premier slot disponible QUI RESTE.
		if not available_slots.is_empty():
			var first_slot = available_slots.pop_front()
			first_slot.texture = ROOT_EFFECT_ICON