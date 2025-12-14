extends Control

# --- RÉFÉRENCES ---
@export var slot_1: TextureButton
@export var slot_2: TextureButton
@export var slot_3: TextureButton

@export var gem_collection_source: Control
@export var inventaire_ui: Control 

func _ready():
	add_to_group("ecran_equipement")
	if slot_1: slot_1.pressed.connect(_on_slot_click.bind(0))
	if slot_2: slot_2.pressed.connect(_on_slot_click.bind(1))
	if slot_3: slot_3.pressed.connect(_on_slot_click.bind(2))
	call_deferred("mettre_a_jour")

func _on_slot_click(index_slot):
	print("🖱️ Clic sur le Slot d'équipement n°", index_slot + 1)
	if inventaire_ui and inventaire_ui.has_method("ouvrir_pour_choisir_gemme"):
		inventaire_ui.ouvrir_pour_choisir_gemme(index_slot)
	else:
		printerr("ERREUR : L'inventaire n'est pas assigné !")

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
				
				# 1. Reset Position
				clone.set_anchors_preset(Control.PRESET_TOP_LEFT)
				clone.position = Vector2.ZERO
				clone.rotation = 0
				clone.pivot_offset = Vector2.ZERO
				
				# 2. Calcul des tailles
				var taille_org = clone.size
				if taille_org.x <= 1: taille_org = clone.custom_minimum_size
				if taille_org.x <= 1: taille_org = Vector2(300, 300)
				
				var taille_slot = slot.size
				if taille_slot.x <= 1: taille_slot = slot.custom_minimum_size
				if taille_slot.x <= 1: taille_slot = Vector2(100, 100)
				
				# 3. RATIO (ZOOM)
				var ratio_x = taille_slot.x / taille_org.x
				var ratio_y = taille_slot.y / taille_org.y
				
				# --- MODIFICATION ICI ---
				# 0.95 = La gemme fera 70% de la taille du slot.
				# Cela laisse de la place autour pour voir le cadre du slot.
				var ratio = min(ratio_x, ratio_y) * 0.94 
				# ------------------------
				
				clone.scale = Vector2(ratio, ratio)
				
				# 4. Centrage (Le calcul s'adapte automatiquement à la nouvelle taille)
				var taille_visuelle = taille_org * ratio
				var espace_vide = taille_slot - taille_visuelle
				clone.position = espace_vide / 2
				
				# 5. Interaction
				clone.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
				if clone.has_method("update_visuals"):
					clone.update_visuals()
			else:
				print("Pas trouvé de visuel pour : ", la_data.nom)

# --- OUTILS ---
func trouver_bouton_bulldozer(data_cible):
	var element = nettoyer_nom(data_cible.element)
	var rarete = str(data_cible.rarete)
	var liste = []
	recup_recursif(gem_collection_source, liste)
	for enfant in liste:
		var n = enfant.name.to_lower()
		if element in n and rarete in n: return enfant
	return null

func recup_recursif(parent, liste):
	for enfant in parent.get_children():
		liste.append(enfant)
		if enfant.get_child_count() > 0: recup_recursif(enfant, liste)

func nettoyer_nom(nom):
	var n = nom.to_lower()
	if "végétale" in n or "vegetale" in n: return "plante"
	if "paladin" in n or "lumière" in n: return "lumiere"
	if "glace" in n: return "frost"
	return n