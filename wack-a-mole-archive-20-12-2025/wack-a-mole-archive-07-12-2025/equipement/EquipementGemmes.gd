extends Control

# --- RÉFÉRENCES ---
@export var slot_1: TextureButton
@export var slot_2: TextureButton
@export var slot_3: TextureButton

@export var gem_collection_source: Control
@export var inventaire_ui: Control 

func _ready():
	add_to_group("ecran_equipement")
	
	print("\n 🔥 [INIT] EQUIPEMENT GEMMES (VERSION FINAL) 🔥")

	# Sécurité lien Collection
	if gem_collection_source == null:
		gem_collection_source = find_child("GemCollection", true, false)

	if slot_1: slot_1.pressed.connect(_on_slot_click.bind(0))
	if slot_2: slot_2.pressed.connect(_on_slot_click.bind(1))
	if slot_3: slot_3.pressed.connect(_on_slot_click.bind(2))
	
	call_deferred("mettre_a_jour")

func _on_slot_click(index_slot):
	print("🖱️ Clic sur le Slot d'équipement n°", index_slot + 1)
	if inventaire_ui:
		if inventaire_ui.has_method("ouvrir_pour_choisir_gemme"):
			inventaire_ui.ouvrir_pour_choisir_gemme(index_slot)
		elif inventaire_ui.has_method("show"):
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
			
			var bouton_original = trouver_bouton_bulldozer(la_data)
			
			if bouton_original:
				var clone = bouton_original.duplicate()
				clone.name = "VisuelGemme"
				slot.add_child(clone)
				clone.data = la_data
				
				# Mise en page du clone
				clone.set_anchors_preset(Control.PRESET_TOP_LEFT)
				clone.position = Vector2.ZERO
				clone.rotation = 0
				
				# Gestion taille
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
				# J'AI CHANGÉ LE MESSAGE D'ERREUR ICI POUR QU'ON SOIT SÛR
				print("❌ [V2] ECHEC VISUEL : ", la_data.nom)
				print("   > Je cherchais : ", la_data.element, " (Rareté ", int(la_data.rarete), ")")

# --- LE MOTEUR DE RECHERCHE CORRIGÉ ---
func trouver_bouton_bulldozer(data_cible):
	var elem_brut = data_cible.element.to_lower()
	
	# FIX : On convertit en INT pour chercher "5" et pas "5.0"
	var rarete_str = str(int(data_cible.rarete))
	
	# FIX : Liste complète des synonymes Froid/Glace
	var mots_cles = []
	if "lumière" in elem_brut or "lumiere" in elem_brut or "paladin" in elem_brut: mots_cles = ["lumiere", "paladin", "light"]
	elif "glace" in elem_brut or "froid" in elem_brut or "frost" in elem_brut or "ice" in elem_brut: 
		mots_cles = ["froid", "glace", "frost", "ice"]
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
		
		# On cherche le chiffre ("5")
		if rarete_str in n:
			# On cherche le mot ("froid")
			for mot in mots_cles:
				if mot in n:
					return enfant
	return null

func recup_recursif(parent, liste):
	if parent == null: return
	for enfant in parent.get_children():
		liste.append(enfant)
		if enfant.get_child_count() > 0: recup_recursif(enfant, liste)