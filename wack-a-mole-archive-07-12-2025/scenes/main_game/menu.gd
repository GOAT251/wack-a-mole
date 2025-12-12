# Fichier : menu.gd
extends CanvasLayer

# --- Références aux Nœuds du Menu ---
@onready var flammes = $flammes_menu
@onready var bouton_jouer = $BoutonJouer
@onready var bouton_inventaire = $AnimatedIcon 
@onready var bouton_equipement = $BoutonEquipement
@onready var bouton_tirage = $BoutonTirage
@onready var gemme_container = $gemmeDanim 

# --- Références aux Panels et à leurs enfants ---
@onready var inventaire_panel = $InventairePanel
@onready var menu_button = $InventairePanel/menu_button

# --- SOUS-MENUS (Marteaux & Gemmes) ---
@onready var hammer_panel = $InventairePanel/Hammer_Panel 
@onready var marteaux_button = $InventairePanel/MarteauxButton

# AJOUT : Références pour les Gemmes (Vérifie bien les noms dans ta scène !)
@onready var gem_panel = $InventairePanel/GemInventaire # Adapte si ton panel s'appelle autrement
@onready var gemmes_button = $InventairePanel/GemmesButton # Le bouton pour ouvrir l'onglet gemmes

func _ready():
	flammes.play("default")
	
	# On cache tout au démarrage
	inventaire_panel.hide()
	hammer_panel.hide()
	if gem_panel: gem_panel.hide()
	
	print("--- DIAGNOSTIC DÉMARRAGE ---")
	
	# 1. Test et Connexion Bouton Jouer
	if bouton_jouer:
		bouton_jouer.pressed.connect(_on_bouton_jouer_pressed)
	else:
		printerr("ERREUR : BoutonJouer introuvable !")

	# 2. Test et Connexion Bouton Equipement
	if bouton_equipement:
		bouton_equipement.pressed.connect(_on_bouton_equipement_pressed)

	# 3. Connexion des autres boutons
	bouton_inventaire.pressed.connect(_on_bouton_inventaire_pressed)
	marteaux_button.pressed.connect(_on_MarteauxButton_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	
	# AJOUT : Connexion du bouton Gemmes
	if gemmes_button:
		gemmes_button.pressed.connect(_on_gemmes_button_pressed)
	else:
		print("INFO : Pas de noeud 'GemmesButton' trouvé dans InventairePanel.")

	if bouton_tirage:
		bouton_tirage.pressed.connect(_on_bouton_tirage_pressed)
	
	if gemme_container:
		# On prend tous les enfants (les 10 gemmes)
		for gemme in gemme_container.get_children():
			# On vérifie si c'est bien un AnimatedSprite2D pour éviter les bugs
			if gemme is AnimatedSprite2D:
				gemme.play("default")

# --- NAVIGATION GÉNÉRALE ---

func _on_bouton_jouer_pressed():
	print("Bouton JOUER pressé ! -> Carte du Monde")
	if is_inside_tree():
		get_tree().change_scene_to_file("res://Selection monde/Selection monde.tscn")

func _on_bouton_equipement_pressed():
	print("Bouton EQUIPEMENT pressé ! -> Scène Equipement")
	if is_inside_tree():
		get_tree().change_scene_to_file("res://equipement/Equipement.tscn")

func _on_bouton_tirage_pressed():
	print("Bouton TIRAGE pressé ! -> Scène Tirage")
	if is_inside_tree():
		# CORRECTION : Je renvoie vers Tirage.tscn (avant c'était Equipement par erreur)
		get_tree().change_scene_to_file("res://Tirage/Tirage.tscn") 
	else:
		printerr("ERREUR : Impossible de changer de scène vers Tirage.")

func _on_map_fond_1_pressed():
	# Si tu as un bouton invisible sur le fond
	if is_inside_tree():
		get_tree().change_scene_to_file("res://Selection monde/Selection monde.tscn")

# --- GESTION DE L'INVENTAIRE ---

# Ce bouton principal ouvre/ferme le GROS panel inventaire.
func _on_bouton_inventaire_pressed():
	if inventaire_panel.visible:
		inventaire_panel.hide()
	else:
		inventaire_panel.show()
		# On s'assure que les sous-menus sont fermés au début pour être propre
		hammer_panel.hide()
		if gem_panel: gem_panel.hide()

func _on_menu_button_pressed():
	print("Bouton MENU pressé ! -> Ferme l'inventaire complet")
	inventaire_panel.hide()

# --- SOUS-MENUS (ONGLETS) ---

func _on_MarteauxButton_pressed():
	if hammer_panel.visible:
		hammer_panel.hide()
	else:
		# On ouvre Marteaux et on ferme Gemmes (Exclusivité)
		hammer_panel.show()
		if gem_panel: gem_panel.hide()

# AJOUT : La fonction demandée pour les Gemmes
func _on_gemmes_button_pressed():
	# Sécurité si le panel n'est pas assigné
	if not gem_panel: return

	if gem_panel.visible:
		print("Onglet GEMMES déjà ouvert -> Fermer")
		gem_panel.hide()
	else:
		print("Onglet GEMMES ouvert -> Afficher")
		# On ouvre Gemmes et on ferme Marteaux
		gem_panel.show()
		hammer_panel.hide()
		
		# CRUCIAL : On met à jour l'affichage des gemmes (Grille)
		# Le script attaché à GemPanel2 doit avoir la fonction 'mettre_a_jour_affichage'
		if gem_panel.has_method("mettre_a_jour_affichage"):
			gem_panel.mettre_a_jour_affichage()
		else:
			print("Note : Le GemPanel n'a pas de méthode 'mettre_a_jour_affichage'.")