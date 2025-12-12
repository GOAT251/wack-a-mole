extends Control

# --- RÉFÉRENCES (A REMPLIR DANS L'INSPECTEUR) ---
# 1. Glisse ton "VBoxContainer" ici (celui qui contient GemmeListFeu, etc.)
@export var container_principal: Control 

# 2. Ta collection source (cachée)
@export var gem_collection_source: Control 

# 3. Ton panel d'info (Le même que dans Tirage)
@export var gem_info_panel: Control 

# Mémoire des slots
var tous_les_slots: Array = []

func _ready():
	# On cache l'inventaire au démarrage si nécessaire
	# hide() 
	
	# On récupère les slots une bonne fois pour toutes au lancement
	call_deferred("recuperer_les_slots")

func recuperer_les_slots():
	tous_les_slots.clear()
	
	# ANALYSE DE TA STRUCTURE (Scroll -> VBox -> Lignes -> Boutons)
	if container_principal:
		# On parcourt tes lignes (GemmeListFeu, GemmeListFeu2...)
		for ligne in container_principal.get_children():
			if ligne.get_child_count() > 0:
				for bouton in ligne.get_children():
					# Si c'est un bouton, c'est un slot !
					if bouton is BaseButton: 
						tous_les_slots.append(bouton)
						# Le slot doit capter la souris
						bouton.mouse_filter = Control.MOUSE_FILTER_STOP
	
	print("✅ Inventaire prêt : ", tous_les_slots.size(), " slots détectés.")

# --- LA FONCTION D'AFFICHAGE ---
func mettre_a_jour_affichage():
	print("♻️ Mise à jour de l'inventaire...")
	
	# 1. On récupère les données du joueur
	var inventaire_data = []
	if has_node("/root/PlayerData"):
		inventaire_data = get_node("/root/PlayerData").inventaire_gemmes

	# 2. ON REMPLIT LES SLOTS
	for i in range(tous_les_slots.size()):
		var slot = tous_les_slots[i]
		
		# A. NETTOYAGE PRÉALABLE
		# On déconnecte le clic précédent pour éviter les bugs
		if slot.pressed.is_connected(_on_gemme_clicked):
			slot.pressed.disconnect(_on_gemme_clicked)
		
		# On récupère l'icône interne si elle existe (pour l'épée/coeur)
		var icon_interne = slot.get_node_or_null("Icon") 
		if not icon_interne: icon_interne = slot.get_node_or_null("icon")
		
		# Reset visuel par défaut (Slot vide)
		slot.disabled = true
		slot.modulate.a = 0.5
		slot.texture_normal = null
		if icon_interne: icon_interne.texture = null

		# B. REMPLISSAGE (Si on a une gemme)
		if i < inventaire_data.size():
			var data = inventaire_data[i]
			
			# 1. On active le bouton
			slot.disabled = false
			slot.modulate.a = 1.0
			
			# 2. LA CONNEXION (Style Tirage)
			# On lie le clic de ce slot à la data de la gemme
			slot.pressed.connect(_on_gemme_clicked.bind(data))
			
			# 3. VISUEL (On vole la texture de la collection)
			var modele = trouver_modele(data)
			if modele:
				slot.texture_normal = modele.texture_normal
				if icon_interne: icon_interne.texture = data.icon
			else:
				print("⚠️ Visuel manquant pour : ", data.nom)

# --- LE CLIC (Style Tirage) ---
func _on_gemme_clicked(data_gemme):
	print("👉 Clic Inventaire sur : ", data_gemme.nom)
	
	if gem_info_panel:
		# On envoie la data au panel
		gem_info_panel.afficher_infos(data_gemme)
		
		# On l'affiche
		gem_info_panel.show()
		gem_info_panel.move_to_front()
		
		# Si on peut s'équiper, on active le bouton
		if gem_info_panel.has_method("activer_mode_equipement"):
			gem_info_panel.activer_mode_equipement()
	else:
		printerr("🔴 ERREUR : GemInfoPanel non assigné !")

# --- MOTEUR DE RECHERCHE "TOUT TERRAIN" (CORRIGE LUMIERE/PALADIN) ---
func trouver_modele(data):
	var elem_brut = data.element.to_lower()
	var rarete_str = str(data.rarete) # Ex: "1", "2", "3"...
	
	# Liste des synonymes possibles pour chaque élément
	var mots_cles = []
	
	# LUMIÈRE / PALADIN (C'est souvent lui qui pose problème)
	if "lumière" in elem_brut or "lumiere" in elem_brut or "paladin" in elem_brut or "light" in elem_brut:
		mots_cles = ["lumiere", "paladin", "light", "sacre"]
		
	# PLANTE / NATURE
	elif "végé" in elem_brut or "vege" in elem_brut or "plant" in elem_brut or "natur" in elem_brut:
		mots_cles = ["plante", "vegetal", "plant", "nature"]
		
	# GLACE / FROID
	elif "glace" in elem_brut or "froid" in elem_brut or "frost" in elem_brut:
		mots_cles = ["froid", "glace", "frost", "ice"]
		
	# SOMBRE / TÉNÈBRES
	elif "ténèbre" in elem_brut or "tenebre" in elem_brut or "sombre" in elem_brut or "dark" in elem_brut:
		mots_cles = ["sombre", "tenebre", "dark", "shadow"]
		
	# FOUDRE
	elif "foudre" in elem_brut or "electr" in elem_brut:
		mots_cles = ["foudre", "electr", "lightning"]
		
	# FEU (Simple)
	elif "feu" in elem_brut or "fire" in elem_brut:
		mots_cles = ["feu", "fire"]
	
	else:
		# Par défaut on cherche le mot tel quel
		mots_cles = [elem_brut]

	# --- RECHERCHE DANS LA COLLECTION ---
	var tous = []
	recup_recursive(gem_collection_source, tous)
	
	for node in tous:
		var nom_bouton = node.name.to_lower()
		
		# 1. Vérification de la rareté (Le chiffre doit être dans le nom, ex: "Feu_2")
		if rarete_str in nom_bouton:
			# 2. Vérification de l'élément (On teste tous les synonymes)
			for mot in mots_cles:
				if mot in nom_bouton:
					return node # TROUVÉ !
	
	return null # Vraiment pas trouvé

func recup_recursive(p, l):
	for c in p.get_children():
		l.append(c)
		if c.get_child_count() > 0: recup_recursive(c, l)
