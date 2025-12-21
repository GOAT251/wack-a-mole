extends Control

# --- RÉFÉRENCES ---
@export var slot_1: TextureButton
@export var slot_2: TextureButton
@export var slot_3: TextureButton

@export var gem_collection_source: Control
@export var inventaire_ui: Control 

func _ready():
	add_to_group("ecran_equipement")
	
	# Sécurité lien Collection
	if gem_collection_source == null:
		gem_collection_source = find_child("GemCollection", true, false)

	if slot_1: slot_1.pressed.connect(_on_slot_click.bind(0))
	if slot_2: slot_2.pressed.connect(_on_slot_click.bind(1))
	if slot_3: slot_3.pressed.connect(_on_slot_click.bind(2))
	
	call_deferred("mettre_a_jour")

func _on_slot_click(index_slot):
	print("🖱️ Clic sur le Slot d'équipement n°", index_slot + 1)
	if inventaire_ui and inventaire_ui.has_method("ouvrir_pour_choisir_gemme"):
		inventaire_ui.ouvrir_pour_choisir_gemme(index_slot)
	
	# Fallback si l'inventaire a l'ancienne méthode
	elif inventaire_ui and inventaire_ui.has_method("show"):
		inventaire_ui.show()
		inventaire_ui.move_to_front()
		if "slot_cible_index" in inventaire_ui:
			inventaire_ui.slot_cible_index = index_slot
		if inventaire_ui.has_method("mettre_a_jour_affichage"):
			inventaire_ui.mettre_a_jour_affichage()

func rafraichir_visuel():
	mettre_a_jour()

func mettre_a_jour():
	var equipement = [null, null, null]
	if has_node("/root/PlayerData"):
		equipement = get_node("/root/PlayerData").gemmes_equipees
	
	var les_slots = [slot_1, slot_2, slot_3]
	
	for i in range(les_slots.size()):
		var slot = les_slots[i]
		if slot == null: continue
		
		# Nettoyage
		if slot.has_node("VisuelGemme"):
			slot.get_node("VisuelGemme").queue_free()
		
		# Remplissage
		if i < equipement.size() and equipement[i] != null:
			var la_data = equipement[i]
			
			# APPEL DE LA FONCTION DE RECHERCHE CORRIGÉE
			var bouton_original = trouver_bouton_bulldozer(la_data)
			
			if bouton_original:
				var clone = bouton_original.duplicate()
				clone.name = "VisuelGemme"
				slot.add_child(clone)
				clone.data = la_data
				
				# Mise en page du clone (Ton code original)
				clone.set_anchors_preset(Control.PRESET_TOP_LEFT)
				clone.position = Vector2.ZERO
				clone.rotation = 0
				clone.pivot_offset = Vector2.ZERO
				
				var taille_org = clone.size
				if taille_org.x <= 1: taille_org = Vector2(300, 300)
				
				var taille_slot = slot.size
				if taille_slot.x <= 1: taille_slot = Vector2(100, 100)
				
				var ratio_x = taille_slot.x / taille_org.x
				var ratio_y = taille_slot.y / taille_org.y
				var ratio = min(ratio_x, ratio_y) * 0.94 
				
				clone.scale = Vector2(ratio, ratio)
				var taille_visuelle = taille_org * ratio
				var espace_vide = taille_slot - taille_visuelle
				clone.position = espace_vide / 2
				
				clone.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
				if clone.has_method("update_visuals"):
					clone.update_visuals()
			else:
				# C'EST CETTE LIGNE QUE TU VOYAIS DANS TES LOGS
				print("❌ [EquipementGemmes.gd] Pas trouvé de visuel pour : ", la_data.nom)

# --- OUTILS CORRIGÉS (C'est ici que ça se joue) ---

func trouver_bouton_bulldozer(data_cible):
	var elem_brut = data_cible.element.to_lower()
	
	# FIX 1 : On force le chiffre ENTIER (4.0 -> "4")
	var rarete_str = str(int(data_cible.rarete))
	
	# FIX 2 : Le vrai Lexique complet
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
		
		# On cherche la rareté ("4") ET un des mots ("Froid")
		if rarete_str in n:
			for mot in mots_cles:
				if mot in n:
					return enfant
	return null

func recup_recursif(parent, liste):
	# FIX 3 : Anti-crash si parent est vide
	if parent == null: return
	
	for enfant in parent.get_children():
		liste.append(enfant)
		if enfant.get_child_count() > 0: recup_recursif(enfant, liste)