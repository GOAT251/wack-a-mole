class_name StatsCalculator
extends RefCounted

# Structure de sortie (Le Bilan de santé du joueur)
class PlayerFinalStats:
	# --- COMBAT ---
	var degats_finaux: float = 0.0
	var vitesse_attaque: float = 1.0
	var chance_critique: float = 0.0
	var degats_critique: float = 1.5 
	
	# --- SCORE ---
	var flat_score_bonus: int = 0      # <--- C'est celle-là qui manquait !
	var score_multiplier: float = 1.0
	
	# --- UTILITAIRE / BONUS ---
	var chance_doree: float = 0.0
	var chance_loot: float = 0.0
	var temps_extra: float = 0.0
	var combo_power: float = 0.0
	var stun_chance: float = 0.0
	var cooldown_reduction: float = 0.0
	var aoe_hit_chance: float = 0.0

# --- FONCTION PRINCIPALE ---
static func calculer_tout(marteau: UnlockableItemData, gemmes: Array) -> PlayerFinalStats:
	var stats = PlayerFinalStats.new()
	
	# ============================================================
	# 1. INITIALISATION AVEC LE MARTEAU (LA BASE)
	# ============================================================
	var base_degats = 10.0
	var base_vitesse = 1.0
	var base_crit = 0.05
	var base_crit_dmg = 1.5
	
	if marteau:
		# Stats de combat de base
		base_degats = float(marteau.flat_damage)
		base_vitesse = marteau.swing_speed
		base_crit = marteau.crit_rate
		base_crit_dmg = marteau.crit_damage
		
		# Stats directes (C'est ici que ça plantait avant)
		stats.flat_score_bonus = marteau.flat_score_bonus
		stats.score_multiplier = marteau.score_multiplier
		
		# Autres stats du marteau (si elles existent dans UnlockableItemData)
		stats.chance_doree = marteau.golden_mole_luck
		stats.chance_loot = marteau.loot_drop_rate
		stats.temps_extra = marteau.time_extension
		stats.combo_power = marteau.combo_power
		stats.stun_chance = marteau.stun_chance
		stats.cooldown_reduction = marteau.cooldown_reduction
		stats.aoe_hit_chance = marteau.aoe_hit_chance
	
	# ============================================================
	# 2. CUMUL DES BONUS DES GEMMES (ADDITIVE STACKING)
	# ============================================================
	
	# Accumulateurs temporaires pour le calcul final
	var flat_damage_added = 0.0
	var percent_damage_sum = 0.0 
	var speed_bonus_sum = 0.0
	
	for gem in gemmes:
		if gem == null: continue
		
		# On parcourt chaque ligne de stat de la gemme
		for ligne in gem.stats_generees:
			var valeur = ligne.valeur
			
			match ligne.key:
				# --- OFFENSIF ---
				"flat_damage":
					flat_damage_added += valeur
				"damage_bonus_percent":
					percent_damage_sum += valeur 
				"crit_rate":
					base_crit += (valeur / 100.0) 
				"crit_damage":
					base_crit_dmg += (valeur / 100.0) 
				"swing_speed":
					speed_bonus_sum += valeur
					
				# --- SCORE ---
				"flat_score_bonus":
					stats.flat_score_bonus += int(valeur) # Ajout au marteau
				"score_multiplier":
					stats.score_multiplier += valeur
					
				# --- UTILITAIRE / BONUS ---
				"golden_mole_luck": stats.chance_doree += valeur
				"loot_drop_rate": stats.chance_loot += valeur
				"time_extension": stats.temps_extra += valeur
				"combo_power": stats.combo_power += valeur
				"stun_chance": stats.stun_chance += valeur
				"cooldown_reduction": stats.cooldown_reduction += valeur
				"aoe_hit_chance": stats.aoe_hit_chance += valeur

	# ============================================================
	# 3. CALCUL FINAL (LA FORMULE)
	# ============================================================
	
	# DÉGÂTS : (Base Marteau + Flat Gemmes) * (1 + Somme % Gemmes)
	# Ex: (100 + 50) * (1 + 0.20) = 150 * 1.2 = 180
	var total_flat = base_degats + flat_damage_added
	var multi_percent = 1.0 + (percent_damage_sum / 100.0)
	stats.degats_finaux = total_flat * multi_percent
	
	# VITESSE
	stats.vitesse_attaque = base_vitesse * (1.0 + (speed_bonus_sum / 100.0))
	
	# CRITIQUE
	stats.chance_critique = min(base_crit, 1.0)
	stats.degats_critique = base_crit_dmg
	
	return stats