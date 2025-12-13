extends Control

# --- RÉFÉRENCES ---
# Glisse tes 3 boutons Slots ici
@export var slot_1: TextureButton
@export var slot_2: TextureButton
@export var slot_3: TextureButton

# Glisse ta GemCollection ici (La banque de modèles)
@export var gem_collection_source: Control

# Glisse ton panel "InventairePanel" (ou GemInventaire) ici
# C'est pour pouvoir l'ouvrir quand on clique sur un slot
@export var inventaire_ui: Control 

func _ready():
	# 1. On s'inscrit au groupe pour recevoir l'ordre de rafraichir depuis l'inventaire
	add_to_group("ecran_equipement")
	
	# 2. On connecte les clics des slots
	# On utilise .bind(x) pour savoir quel slot a été cliqué (0, 1 ou 2)
	if slot_1: slot_1.pressed.connect(_on_slot_click.bind(0))
	if slot_2: slot_2.pressed.connect(_on_slot_click.bind(1))
	if slot_3: slot_3.pressed.connect(_on_slot_click.bind(2))
	
	# 3. On lance l'affichage initial
	call_deferred("mettre_a_jour")

# Fonction appelée quand on clique sur un Slot vide ou plein
func _on_slot_click(index_slot):
	print("🖱️ Clic sur le Slot d'équipement n°", index_slot + 1)
	
	if inventaire_ui and inventaire_ui.has_method("ouvrir_pour_choisir_gemme"):
		# On ouvre l'inventaire en mode "Sélection pour le slot X"
		inventaire_ui.ouvrir_pour_choisir_gemme(index_slot)
	else:
		printerr("ERREUR : L'inventaire n'est pas assigné dans l'inspecteur du GestionnaireGemmes !")

# Fonction appelée par le groupe "ecran_equipement"
func rafraichir_visuel():
	print("🔄 Rafraîchissement visuel de l'équipement...")
	mettre_a_jour()

func mettre_a_jour():
	# 1. Récupération des données
	var equipement = [null, null, null]
	if has_node("/root/PlayerData"):
		equipement = get_node("/root/PlayerData").gemmes_equipees
	
	var les_slots = [slot_1, slot_2, slot_3]
	
	for i in range(les_slots.size()):
		var slot = les_slots[i]
		if slot == null: continue
		
		# A. NETTOYAGE (On vire l'ancien visuel)
		if slot.has_node("VisuelGemme"):
			slot.get_node("VisuelGemme").queue_free()
		
		# B. REMPLISSAGE
		if i < equipement.size() and equipement[i] != null:
			var la_data = equipement[i]
			
			# On cherche le modèle dans la collection
			var bouton_original = trouver_bouton_bulldozer(la_data)
			
			if bouton_original:
				# --- CLONAGE (Même méthode que l'Inventaire) ---
				var clone = bouton_original.duplicate()
				clone.name = "VisuelGemme"
				slot.add_child(clone)
				clone.data = la_data # Pour l'image et le cadre
				
				# 1. Reset Position (Haut Gauche)
				clone.set_anchors_preset(Control.PRESET_TOP_LEFT)
				clone.position = Vector2.ZERO
				clone.rotation = 0
				clone.pivot_offset = Vector2.ZERO
				
				# 2. Calcul du Scale (Zoom)
				# Taille originale du bouton
				var taille_org = clone.size
				if taille_org.x <= 1: taille_org = clone.custom_minimum_size
				if taille_org.x <= 1: taille_org = Vector2(300, 300)
				
				# Taille du slot
				var taille_slot = slot.size
				if taille_slot.x <= 1: taille_slot = Vector2(100, 100) # Sécurité
				
				# Ratio
				var ratio_x = taille_slot.x / taille_org.x
				var ratio_y = taille_slot.y / taille_org.y
				var ratio = min(ratio_x, ratio_y)
				
				# Application du Zoom
				clone.scale = Vector2(ratio, ratio)
				
				# 3. Interaction
				# IMPORTANT : On désactive la souris sur le visuel pour que le Slot en dessous capte le clic
				clone.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
				# Update Visuel
				if clone.has_method("update_visuals"):
					clone.update_visuals()
			else:
				print("Pas trouvé de visuel pour : ", la_data.nom)

# --- OUTILS DE RECHERCHE ---
func trouver_bouton_bulldozer(data_cible):
	var element = nettoyer_nom(data_cible.element)
	var rarete = str(data_cible.rarete)
	var liste = []
	recup_recursif(gem_collection_source, liste)
	
	for enfant in liste:
		var n = enfant.name.to_lower()
		if element in n and rarete in n:
			return enfant
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