# Fichier : menu.gd
extends CanvasLayer

# --- Références aux Nœuds du Menu ---
@onready var flammes = $flammes_menu
@onready var bouton_jouer = $BoutonJouer
@onready var bouton_inventaire = $AnimatedIcon 

# --- Références aux Panels et à leurs enfants ---
@onready var inventaire_panel = $InventairePanel
@onready var hammer_panel = $InventairePanel/Hammer_Panel 
@onready var marteaux_button = $InventairePanel/MarteauxButton
@onready var menu_button = $InventairePanel/menu_button


func _ready():
	flammes.play("default")
	inventaire_panel.hide()
	hammer_panel.hide()
	
	bouton_jouer.pressed.connect(_on_bouton_jouer_pressed)
	bouton_inventaire.pressed.connect(_on_bouton_inventaire_pressed)
	marteaux_button.pressed.connect(_on_MarteauxButton_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)

func _on_bouton_jouer_pressed():
	print("Bouton JOUER pressé ! -> Carte du Monde")
	if is_inside_tree():
		get_tree().change_scene_to_file("res://Selection monde/Selection monde.tscn")
	else:
		printerr("ERREUR: Le menu a essayé de changer de scène alors qu'il n'était pas dans l'arbre !")

# Ce bouton principal ouvre/ferme l'inventaire complet.
func _on_bouton_inventaire_pressed():
	if inventaire_panel.visible:
		print("Bouton INVENTAIRE pressé (déjà ouvert) -> Ferme le panel")
		inventaire_panel.hide()
	else:
		print("Bouton INVENTAIRE pressé -> Affiche le panel")
		inventaire_panel.show()
		hammer_panel.hide() # On s'assure que le sous-menu est fermé à l'ouverture

# --- CORRIGÉ : Cette fonction est maintenant un "interrupteur" pour le Hammer_Panel ---
func _on_MarteauxButton_pressed():
	# On vérifie si le panel des marteaux est DEJA visible
	if hammer_panel.visible:
		# Si oui, on le cache
		print("Bouton MARTEAUX pressé (déjà ouvert) -> Ferme le Hammer_Panel")
		hammer_panel.hide()
	else:
		# Sinon (s'il est caché), on l'affiche
		print("Bouton MARTEAUX pressé -> Affiche le Hammer_Panel")
		hammer_panel.show()

func _on_menu_button_pressed():
	print("Bouton MENU pressé ! -> Ferme l'inventaire complet")
	inventaire_panel.hide()

func _on_map_fond_1_pressed():
	print("Bouton MAP FOND pressé !")
	if is_inside_tree():
		get_tree().change_scene_to_file("res://Selection monde/Selection monde.tscn")
	else:
		printerr("ERREUR: Le bouton Map Fond a essayé de changer de scène alors qu'il n'était pas dans l'arbre !")
