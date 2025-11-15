# Fichier : menu.gd
extends CanvasLayer

@onready var flammes = $flammes_menu
@onready var inventaire_panel = $InventairePanel
@onready var bouton_jouer = $BoutonJouer # Assurez-vous que ce nom est correct
@onready var bouton_inventaire = $AnimatedIcon # Assurez-vous que ce nom est correct

func _ready():
	flammes.play("default")
	inventaire_panel.hide()
	
	bouton_jouer.pressed.connect(_on_bouton_jouer_pressed)
	bouton_inventaire.pressed.connect(_on_bouton_inventaire_pressed)

func _on_bouton_jouer_pressed():
	print("Bouton JOUER pressé ! -> Carte du Monde")
	
	# --- LA CORRECTION FINALE ET SÉCURISÉE ---
	# On vérifie si notre noeud est bien dans l'arbre de la scène.
	if is_inside_tree():
		# Si oui, on change de scène.
		get_tree().change_scene_to_file("res://Selection monde/Selection monde.tscn")
	else:
		# Sinon, on affiche une erreur claire pour le débogage.
		printerr("ERREUR: Le menu a essayé de changer de scène alors qu'il n'était pas dans l'arbre !")


func _on_bouton_inventaire_pressed():
	print("Bouton INVENTAIRE pressé ! -> Affiche le panel")
	inventaire_panel.show()

# NOTE : J'applique la même correction ici pour être sûr.
func _on_map_fond_1_pressed():
	print("Bouton MAP FOND pressé !")
	if is_inside_tree():
		get_tree().change_scene_to_file("res://Selection monde/Selection monde.tscn")
	else:
		printerr("ERREUR: Le bouton Map Fond a essayé de changer de scène alors qu'il n'était pas dans l'arbre !")
