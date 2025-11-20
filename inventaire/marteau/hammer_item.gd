# SmartButton.gd (Version modifiée pour deux textures ET pour le test)
class_name SmartButton
extends TextureButton

signal item_clicked(data: UnlockableItemData)

@export var item_data: UnlockableItemData
@export var greyscale_if_locked: bool = true

@onready var icon_display: TextureRect = $IconDisplay

func _ready():
	if not item_data:
		print("ATTENTION : Le bouton '%s' n'a pas de données (item_data) !" % self.name)
		return
	if not icon_display:
		print("ERREUR : Le bouton '%s' n'a pas de nœud enfant nommé 'IconDisplay' !" % self.name)
		return

	icon_display.texture = item_data.icon

	if not item_data.is_unlocked and greyscale_if_locked:
		var grey_material = CanvasItemMaterial.new()
		grey_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		icon_display.material = grey_material
		icon_display.self_modulate = Color.GRAY
	else:
		icon_display.material = null
		icon_display.self_modulate = Color.WHITE

	self.pressed.connect(_on_pressed)

func _on_pressed():
	# --- LIGNE DE TEST AJOUTÉE ---
	# Cette ligne va nous dire si Godot détecte bien le clic sur ce bouton.
	print(">>> 1. Clic détecté sur le bouton : ", self.name)
	
	if item_data:
		emit_signal("item_clicked", item_data)