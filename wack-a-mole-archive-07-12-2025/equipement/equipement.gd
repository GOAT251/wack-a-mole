extends Control

# --- RÉFÉRENCES EXISTANTES ---
@onready var info_panel = $ItemInfoPanel
@onready var hammer_list = $Hammer_PanelEQUI
@onready var bouton_marteau = $BoutonMarteau
@onready var icon_display = $BoutonMarteau/IconDisplay

# Vérifiez que le bouton s'appelle bien "BoutonRetour" dans la scène !
@onready var bouton_retour = $BoutonRetour 

# --- IMAGES ---
@export var fond_neutre: Texture2D 
var fond_socle_original: Texture2D 

# --- NOUVEAU : Variable pour stocker le gestionnaire une fois trouvé ---
var gestionnaire_gemmes_ref = null 

func _ready():
	print("\n--- DÉMARRAGE SCÈNE EQUIPEMENT ---")
	
	# 1. Initialisation UI existante
	info_panel.hide()
	hammer_list.hide()
	
	if bouton_marteau:
		fond_socle_original = bouton_marteau.texture_normal
		bouton_marteau.pressed.connect(_on_bouton_marteau_pressed)

	if bouton_retour:
		bouton_retour.pressed.connect(_on_bouton_retour_pressed)
	else:
		printerr("ERREUR : 'BoutonRetour' introuvable à la racine de la scène Equipement.")

	var buttons = get_tree().get_nodes_in_group("smart_buttons")
	for btn in buttons:
		if not btn.item_clicked.is_connected(_on_item_clicked):
			btn.item_clicked.connect(_on_item_clicked)
	
	update_button_visuals()
	
	# ============================================================
	# 2. LE RADAR : RECHERCHE AUTOMATIQUE DES GEMMES
	# ============================================================
	# On cherche le noeud partout dans les enfants, même profondément (true)
	gestionnaire_gemmes_ref = find_child("GestionnaireGemmes", true, false)
	
	if gestionnaire_gemmes_ref:
		print("✅ SUCCÈS : Noeud 'GestionnaireGemmes' trouvé !")
		print("   > Chemin : ", gestionnaire_gemmes_ref.get_path())
		
		# On vérifie si le script est bien attaché
		if gestionnaire_gemmes_ref.has_method("mettre_a_jour"):
			print("   > Script OK. Lancement de l'affichage...")
			gestionnaire_gemmes_ref.call_deferred("mettre_a_jour")
		else:
			printerr("🔴 ERREUR : Le noeud est trouvé mais n'a pas le script 'EquipementGemmes.gd' !")
	else:
		printerr("🔴 ERREUR CRITIQUE : Impossible de trouver 'GestionnaireGemmes' dans la scène !")
		print("👉 Vérifie que tu as bien nommé le noeud 'GestionnaireGemmes' (Attention aux majuscules).")

func _process(_delta):
	update_button_visuals()

func update_button_visuals():
	if PlayerData.equipped_hammer:
		if fond_neutre: bouton_marteau.texture_normal = fond_neutre
		if icon_display:
			icon_display.show()
			icon_display.texture = PlayerData.equipped_hammer.icon
	else:
		if fond_socle_original: bouton_marteau.texture_normal = fond_socle_original
		if icon_display: icon_display.hide()

func _on_item_clicked(data):
	info_panel.show_with_data(data)
	info_panel.move_to_front()

func _on_bouton_marteau_pressed():
	if hammer_list.visible:
		hammer_list.hide()
		info_panel.hide()
	else:
		hammer_list.show()
		hammer_list.move_to_front()

func _on_bouton_retour_pressed():
	print("Retour au menu principal...")
	get_tree().change_scene_to_file("res://scenes/main_game/menu.tscn")