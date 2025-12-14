extends Control

# --- RÉFÉRENCES ---
@onready var info_panel = $ItemInfoPanel
@onready var hammer_list = $Hammer_PanelEQUI
@onready var bouton_marteau = $BoutonMarteau
@onready var icon_display = $BoutonMarteau/IconDisplay
@onready var bouton_retour = $BoutonRetour 

# --- NOUVEAU : Référence au panel Inventaire EQUI ---
# Assure-toi que le nom du noeud dans la scène est bien "GemInventaireEQUI"
@onready var inventaire_equi = $GemInventaireEQUI

# Images
@export var fond_neutre: Texture2D 
var fond_socle_original: Texture2D 

var gestionnaire_gemmes_ref = null 

func _ready():
	print("\n--- DÉMARRAGE SCÈNE EQUIPEMENT ---")
	
	info_panel.hide()
	hammer_list.hide()
	
	# Sécurité : On cache l'inventaire au début
	if inventaire_equi:
		inventaire_equi.hide()
	else:
		printerr("ATTENTION : Je ne trouve pas le noeud 'GemInventaireEQUI' dans la scène Equipement.")
	
	if bouton_marteau:
		fond_socle_original = bouton_marteau.texture_normal
		bouton_marteau.pressed.connect(_on_bouton_marteau_pressed)

	if bouton_retour:
		bouton_retour.pressed.connect(_on_bouton_retour_pressed)

	var buttons = get_tree().get_nodes_in_group("smart_buttons")
	for btn in buttons:
		if not btn.item_clicked.is_connected(_on_item_clicked):
			btn.item_clicked.connect(_on_item_clicked)
	
	update_button_visuals()
	
	# RADAR Gestionnaire
	gestionnaire_gemmes_ref = find_child("GestionnaireGemmes", true, false)
	if gestionnaire_gemmes_ref and gestionnaire_gemmes_ref.has_method("mettre_a_jour"):
		gestionnaire_gemmes_ref.call_deferred("mettre_a_jour")

func _process(_delta):
	update_button_visuals()

func update_button_visuals():
	if PlayerData.equipped_hammer:
		if fond_neutre: bouton_marteau.texture_normal = fond_neutre
		if icon_display: icon_display.show(); icon_display.texture = PlayerData.equipped_hammer.icon
	else:
		if fond_socle_original: bouton_marteau.texture_normal = fond_socle_original
		if icon_display: icon_display.hide()

func _on_item_clicked(data):
	info_panel.show_with_data(data)
	info_panel.move_to_front()

func _on_bouton_marteau_pressed():
	if hammer_list.visible: hammer_list.hide(); info_panel.hide()
	else: hammer_list.show(); hammer_list.move_to_front()

# --- LOGIQUE INTELLIGENTE DU BOUTON RETOUR ---
func _on_bouton_retour_pressed():
	
	# PRIORITÉ 1 : Si l'inventaire des gemmes est ouvert, on le ferme
	if inventaire_equi and inventaire_equi.visible:
		print("Retour : Fermeture de l'inventaire gemmes.")
		inventaire_equi.hide()
		
		# On ferme aussi le panel d'info s'il était par dessus
		# (Suppose que info_panel est partagé ou dans l'inventaire, mais par sécurité :)
		var info_gemme = inventaire_equi.get_node_or_null("GemInfoPanel")
		if info_gemme: info_gemme.hide()
		
		return # ON S'ARRÊTE LÀ, on ne change pas de scène

	# PRIORITÉ 2 : Si la liste des marteaux est ouverte, on la ferme
	if hammer_list.visible:
		print("Retour : Fermeture liste marteaux.")
		hammer_list.hide()
		info_panel.hide()
		return

	# PRIORITÉ 3 : Si rien n'est ouvert, on retourne au menu
	print("Retour : Chargement du menu principal...")
	get_tree().change_scene_to_file("res://scenes/main_game/menu.tscn")