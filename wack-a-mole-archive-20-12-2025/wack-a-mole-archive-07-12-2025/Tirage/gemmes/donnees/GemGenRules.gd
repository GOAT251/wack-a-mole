class_name GemGenRules
extends Resource

# ==============================================================================
# 1. LES PROBABILITÉS
# ==============================================================================
@export_group("Casino - Probabilités")
@export_range(0.0, 1.0) var chance_1_bonus: float = 0.30 # 30%
@export_range(0.0, 1.0) var chance_2_bonus: float = 0.20 # 20%

@export_subgroup("Tiers & Rolls")
@export_range(0.0, 1.0) var chance_tier_upgrade: float = 0.05   # 5% Divine Proc
@export_range(0.0, 1.0) var chance_tier_downgrade: float = 0.10 # 10% Bad Roll

# ==============================================================================
# 2. DEFINITION DES STATS (AVEC TOUS LES INTERVALLES)
# ==============================================================================
# Format : X = Min, Y = Max
# t1 = Commun, t2 = Rare, t3 = Epique, t4 = Legendaire, t5 = Mythique

@export_group("1. Stat Fixe (Socle)")
@export var stat_fixe: Dictionary = { 
	"key": "flat_damage", "nom": "Dégâts Bruts", "is_percent": false,
	"t1": Vector2(5, 10),   "t2": Vector2(10, 20),   "t3": Vector2(20, 40), 
	"t4": Vector2(40, 80),  "t5": Vector2(75, 150)
}

@export_group("2. Pool Basique (Corps)")
@export var pool_basique: Array[Dictionary] = [
	{ 
		"key": "damage_bonus_percent", "nom": "% Dégâts", "is_percent": true,
		"t1": Vector2(2, 5),   "t2": Vector2(4, 10),   "t3": Vector2(8, 20), 
		"t4": Vector2(16, 40), "t5": Vector2(30, 75)
	},
	{ 
		"key": "flat_score_bonus", "nom": "Points Bonus", "is_percent": false,
		"t1": Vector2(10, 20), "t2": Vector2(20, 40),  "t3": Vector2(40, 80), 
		"t4": Vector2(80, 160),"t5": Vector2(150, 300)
	},
	{ 
		"key": "swing_speed", "nom": "Vitesse Frappe", "is_percent": true,
		"t1": Vector2(1, 3),   "t2": Vector2(2, 6),    "t3": Vector2(4, 12), 
		"t4": Vector2(8, 24),  "t5": Vector2(15, 45)
	},
	{ 
		"key": "crit_rate", "nom": "Critique", "is_percent": true,
		"t1": Vector2(1, 2),   "t2": Vector2(2, 4),    "t3": Vector2(4, 8), 
		"t4": Vector2(8, 16),  "t5": Vector2(15, 30)
	},
	{ 
		"key": "crit_damage", "nom": "Dégâts Crit.", "is_percent": true,
		"t1": Vector2(5, 10),  "t2": Vector2(10, 20),  "t3": Vector2(20, 40), 
		"t4": Vector2(40, 80), "t5": Vector2(75, 150)
	},
	{ 
		"key": "score_multiplier", "nom": "Multiplicateur", "is_percent": true,
		"t1": Vector2(0.1, 0.2), "t2": Vector2(0.2, 0.4), "t3": Vector2(0.4, 0.8), 
		"t4": Vector2(0.8, 1.6), "t5": Vector2(1.5, 3.0)
	}
]

@export_group("3. Pool Bonus (Cerise)")
@export var pool_bonus: Array[Dictionary] = [
	{ 
		"key": "golden_mole_luck", "nom": "Chance Dorée", "is_percent": true,
		"t1": Vector2(0.5, 1), "t2": Vector2(1, 2),    "t3": Vector2(2, 4), 
		"t4": Vector2(4, 8),   "t5": Vector2(7.5, 15)
	},
	{ 
		"key": "loot_drop_rate", "nom": "Chance Loot", "is_percent": true,
		"t1": Vector2(1, 3),   "t2": Vector2(2, 6),    "t3": Vector2(4, 12), 
		"t4": Vector2(8, 24),  "t5": Vector2(15, 45)
	},
	{ 
		"key": "time_extension", "nom": "Temps Extra", "is_percent": false,
		"t1": Vector2(1, 2),   "t2": Vector2(2, 4),    "t3": Vector2(4, 8), 
		"t4": Vector2(8, 16),  "t5": Vector2(15, 30)
	},
	{ 
		"key": "combo_power", "nom": "Combo Power", "is_percent": true,
		"t1": Vector2(1, 5),   "t2": Vector2(2, 10),   "t3": Vector2(4, 20), 
		"t4": Vector2(8, 40),  "t5": Vector2(15, 75)
	},
	{ 
		"key": "stun_chance", "nom": "Stun", "is_percent": true,
		"t1": Vector2(1, 3),   "t2": Vector2(2, 6),    "t3": Vector2(4, 12), 
		"t4": Vector2(8, 24),  "t5": Vector2(15, 45)
	},
	{ 
		"key": "cooldown_reduction", "nom": "CDR", "is_percent": true,
		"t1": Vector2(1, 5),   "t2": Vector2(2, 10),   "t3": Vector2(4, 20), 
		"t4": Vector2(8, 40),  "t5": Vector2(15, 75)
	}
]