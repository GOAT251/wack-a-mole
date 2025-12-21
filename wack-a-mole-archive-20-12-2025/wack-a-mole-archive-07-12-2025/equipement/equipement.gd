extends Control

# --- RÉFÉRENCES INSPECTEUR (A REMPLIR !) ---
@export var slots_equipement: Array[TextureButton] # Tes 3 gros socles
@export var gem_collection_source: Control         # Ta banque d'images
@export var texture_socle_vide: Texture2D          # Image du trou vide

# --- RÉFÉRENCES EXISTANTES ---
@onready var info_panel = $ItemInfoPanel
@onready var hammer_list = $Hammer_PanelEQUI
@onready var bouton_marteau = $BoutonMarteau
@onready var icon_display = $BoutonMarteau/IconDisplay
@onready var bouton_retour = $BoutonRetour 
@onready var inventaire_equi = $GemInventaireEQUI

# Images Marteau
@export var fond_neutre: Texture2D 
var fond_socle_original: Texture2D 

func _ready():
	print("\n--- DÉMARRAGE SCÈNE EQUIPEMENT (MODE COMPLET) ---")
	
	# Initialisation
	if info_panel: info_panel.hide()
	if hammer_list: hammer_list.hide()
	if inventaire_equi: inventaire_equi.hide()
	
	if bouton_marteau:
		fond_socle_original = bouton_marteau.texture_normal
		bouton_marteau.pressed.connect(_on_bouton_marteau_pressed)

	if bouton_retour:
		bouton_retour.pressed.connect(_on_bouton_retour_pressed)

	# Connexion des boutons marteaux
	var buttons = get_tree().get_nodes_in_group("smart_buttons")
	for btn in buttons:
		if not btn.item_clicked.is_connected(_on_item_clicked):
			btn.item_clicked.connect(_on_item_clicked)
	
	# Connexion des 3 Socles Gemmes
	for i in range(slots_equipement.size()):
		var slot = slots_equipement[i]
		if slot and not slot.pressed.is_connected(_on_slot_equipement_pressed):
			slot.pressed.connect(_on_slot_equipement_pressed.bind(i))

	# MISE A JOUR VISUELLE IMMEDIATE
	update_button_visuals()       # Marteaux
	mettre_a_jour_socles()        # Gemmes (Le lexique est utilisé ici)

func _process(_delta):
	update_button_visuals()

# =============================================================
# GESTION DES 3 SOCLES GEMMES (AVEC LEXIQUE INTEGRÉ)
# =============================================================
func mettre_a_jour_socles():
	print("♻️ Mise à jour des socles...")
	var gemmes_equipees = []
	if has_node("/root/PlayerData"):
		gemmes_equipees = get_node("/root/PlayerData").gemmes_equipees

	for i in range(slots_equipement.size()):
		var slot = slots_equipement[i]
		var icon_interne = slot.get_node_or_null("Icon") or slot.get_node_or_null("icon")

		# Reset (Image vide)
		if texture_socle_vide: slot.texture_normal = texture_socle_vide
		if icon_interne: icon_interne.texture = null

		# Remplissage
		if i < gemmes_equipees.size() and gemmes_equipees[i] != null:
			var data = gemmes_equipees[i]
			
			# APPEL A LA FONCTION QUI CONTIENT LE LEXIQUE
			var modele = trouver_modele_visuel(data)
			
			if modele:
				slot.texture_normal = modele.texture_normal
				if icon_interne: icon_interne.texture = data.icon

# --- LE LEXIQUE EST ICI (C'est ça que tu cherchais) ---
func trouver_modele_visuel(data):
	var elem_brut = data.element.to_lower()
	var rarete_str = str(int(data.rarete)) # Force "4" au lieu de "4.0"
	
	var mots_cles = []
	
	# [LEXIQUE] DEFINITION DES SYNONYMES
	if "lumière" in elem_brut or "lumiere" in elem_brut or "paladin" in elem_brut:
		mots_cles = ["lumiere", "paladin", "light"]
	elif "glace" in elem_brut or "froid" in elem_brut or "frost" in elem_brut or "ice" in elem_brut:
		mots_cles = ["Froid", "glace", "frost", "ice"]
	elif "plante" in elem_brut or "végé" in elem_brut or "plant" in elem_brut:
		mots_cles = ["plante", "vegetal", "plant"]
	elif "foudre" in elem_brut or "electr" in elem_brut:
		mots_cles = ["foudre", "electr"]
	elif "feu" in elem_brut or "fire" in elem_brut:
		mots_cles = ["feu", "fire"]
	elif "ténèbre" in elem_brut or "tenebre" in elem_brut or "sombre" in elem_brut:
		mots_cles = ["sombre", "tenebre", "dark"]
	else:
		mots_cles = [elem_brut]

	# RECHERCHE DANS LA COLLECTION
	if not gem_collection_source: return null
	
	var tous = []
	recup_recursive(gem_collection_source, tous)
	
	for node in tous:
		var nom = node.name.to_lower()
		if rarete_str in nom:
			for mot in mots_cles:
				if mot in nom:
					return node
	return null

func recup_recursive(p, l):
	if p == null: return
	for c in p.get_children():
		l.append(c)
		if c.get_child_count() > 0: recup_recursive(c, l)

# =============================================================
# INTERACTIONS ET MARTEAUX
# =============================================================
func _on_slot_equipement_pressed(index):
	if inventaire_equi:
		inventaire_equi.show()
		inventaire_equi.move_to_front()
		# Si tu as besoin de passer l'index cible à l'inventaire :
		if "slot_cible_index" in inventaire_equi:
			inventaire_equi.slot_cible_index = index
		if inventaire_equi.has_method("mettre_a_jour_affichage"):
			inventaire_equi.mettre_a_jour_affichage()

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

func _on_bouton_retour_pressed():
	# Priorité 1 : Fermer Inventaire
	if inventaire_equi and inventaire_equi.visible:
		inventaire_equi.hide()
		var info = inventaire_equi.get_node_or_null("GemInfoPanel")
		if info: info.hide()
		mettre_a_jour_socles() # Refresh visuel en sortant
		return

	# Priorité 2 : Fermer Marteaux
	if hammer_list.visible:
		hammer_list.hide(); info_panel.hide()
		return

	# Priorité 3 : Quitter
	get_tree().change_scene_to_file("res://scenes/main_game/menu.tscn")