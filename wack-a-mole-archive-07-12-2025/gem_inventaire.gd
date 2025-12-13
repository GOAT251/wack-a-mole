extends Control

# --- RÉFÉRENCES ---
@export var container_principal: VBoxContainer 
@export var gem_collection_source: Control 
@onready var info_panel = $GemInfoPanel # Assure-toi que le panel est bien là !

# --- VARIABLES ---
var tous_les_slots: Array = []
var debug_fait = false

# --- NOUVEAU : LE MODE SÉLECTION ---
# -1 = Mode Normal (Pas de sélection)
# 0, 1, 2 = On cherche une gemme pour le Slot 0, 1 ou 2
var slot_cible_index: int = -1 

func _ready():
	call_deferred("initialiser_inventaire")
	
	# CONNEXION DU SIGNAL DU PANEL INFO
	if info_panel:
		# Quand on clique sur "ÉQUIPER" dans la fiche, ça déclenche cette fonction
		if not info_panel.demande_equipement.is_connected(_on_info_panel_demande_equipement):
			info_panel.demande_equipement.connect(_on_info_panel_demande_equipement)
	else:
		printerr("ERREUR : Pas de GemInfoPanel dans l'inventaire !")

# --- FONCTION APPELÉE PAR LES SLOTS D'ÉQUIPEMENT ---
func ouvrir_pour_choisir_gemme(index_slot):
	print("--- OUVERTURE INVENTAIRE (Mode Sélection Slot " + str(index_slot) + ") ---")
	slot_cible_index = index_slot
	
	# On s'assure que l'inventaire est visible et à jour
	self.show()
	self.move_to_front()
	mettre_a_jour_affichage()

func initialiser_inventaire():
	if gem_collection_source == null:
		printerr("ERREUR : Glisse 'GemCollection' dans l'inspecteur !")
		return
	
	tous_les_slots.clear()
	if container_principal:
		for ligne in container_principal.get_children():
			if ligne.get_child_count() > 0:
				for bouton in ligne.get_children():
					tous_les_slots.append(bouton)
	
	mettre_a_jour_affichage()

func mettre_a_jour_affichage():
	var inventaire = []
	if has_node("/root/PlayerData"):
		inventaire = get_node("/root/PlayerData").inventaire_gemmes

	for i in range(tous_les_slots.size()):
		var slot = tous_les_slots[i]
		
		# Nettoyage
		if slot.has_node("Clone"): slot.get_node("Clone").queue_free()
		
		slot.disabled = true
		slot.modulate.a = 0.5
		if "data" in slot: slot.data = null
		slot.texture_normal = null
		if slot.has_node("icon"): slot.get_node("icon").texture = null

		# --- REMPLISSAGE ---
		if i < inventaire.size():
			var la_data = inventaire[i]
			
			# 1. On active le slot
			slot.disabled = false
			slot.modulate.a = 1.0
			
			# 2. On injecte la data pour que le clic fonctionne
			if "data" in slot:
				slot.data = la_data
			
			# 3. GESTION DU CLIC (C'est ici qu'on ouvre le panel)
			if slot.is_connected("pressed", _on_slot_clicked):
				slot.disconnect("pressed", _on_slot_clicked)
			slot.pressed.connect(_on_slot_clicked.bind(la_data))
			
			# 4. VISUEL (Ta méthode Clone + Zoom)
			var bouton_original = trouver_bouton_bulldozer(la_data)
			if bouton_original:
				var clone = bouton_original.duplicate()
				clone.name = "Clone"
				slot.add_child(clone)
				clone.data = la_data 
				
				clone.set_anchors_preset(Control.PRESET_TOP_LEFT)
				clone.position = Vector2.ZERO
				clone.rotation = 0
				clone.pivot_offset = Vector2.ZERO
				
				var taille_originale = clone.size
				if taille_originale.x <= 1: taille_originale = clone.custom_minimum_size
				if taille_originale.x <= 1: taille_originale = Vector2(300, 300)
				
				var taille_slot = slot.size
				if taille_slot.x <= 1: taille_slot = Vector2(100, 100)
				
				var ratio_x = taille_slot.x / taille_originale.x
				var ratio_y = taille_slot.y / taille_originale.y
				var ratio = min(ratio_x, ratio_y)
				
				clone.scale = Vector2(ratio, ratio)
				clone.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
				if clone.has_method("update_visuals"):
					clone.update_visuals()

# --- GESTION DES CLICS ---

func _on_slot_clicked(data_gemme):
	if info_panel:
		# EST-CE QU'ON EST EN MODE SÉLECTION ?
		var mode_equipement = (slot_cible_index != -1)
		
		# On ouvre la fiche (avec ou sans le bouton Équiper selon le mode)
		info_panel.afficher_infos(data_gemme, mode_equipement)
		info_panel.show()
		info_panel.move_to_front()

# C'est ici que la magie opère quand on clique sur "EQUIPER"
func _on_info_panel_demande_equipement(data_gemme):
	if slot_cible_index != -1:
		print("✅ VALIDATION : Équipement de ", data_gemme.nom, " sur le slot ", slot_cible_index)
		
		# 1. Sauvegarde dans PlayerData
		if has_node("/root/PlayerData"):
			get_node("/root/PlayerData").equiper_gemme_dans_slot(slot_cible_index, data_gemme)
		
		# 2. Rafraîchissement visuel de l'écran d'équipement
		get_tree().call_group("ecran_equipement", "rafraichir_visuel")
		
		# 3. Fermeture de tout
		info_panel.hide()
		self.hide() # On ferme l'inventaire pour revenir à l'équipement
		
		# 4. Reset du mode
		slot_cible_index = -1

# --- OUTILS DE RECHERCHE ---
func trouver_bouton_bulldozer(data_cible):
	var element_nom = nettoyer_nom(data_cible.element)
	var rarete_str = str(data_cible.rarete)
	var tous_les_enfants = []
	recuperer_tout_le_monde_recursif(gem_collection_source, tous_les_enfants)
	for enfant in tous_les_enfants:
		var nom = enfant.name.to_lower()
		if element_nom in nom and rarete_str in nom:
			return enfant
	return null

func recuperer_tout_le_monde_recursif(parent, liste):
	for enfant in parent.get_children():
		liste.append(enfant)
		if enfant.get_child_count() > 0:
			recuperer_tout_le_monde_recursif(enfant, liste)

func nettoyer_nom(nom_brut: String) -> String:
	var n = nom_brut.to_lower()
	if "végétale" in n or "vegetale" in n: return "plante"
	if "paladin" in n or "lumière" in n or "lumiere" in n: return "lumiere"
	if "frost" in n or "glace" in n or "froid" in n: return "froid"
	return n