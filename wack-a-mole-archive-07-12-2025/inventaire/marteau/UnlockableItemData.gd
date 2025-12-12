# scripts/UnlockableItemData.gd
class_name UnlockableItemData
extends Resource

# Informations de base
@export var item_name: String = "Nouvel objet"
@export_multiline var description: String = "Description ici."
@export var icon: Texture2D
@export var is_unlocked: bool = false

# ============================
#         STATS JEU
# ============================

# Offensives
@export var flat_score_bonus: int = 0              # +X points par taupe
@export var score_multiplier: float = 1.0          # multiplicateur de score
@export var crit_rate: float = 0.0                 # probabilité de coup critique (0–1)
@export var crit_damage: float = 1.5               # multiplicateur de dégâts critique
@export var flat_damage: int = 0                   # dégâts purs
@export var damage_bonus_percent: float = 0.0      # % de dégâts bonus

# Utilitaires
@export var swing_speed: float = 1.0               # vitesse de frappe
@export var cooldown_reduction: float = 0.0        # réduction des cooldowns %
@export var precision: float = 0.0                 # marge d'erreur élargie pour toucher
@export var aim_assist: float = 0.0                # légère auto-correction

# Chances / événements
@export var golden_mole_luck: float = 0.0          # chance d'apparition de golden moles
@export var evade_rate: float = 0.0                # % chance d'esquiver une bombe

# Contrôle du rythme
@export var tempo_control: float = 0.0             # ralentissement léger du gameplay (0–1)

# Défensives
@export var negative_effect_duration_reduction: float = 0.0
# réduction des durées d'effets négatifs (%)

# Loot / utilitaire
@export var loot_drop_rate: float = 0.0            # chance d'obtenir plus d'objets
@export var time_extension: float = 0.0            # +X secondes à la fin du round

# Spéciales
@export var combo_power: float = 0.0               # bonus de score/dégâts sur combos
@export var combo_forgiveness: float = 0.0         # tolérance avant de casser un combo
@export var stun_chance: float = 0.0               # chance d'étourdir une taupe spéciale
@export var aoe_hit_chance: float = 0.0            # chance de toucher les trous adjacents
@export var animation_scene: PackedScene