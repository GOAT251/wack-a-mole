# Fichier : menu.gd
# À attacher au noeud racine de votre scène de menu (le CanvasLayer)

extends CanvasLayer

# 1. On prend une référence à notre animation de flammes.
# Le signe "$" veut dire "cherche un de mes enfants directs".
@onready var flammes = $flammes_menu

# La fonction _ready() est appelée une seule fois, au démarrage de la scène.
func _ready():
	# 2. On dit simplement aux flammes de jouer leur animation.
	# Assurez-vous que le nom de l'animation dans votre AnimatedSprite2D est bien "default".
	# Si vous l'avez renommé (ex: "burn"), mettez ce nom ici.
	flammes.play("default")

func _on_map_fond_1_pressed():
	# --- DEBUG ---
	# Ce message DOIT apparaître quand vous cliquez sur le bouton.
	print("DEBUG: Bouton Menu pressé ! Tentative de changement de scène...")
	
	# On redirige vers la scène du menu principal
	get_tree().change_scene_to_file("res://Selection monde/Selection monde.tscn")
