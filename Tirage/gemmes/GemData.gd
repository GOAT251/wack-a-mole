class_name GemData
extends Resource

@export var nom: String = "Nom de la gemme"
@export var icon: Texture2D
@export_range(1, 5) var rarete: int = 1

# --- NOUVEAU : LES STATS ---

# Les bornes (définies dans l'éditeur pour chaque type)
@export var stat_min: float = 10.0
@export var stat_max: float = 20.0

# La valeur réelle (qui sera définie au moment du tirage)
var valeur_reelle: float = 0.0

# Fonction pour générer une stat unique
func generer_stats_aleatoires():
	valeur_reelle = randf_range(stat_min, stat_max)
	# On arrondit à 2 chiffres après la virgule si tu veux
	valeur_reelle = snapped(valeur_reelle, 0.01)