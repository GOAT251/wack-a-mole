extends CanvasLayer

@onready var portail = $Monde1animation

# La fonction _ready() est appelée une seule fois au démarrage.
# C'est ici qu'on doit mettre TOUS les ordres de démarrage.
func _ready():
	portail.play("default")

# Les autres fonctions ne changent pas.
func _on_bouton_monde_1_pressed() -> void:
	get_tree().change_scene_to_file("res://components/world_map/world_map.tscn")

func _on_menu_button_pressed():
	print("DEBUG: Bouton Menu pressé ! Tentative de changement de scène...")
	get_tree().change_scene_to_file("res://scenes/main_game/menu.tscn")
