extends Control

@onready var resultat_panel = $ResultatTirage 
@onready var bouton_retour = $BoutonRetour

# --- REFERENCES AUX COLLECTIONS ---
@export var scene_carte_mystere: PackedScene 

# Glisse le noeud "HammerCollection" qui est dans ta scène ici !
@export var hammer_collection_ref: Control 

func _ready():
	randomize()
	if resultat_panel:
		resultat_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		resultat_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if bouton_retour:
		bouton_retour.pressed.connect(_on_bouton_retour_pressed)

func _on_bouton_retour_pressed():
	get_tree().change_scene_to_file("res://scenes/main_game/menu.tscn")

# CETTE FONCTION GÈRE TOUT (Gemmes ET Marteaux)
func generer_tirage_pour_coffre(coffre):
	
	# ============================================================
	# CAS 1 : C'EST UN COFFRE A MARTEAUX
	# ============================================================
	# On le reconnaît car il a la fonction spéciale et la variable nom_bouton_ref
	if coffre.has_method("piocher_marteau_hasard"):
		print("--- TIRAGE MARTEAUX DÉTECTÉ ---")
		_lancer_tirage_marteaux(coffre)
		return 

	# ============================================================
	# CAS 2 : C'EST UN COFFRE A GEMMES (Classique)
	# ============================================================
	print("--- TIRAGE GEMMES DÉTECTÉ ---")
	_lancer_tirage_gemmes(coffre)


# --- LOGIQUE MARTEAUX (Nouvelle version avec HammerCollection) ---
func _lancer_tirage_marteaux(coffre):
	if hammer_collection_ref == null:
		printerr("ERREUR : Tu as oublié de glisser 'HammerCollection' dans l'inspecteur de Tirage !")
		return

	# 1. On trouve le MODÈLE VISUEL (Le bouton Shard spécifique à ce coffre)
	# Le coffre contient le nom du bouton qu'il doit utiliser (ex: "BoutonFeu")
	var nom_modele = coffre.nom_bouton_ref
	var bouton_modele = hammer_collection_ref.find_child(nom_modele, true, false)
	
	if bouton_modele == null:
		printerr("ERREUR : Impossible de trouver le bouton nommé '", nom_modele, "' dans HammerCollection !")
		return

	var selection_finale = []
	
	for i in range(6):
		# 2. Le coffre choisit le marteau (Data)
		var data_marteau = coffre.piocher_marteau_hasard()
		
		if data_marteau:
			# Sauvegarde
			var qte = randi_range(5, 10)
			if has_node("/root/PlayerData"):
				get_node("/root/PlayerData").ajouter_shards(data_marteau.item_name, qte)
			
			# 3. VISUEL : On clone le bouton modèle de la collection
			var visuel_shard = bouton_modele.duplicate()
			
			# 4. ON APPLIQUE LA TEXTURE DU MARTEAU GAGNANT
			# On cherche le TextureRect "VisuelMarteau" à l'intérieur du clone
			var texture_marteau = visuel_shard.find_child("VisuelMarteau", true, false)
			if texture_marteau:
				texture_marteau.texture = data_marteau.icon
			else:
				# Si la hiérarchie est simple
				visuel_shard.texture_normal = data_marteau.icon
			
			# 5. EMBALLAGE MYSTERY CARD
			if scene_carte_mystere:
				var carte = scene_carte_mystere.instantiate()
				if carte.has_method("setup"):
					# On passe data_marteau pour la couleur du ? (Rareté)
					carte.setup(visuel_shard, data_marteau)
				selection_finale.append(carte)
			else:
				selection_finale.append(visuel_shard)

	if resultat_panel:
		resultat_panel.afficher_ces_boutons_la(selection_finale, coffre)


# --- LOGIQUE GEMMES (Ton ancien code inchangé) ---
func _lancer_tirage_gemmes(coffre):
	var pool_complet = get_tree().get_nodes_in_group("boutons_gemmes_pool")
	
	var sacs_par_rareté = { 1: [], 2: [], 3: [], 4: [], 5: [] }
	for bouton in pool_complet:
		if bouton.data and "rarete" in bouton.data:
			var r = int(bouton.data.rarete)
			if sacs_par_rareté.has(r): sacs_par_rareté[r].append(bouton)
	
	var selection_finale = []
	for i in range(6):
		var rareté_gagnée = lancer_les_des(coffre)
		var modele_bouton = piocher_gemme_robuste(sacs_par_rareté, rareté_gagnée, pool_complet)
		
		if modele_bouton and modele_bouton.data:
			var data_unique = modele_bouton.data.duplicate()
			if data_unique.has_method("generer_stats_uniques"):
				data_unique.generer_stats_uniques()
			
			if has_node("/root/PlayerData"):
				get_node("/root/PlayerData").ajouter_gemme_inventaire(data_unique)
			
			var bouton_visuel = modele_bouton.duplicate()
			bouton_visuel.data = data_unique 
			
			if scene_carte_mystere:
				var carte = scene_carte_mystere.instantiate()
				if carte.has_method("setup"):
					carte.setup(bouton_visuel, data_unique)
				selection_finale.append(carte)
			else:
				selection_finale.append(bouton_visuel)

	if resultat_panel:
		resultat_panel.afficher_ces_boutons_la(selection_finale, coffre)

# --- MATHS ---
func lancer_les_des(coffre) -> int:
	var roll = randf_range(0.0, 100.0)
	var s = 0.0
	s += coffre.chance_commune; if roll < s: return 1
	s += coffre.chance_rare; if roll < s: return 2
	s += coffre.chance_epique; if roll < s: return 3
	s += coffre.chance_legendaire; if roll < s: return 4
	return 5

func piocher_gemme_robuste(sacs, rareté_cible, pool_de_secours):
	var sac_cible = sacs[rareté_cible]
	if sac_cible.size() > 0: return sac_cible.pick_random()
	if rareté_cible > 1: return piocher_gemme_robuste(sacs, rareté_cible - 1, pool_de_secours)
	if pool_de_secours.size() > 0: return pool_de_secours.pick_random()
	return null
