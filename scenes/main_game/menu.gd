# Fichier : menu.gd
extends CanvasLayer

# --- Références aux Nœuds du Menu ---
@onready var flammes = $flammes_menu
@onready var bouton_jouer = $BoutonJouer
@onready var bouton_inventaire = $AnimatedIcon 
@onready var bouton_equipement = $BoutonEquipement

# --- Références aux Panels et à leurs enfants ---
@onready var inventaire_panel = $InventairePanel
@onready var hammer_panel = $InventairePanel/Hammer_Panel 
@onready var marteaux_button = $InventairePanel/MarteauxButton
@onready var menu_button = $InventairePanel/menu_button


func _ready():
	flammes.play("default")
	inventaire_panel.hide()
	hammer_panel.hide()
	
	print("--- DIAGNOSTIC DÉMARRAGE ---")
	
	# 1. Test et Connexion Bouton Jouer
	if bouton_jouer:
		bouton_jouer.pressed.connect(_on_bouton_jouer_pressed)
	else:
		printerr("ERREUR : BoutonJouer introuvable !")

	# 2. Test et Connexion Bouton Equipement (CELUI QUI NOUS INTÉRESSE)
	if bouton_equipement:
		print("OK : BoutonEquipement trouvé, connexion en cours...")
		bouton_equipement.pressed.connect(_on_bouton_equipement_pressed)
	else:
		# --- ICI C'ETAIT L'ERREUR, J'AI RAJOUTÉ LE " et la ) ---
		printerr("ERREUR ROUGE : Le script ne trouve pas '$BoutonEquipement'. Vérifiez le nom dans la scène !")

	# 3. Connexion des autres boutons (classique)
	bouton_inventaire.pressed.connect(_on_bouton_inventaire_pressed)
	marteaux_button.pressed.connect(_on_MarteauxButton_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)


func _on_bouton_jouer_pressed():
	print("Bouton JOUER pressé ! -> Carte du Monde")
	if is_inside_tree():
		get_tree().change_scene_to_file("res://Selection monde/Selection monde.tscn")
	else:
		printerr("ERREUR: Le menu a essayé de changer de scène alors qu'il n'était pas dans l'arbre !")

func _on_bouton_equipement_pressed():
	print("Bouton EQUIPEMENT pressé ! -> Scène Equipement")
	if is_inside_tree():
		get_tree().change_scene_to_file("res://equipement/Equipement.tscn")
	else:
		printerr("ERREUR : Impossible de changer de scène vers Equipement.")

# Ce bouton principal ouvre/ferme l'inventaire complet.
func _on_bouton_inventaire_pressed():
	if inventaire_panel.visible:
		print("Bouton INVENTAIRE pressé (déjà ouvert) -> Ferme le panel")
		inventaire_panel.hide()
	else:
		print("Bouton INVENTAIRE pressé -> Affiche le panel")
		inventaire_panel.show()
		hammer_panel.hide() 

func _on_MarteauxButton_pressed():
	if hammer_panel.visible:
		print("Bouton MARTEAUX pressé (déjà ouvert) -> Ferme le Hammer_Panel")
		hammer_panel.hide()
	else:
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
