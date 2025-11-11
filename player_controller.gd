pass# Dans PlayerController.gd
extends Node

# Il a besoin de connaître les éléments qu'il contrôle
@export var freeze_shield: ColorRect
@export var ui_node: CanvasLayer

# C'est LA fonction qui écoute le StatusManager
func on_status_effect_changed(effect_name: String, is_active: bool):
	if effect_name == "rooted":
		if freeze_shield:
			freeze_shield.visible = is_active
		
		# On cherche le gestionnaire d'affichage dans l'UI
		var status_display = ui_node.get_node("StateContainer")
		if status_display:
			status_display.update_effect(effect_name, is_active)
			
	if effect_name == "gold":
		# La logique pour l'effet gold reste ici
		pass