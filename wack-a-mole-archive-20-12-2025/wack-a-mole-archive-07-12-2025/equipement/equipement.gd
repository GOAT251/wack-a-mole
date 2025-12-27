extends Control

# =============================================================
# 1. REFERENCES GEMMES (A REMPLIR DANS L'INSPECTEUR)
# =============================================================
@export_group("Configuration Gemmes")
@export var slot_1: TextureButton
@export var slot_2: TextureButton
@export var slot_3: TextureButton
@export var gem_collection_source: Control
@export var inventaire_ui: Control 

# =============================================================
# 2. REFERENCES AUTO-DETECTEES (SCENE)
# =============================================================
@onready var hammer_list = $Hammer_PanelEQUI
@onready var bouton_marteau = $BoutonMarteau
@onready var icon_display = $BoutonMarteau/IconDisplay
@onready var bouton_retour = $BoutonRetour 
@onready var info_panel = $ItemInfoPanel # Le panel d'info général

# --- NOUVEAU : LE FOND LUXE ---
# Assure-toi que ce noeud existe bien dans ta scène Equipement
@onready var fond_luxe = $FondLuxeAnime 

# Images Marteau
@export_group("Visuels Marteau")
@export var fond_neutre: Texture2D 
var fond_socle_original: Texture2D 

func _ready():
	print("\n 🔥 [INIT] EQUIPEMENT COMPLET (GEMMES + MARTEAUX + LUXE) 🔥")
	add_to_group("ecran_equipement")

	# --- INIT MARTEAUX & UI ---
	if info_panel: info_panel.hide()
	if hammer_list: hammer_list.hide()
	if inventaire_ui: inventaire_ui.hide()
	
	# Initialisation du Fond Luxe (Caché au début)
	if fond_luxe:
		fond_luxe.hide()
		# Optionnel : Si c'est une vidéo, on peut la mettre en pause
		if fond_luxe.has_method("stop"): fond_luxe.stop()
	else:
		print("⚠️ Attention : Noeud 'FondLuxeAnime' introuvable dans la scène.")
	
	if bouton_marteau:
		fond_socle_original = bouton_marteau.texture_normal
		bouton_marteau.pressed.connect(_on_bouton_marteau_pressed)

	if bouton_retour:
		bouton_retour.pressed.connect(_on_bouton_retour_pressed)

	# Connexion des boutons marteaux
	var buttons = get_tree().get_nodes_in_group("smart_buttons")
	for btn in buttons:
		if not btn.item_clicked.is_connected(_on_marteau_item_clicked):
			btn.item_clicked.connect(_on_marteau_item_clicked)

	# --- INIT GEMMES ---
	if gem_collection_source == null:
		gem_collection_source = find_child("GemCollection", true, false)

	if slot_1: slot_1.pressed.connect(_on_slot_click.bind(0))
	if slot_2: slot_2.pressed.connect(_on_slot_click.bind(1))
	if slot_3: slot_3.pressed.connect(_on_slot_click.bind(2))
	
	# Mise à jour globale
	update_hammer_visuals()
	call_deferred("mettre_a_jour_gemmes")

func _process(_delta):
	update_hammer_visuals()

# =============================================================
# A. LOGIQUE MARTEAUX & RETOUR
# =============================================================

func update_hammer_visuals():
	if PlayerData.equipped_hammer:
		if fond_neutre: bouton_marteau.texture_normal = fond_neutre
		if icon_display: 
			icon_display.show()
			icon_display.texture = PlayerData.equipped_hammer.icon
	else:
		if fond_socle_original: bouton_marteau.texture_normal = fond_socle_original
		if icon_display: icon_display.hide()

func _on_bouton_marteau_pressed():
	# Si l'inventaire gemme est ouvert, on le ferme (et le fond luxe aussi)
	fermer_inventaire_gemmes()
	
	# Bascule du panneau marteau
	if hammer_list.visible:
		hammer_list.hide()
		info_panel.hide()
	else:
		hammer_list.show()
		hammer_list.move_to_front()

func _on_marteau_item_clicked(data):
	info_panel.show_with_data(data)
	info_panel.move_to_front()

func _on_bouton_retour_pressed():
	# 1. Si Inventaire Gemmes ouvert -> Fermer
	if inventaire_ui and inventaire_ui.visible:
		fermer_inventaire_gemmes()
		return

	# 2. Si Liste Marteaux ouverte -> Fermer
	if hammer_list.visible:
		hammer_list.hide()
		info_panel.hide()
		return

	# 3. Sinon -> Menu Principal
	print("Retour Menu...")
	get_tree().change_scene_to_file("res://scenes/main_game/menu.tscn")

# =============================================================
# B. LOGIQUE GEMMES + FOND LUXE
# =============================================================

func _on_slot_click(index_slot):
	print("🖱️ Clic sur le Slot GEMME n°", index_slot + 1)
	
	# On ferme les marteaux si ouverts
	if hammer_list.visible: hammer_list.hide()
	if info_panel.visible: info_panel.hide()

	if inventaire_ui:
		# --- ACTIVATION DU FOND LUXE ---
		if fond_luxe:
			fond_luxe.show()
			fond_luxe.move_to_front() # Juste derrière l'inventaire
			# Si c'est une vidéo, on lance la lecture
			if fond_luxe.has_method("play"): fond_luxe.play()
		
		# Affichage de l'inventaire
		if inventaire_ui.has_method("ouvrir_pour_choisir_gemme"):
			inventaire_ui.ouvrir_pour_choisir_gemme(index_slot)
		elif inventaire_ui.has_method("show"):
			inventaire_ui.show()
			inventaire_ui.move_to_front()
			if "slot_cible_index" in inventaire_ui:
				inventaire_ui.slot_cible_index = index_slot
			if inventaire_ui.has_method("mettre_a_jour_affichage"):
				inventaire_ui.mettre_a_jour_affichage()

func fermer_inventaire_gemmes():
	if inventaire_ui:
		inventaire_ui.hide()
		# On cache le panel info gemme
		var info_gem = inventaire_ui.get_node_or_null("GemInfoPanel")
		if info_gem: info_gem.hide()
		
		# --- DESACTIVATION DU FOND LUXE ---
		if fond_luxe:
			fond_luxe.hide()
			if fond_luxe.has_method("stop"): fond_luxe.stop()
		
		mettre_a_jour_gemmes()

func mettre_a_jour_gemmes():
	var equipement = [null, null, null]
	if has_node("/root/PlayerData"):
		equipement = get_node("/root/PlayerData").gemmes_equipees
	
	var les_slots = [slot_1, slot_2, slot_3]
	
	for i in range(les_slots.size()):
		var slot = les_slots[i]
		if slot == null: continue
		
		if slot.has_node("VisuelGemme"):
			slot.get_node("VisuelGemme").queue_free()
		
		if i < equipement.size() and equipement[i] != null:
			var la_data = equipement[i]
			var bouton_original = trouver_bouton_bulldozer(la_data)
			
			if bouton_original:
				var clone = bouton_original.duplicate()
				clone.name = "VisuelGemme"
				slot.add_child(clone)
				clone.data = la_data
				
				clone.set_anchors_preset(Control.PRESET_TOP_LEFT)
				clone.position = Vector2.ZERO
				clone.rotation = 0
				
				var taille_org = clone.size
				if taille_org.x <= 1: taille_org = Vector2(300, 300)
				var taille_slot = slot.size
				if taille_slot.x <= 1: taille_slot = Vector2(100, 100)
				
				var ratio = min(taille_slot.x / taille_org.x, taille_slot.y / taille_org.y) * 0.94 
				clone.scale = Vector2(ratio, ratio)
				clone.position = (taille_slot - (taille_org * ratio)) / 2
				clone.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
				if clone.has_method("update_visuals"):
					clone.update_visuals()
			else:
				print("❌ ECHEC VISUEL : ", la_data.nom)

# --- OUTILS ---
func trouver_bouton_bulldozer(data_cible):
	var elem_brut = data_cible.element.to_lower()
	var rarete_str = str(int(data_cible.rarete)) 
	
	var mots_cles = []
	if "lumière" in elem_brut or "lumiere" in elem_brut or "paladin" in elem_brut: mots_cles = ["lumiere", "paladin", "light"]
	elif "glace" in elem_brut or "froid" in elem_brut or "frost" in elem_brut or "ice" in elem_brut: mots_cles = ["froid", "glace", "frost", "ice"]
	elif "plante" in elem_brut or "végé" in elem_brut or "plant" in elem_brut: mots_cles = ["plante", "vegetal", "plant"]
	elif "foudre" in elem_brut or "electr" in elem_brut: mots_cles = ["foudre", "electr"]
	elif "feu" in elem_brut or "fire" in elem_brut: mots_cles = ["feu", "fire"]
	elif "ténèbre" in elem_brut or "tenebre" in elem_brut or "sombre" in elem_brut: mots_cles = ["sombre", "tenebre", "dark"]
	else: mots_cles = [elem_brut]

	var liste = []
	if gem_collection_source:
		recup_recursif(gem_collection_source, liste)
	
	for enfant in liste:
		var n = enfant.name.to_lower()
		if rarete_str in n:
			for mot in mots_cles:
				if mot in n:
					return enfant
	return null

func recup_recursif(parent, liste):
	if parent == null: return
	for enfant in parent.get_children():
		liste.append(enfant)
		if enfant.get_child_count() > 0: recup_recursif(enfant, liste)