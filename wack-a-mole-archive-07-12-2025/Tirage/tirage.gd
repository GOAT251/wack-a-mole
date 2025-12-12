extends Control

@onready var resultat_panel = $ResultatTirage 
@onready var bouton_retour = $BoutonRetour

# --- NOUVEAU : La scène de la carte mystère ---
# Glisse "MysteryCard.tscn" ici dans l'inspecteur !
@export var scene_carte_mystere: PackedScene 

func _ready():
	randomize()
	
	# Gestion du panel résultat
	if resultat_panel:
		resultat_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		resultat_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Gestion du bouton retour
	if bouton_retour:
		bouton_retour.pressed.connect(_on_bouton_retour_pressed)
	else:
		printerr("ATTENTION : Nœud 'BoutonRetour' introuvable dans la scène Tirage.")

func _on_bouton_retour_pressed():
	get_tree().change_scene_to_file("res://scenes/main_game/menu.tscn")

func generer_tirage_pour_coffre(coffre):
	# 1. Récupérer la banque de boutons
	var pool_complet = get_tree().get_nodes_in_group("boutons_gemmes_pool")
	
	if pool_complet.size() == 0:
		printerr("ERREUR ROUGE : La banque est vide ! Vérifie le groupe 'boutons_gemmes_pool'.")
		return

	# 2. Trier les boutons par rareté
	var sacs_par_rareté = {
		1: [], 2: [], 3: [], 4: [], 5: []
	}
	
	for bouton in pool_complet:
		if bouton.data and "rarete" in bouton.data:
			var r = int(bouton.data.rarete)
			if sacs_par_rareté.has(r):
				sacs_par_rareté[r].append(bouton)
	
	# 3. Le Tirage des 6 Gemmes
	var selection_finale = []
	
	for i in range(6):
		# A. On demande au coffre quelle rareté on veut
		var rareté_gagnée = lancer_les_des(coffre)
		
		# B. On pioche (avec sécurité)
		var modele_bouton = piocher_gemme_robuste(sacs_par_rareté, rareté_gagnée, pool_complet)
		
		# C. Traitement et Sauvegarde
		if modele_bouton and modele_bouton.data:
			var data_unique = modele_bouton.data.duplicate()
			
			if data_unique.has_method("generer_stats_uniques"):
				data_unique.generer_stats_uniques()
			
			# Sauvegarde Inventaire
			if has_node("/root/PlayerData"):
				get_node("/root/PlayerData").ajouter_gemme_inventaire(data_unique)
			
			# --- CRÉATION VISUELLE (MODIFIÉ POUR MYSTERY CARD) ---
			
			# 1. On prépare le vrai bouton (la récompense)
			var bouton_visuel = modele_bouton.duplicate()
			bouton_visuel.data = data_unique 
			
			# 2. On l'emballe dans une Carte Mystère
			if scene_carte_mystere:
				var carte = scene_carte_mystere.instantiate()
				
				# On configure la carte (cache le bouton, met le bon point d'interrogation)
				if carte.has_method("setup"):
					carte.setup(bouton_visuel, data_unique)
				else:
					printerr("ERREUR : Le script MysteryCard n'a pas la fonction 'setup' !")
				
				selection_finale.append(carte)
			else:
				# Sécurité : Si tu as oublié de glisser la scène, on affiche le bouton direct
				selection_finale.append(bouton_visuel)
				
		else:
			printerr("ERREUR FATALE : Impossible de trouver une gemme pour le slot ", i)

	# 4. Envoi au panel
	if resultat_panel:
		resultat_panel.afficher_ces_boutons_la(selection_finale, coffre)

# --- LOGIQUE MATHÉMATIQUE ---

func lancer_les_des(coffre) -> int:
	var roll = randf_range(0.0, 100.0)
	var seuil = 0.0
	
	seuil += coffre.chance_commune
	if roll < seuil: return 1
	seuil += coffre.chance_rare
	if roll < seuil: return 2
	seuil += coffre.chance_epique
	if roll < seuil: return 3
	seuil += coffre.chance_legendaire
	if roll < seuil: return 4
	return 5

# --- PIOCHE ROBUSTE ---
func piocher_gemme_robuste(sacs, rareté_cible, pool_de_secours):
	var sac_cible = sacs[rareté_cible]
	
	if sac_cible.size() > 0:
		return sac_cible.pick_random()
	else:
		if rareté_cible > 1:
			return piocher_gemme_robuste(sacs, rareté_cible - 1, pool_de_secours)
		elif pool_de_secours.size() > 0:
			return pool_de_secours.pick_random()
		return null