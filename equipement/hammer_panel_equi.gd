# Dans votre script de menu principal, que vous appelez hammer_panel
extends Control # Ou Node, selon le type de votre racine

# --- RÉFÉRENCES AUX NŒUDS ---

# 1. Référence vers le panneau qui affichera les informations.
#    Assurez-vous qu'il est bien dans votre scène de menu et que le chemin est correct.
@onready var item_info_panel = $ItemInfoPanel 

# 2. (Optionnel) Vous pouvez avoir d'autres boutons comme "Jouer", "Options", etc.
# @onready var play_button = $PlayButton


# --- LA FONCTION _READY() ---

# Cette fonction est appelée automatiquement par Godot au démarrage de la scène.
# C'est l'endroit parfait pour faire toutes les connexions initiales.
func _ready():
	# --------------------------------------------------------------------- #
	# --- CODE INTÉGRÉ POUR LA CONNEXION DES BOUTONS D'ITEMS --- #
	
	# On demande à Godot de trouver tous les nœuds appartenant au groupe "smart_buttons".
	var all_item_buttons = get_tree().get_nodes_in_group("smart_buttons")
	
	# --- LIGNE DE TEST 2 AJOUTÉE ---
	# Cette ligne va s'afficher au démarrage et nous dire combien de boutons
	# ont été trouvés dans le groupe "smart_buttons".
	print(">>> 2. Connexion en cours. Nombre de boutons trouvés : ", all_item_buttons.size())
	
	# On fait une boucle sur chaque bouton que Godot a trouvé.
	for button in all_item_buttons:
		# Pour chaque bouton, on connecte son signal personnalisé "item_clicked"
		# à la fonction "show_with_data" de notre panneau d'information.
		# Quand un bouton sera cliqué -> il enverra le signal -> la fonction du panneau sera appelée.
		button.item_clicked.connect(item_info_panel.show_with_data)
	
	# --- FIN DU CODE INTÉGRÉ --- #
	# --------------------------------------------------------------------- #
	
	# Votre autre code de _ready() peut rester ici sans problème. Par exemple :
	# play_button.pressed.connect(_on_play_button_pressed)
	# print("Le menu principal est prêt !")


# --- AUTRES FONCTIONS DE VOTRE MENU ---

# Par exemple, la fonction pour lancer le jeu.
# func _on_play_button_pressed():
#     get_tree().change_scene_to_file("res://scenes/main_game/game.tscn")
