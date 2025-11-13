extends CanvasLayer


@onready var portail = $Monde1animation

func _on_bouton_monde_1_pressed() -> void:
	get_tree().change_scene_to_file("res://components/world_map/world_map.tscn")

func _ready():
	portail.play("default")

func _on_menu_button_pressed():
	# --- DEBUG ---
	# Ce message DOIT apparaître quand vous cliquez sur le bouton.
	print("DEBUG: Bouton Menu pressé ! Tentative de changement de scène...")
	
	# On redirige vers la scène du menu principal
	get_tree().change_scene_to_file("res://scenes/main_game/menu.tscn")
