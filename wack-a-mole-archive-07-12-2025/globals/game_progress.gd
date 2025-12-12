extends Node

# --- DONNÉES DES NIVEAUX (PROPRE) ---

# La base de données de tous les niveaux du jeu.
const LEVEL_DATABASE = {
	"res://scenes/main_game/world_1/level_1.tscn": {"name": "Niveau 1", "unlocks_next": "res://scenes/main_game/world_1/level_2.tscn"},
	"res://scenes/main_game/world_1/level_2.tscn": {"name": "Niveau 2", "unlocks_next": null}
}

var unlocked_levels = ["res://scenes/main_game/world_1/level_1.tscn"] # Le premier niveau est toujours débloqué
var high_scores = {}

# Variable temporaire pour savoir quel niveau lancer
var current_level_to_play = ""


# --- FONCTIONS DE PROGRESSION ---

# Le joueur a gagné un niveau, on débloque le suivant
func level_completed(level_path):
	var level_data = LEVEL_DATABASE.get(level_path)
	if not level_data:
		print("Erreur: Le niveau ", level_path, " n'a pas été trouvé dans la base de données.")
		return
	
	var next_level = level_data["unlocks_next"]
	
	# S'il y a un niveau suivant ET qu'il n'est pas déjà débloqué
	if next_level and not next_level in unlocked_levels:
		unlocked_levels.append(next_level)
		print("Nouveau niveau débloqué : ", next_level)

# Fonction pour lancer le niveau sélectionné
func play_level(level_path):
	current_level_to_play = level_path
	# On utilise le bon chemin vers la scène de jeu.
	get_tree().change_scene_to_file("res://scenes/main_game/game.tscn")

# NOTE : La gestion du marteau a été déplacée dans PlayerData.gd 
# pour gérer les animations et les stats via les fichiers .tres