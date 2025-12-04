class_name GemData
extends Resource

@export var nom: String = "Nom de la gemme"
@export var icon: Texture2D
@export_range(1, 5) var rarete: int = 1

# C'est ici qu'on définit le type (Feu, Frost, etc.)
@export_enum("Feu", "Frost", "Plante", "Sombre", "Paladin", "Foudre") var element: String = "Feu"

@export var stat_min: float = 10.0
@export var stat_max: float = 20.0
var valeur_reelle: float = 0.0

func generer_stats_aleatoires():
	valeur_reelle = randf_range(stat_min, stat_max)
	valeur_reelle = snapped(valeur_reelle, 0.01)