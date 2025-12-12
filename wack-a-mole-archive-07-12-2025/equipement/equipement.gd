extends Control

# --- RÉFÉRENCES EXISTANTES ---
@onready var info_panel = $ItemInfoPanel
@onready var hammer_list = $Hammer_PanelEQUI
@onready var bouton_marteau = $BoutonMarteau
@onready var icon_display = $BoutonMarteau/IconDisplay

# --- NOUVEAU : Référence au bouton Retour vers le Menu ---
# Vérifiez que le bouton s'appelle bien "BoutonRetour" dans la scène !
@onready var bouton_retour = $BoutonRetour 

# --- IMAGES ---
@export var fond_neutre: Texture2D 
var fond_socle_original: Texture2D 

func _ready():
	info_panel.hide()
	hammer_list.hide()
	
	# Gestion des images du bouton marteau
	if bouton_marteau:
		fond_socle_original = bouton_marteau.texture_normal
		bouton_marteau.pressed.connect(_on_bouton_marteau_pressed)

	# --- NOUVEAU : Connexion du bouton Retour ---
	if bouton_retour:
		bouton_retour.pressed.connect(_on_bouton_retour_pressed)
	else:
		print("ERREUR : 'BoutonRetour' introuvable à la racine de la scène Equipement.")

	# Connexion des boutons items
	var buttons = get_tree().get_nodes_in_group("smart_buttons")
	for btn in buttons:
		if not btn.item_clicked.is_connected(_on_item_clicked):
			btn.item_clicked.connect(_on_item_clicked)
	
	update_button_visuals()

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

# --- NOUVEAU : La fonction pour retourner au menu ---
func _on_bouton_retour_pressed():
	print("Retour au menu principal...")
	get_tree().change_scene_to_file("res://scenes/main_game/menu.tscn")