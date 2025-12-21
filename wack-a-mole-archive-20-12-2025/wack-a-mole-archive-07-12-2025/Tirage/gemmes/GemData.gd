class_name GemData
extends Resource

# --- INFO DE BASE ---
@export var nom: String = "Nom de la Gemme"
@export var icon: Texture2D
@export_enum("Feu", "Glace", "Plante", "Foudre", "Sombre", "Paladin") var element: String = "Feu"
@export_range(1, 5) var rarete: int = 1

# --- STOCKAGE STATS ---
var stats_generees: Array = []

# --- CONNEXION AU CERVEAU (.tres) ---
# ⚠️ Vérifie que ce fichier existe bien, sinon commente cette ligne temporairement !
var regles_par_defaut = preload("res://Tirage/gemmes/donnees/ReglesGemmes.tres") 

# --- GÉNÉRATION ---
# MODIFICATION ICI : J'ai retiré ": GemGenRules" pour éviter l'erreur de parse
func generer_stats_uniques(regles_custom = null):
	var rules = regles_custom
	if rules == null: rules = regles_par_defaut
	
	if rules == null:
		printerr("ERREUR CRITIQUE : Pas de fichier ReglesGemmes.tres trouvé !")
		return

	randomize()
	stats_generees.clear()
	
	# 1. LA STAT FIXE
	_generer_ligne_precise(rules.stat_fixe, rules)
	
	# 2. LES 3 STATS BASIQUES
	var pool_b = rules.pool_basique.duplicate()
	pool_b.shuffle()
	for i in range(3):
		if pool_b.size() > 0: 
			_generer_ligne_precise(pool_b.pop_front(), rules)
	
	# 3. LES STATS BONUS
	var roll = randf()
	var nb_bonus = 0
	
	if roll > (1.0 - rules.chance_2_bonus): 
		nb_bonus = 2
	elif roll > (1.0 - rules.chance_2_bonus - rules.chance_1_bonus): 
		nb_bonus = 1
	
	var pool_bonus = rules.pool_bonus.duplicate()
	pool_bonus.shuffle()
	
	for i in range(nb_bonus):
		if pool_bonus.size() > 0: 
			_generer_ligne_precise(pool_bonus.pop_front(), rules)

# --- MOTEUR DE CALCUL ---
# MODIFICATION ICI : J'ai retiré ": GemGenRules"
func _generer_ligne_precise(config: Dictionary, rules):
	# A. CALCUL DU TIER
	var tier = rarete
	var chance = randf()
	
	if chance < rules.chance_tier_upgrade and tier < 5: 
		tier += 1
	elif chance > (1.0 - rules.chance_tier_downgrade) and tier > 1: 
		tier -= 1
	
	# B. LECTURE DES DONNÉES
	var cle_tier = "t" + str(tier) 
	var intervalle = Vector2.ZERO
	
	if config.has(cle_tier):
		intervalle = config[cle_tier]
	else:
		printerr("ERREUR : Pas de config pour le tier ", cle_tier, " dans ", config.get("nom", "Inconnu"))
		return

	# C. ROLL
	var val_min = intervalle.x
	var val_max = intervalle.y
	var valeur_brute = randf_range(val_min, val_max)
	
	# D. ARRONDI
	var valeur_finale = 0.0
	if config.get("is_percent", false):
		valeur_finale = snapped(valeur_brute, 0.1)
	else:
		valeur_finale = round(valeur_brute)
	
	# E. QUALITÉ
	var ratio = 0.0
	if val_max > val_min:
		ratio = (valeur_brute - val_min) / (val_max - val_min)
	else:
		ratio = 1.0
	
	# F. ENREGISTREMENT
	stats_generees.append({
		"key": config.key,
		"nom": config.nom,
		"valeur": valeur_finale,
		"is_percent": config.get("is_percent", false),
		"tier_visuel": tier,
		"ratio": ratio
	})
