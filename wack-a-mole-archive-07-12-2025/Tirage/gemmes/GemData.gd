class_name GemData
extends Resource

# --- INFO DE BASE (Ce que tu as déjà) ---
@export var nom: String = "Nom de la Gemme"
@export var icon: Texture2D
@export_enum("Feu", "Glace", "Plante", "Foudre", "Sombre", "Paladin") var element: String = "Feu"
@export_range(1, 5) var rarete: int = 1

# --- STATS ALÉATOIRES (Bornes) ---
@export_group("Stats")
@export var stat_nom: String = "Force" # Ex: Force, Vitesse, PV...
@export var stat_min: int = 10
@export var stat_max: int = 20

# --- VALEUR RÉELLE (Celle qui compte) ---
# Cette variable n'est pas exportée, elle est calculée par le code
var valeur_reelle: int = 0

# Fonction appelée par le Tirage juste après la duplication
func generer_stats_uniques():
	randomize()
	# On tire un chiffre au hasard entre le min et le max
	valeur_reelle = randi_range(stat_min, stat_max)
	# print("Stat générée pour ", nom, " : ", valeur_reelle)