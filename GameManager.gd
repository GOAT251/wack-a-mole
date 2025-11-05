extends Node

# La variable pour suivre le niveau actuel.
var current_level_index = 0

# La liste des scènes de niveau.
# Assurez-vous que vos fichiers de scène s'appellent bien "level_1.tscn" et "level_2.tscn".
const LEVELS = [
	preload("res://level_1.tscn"),
	preload("res://level_2.tscn")
]

# Le nombre total de niveaux est simplement la taille de la liste.
var total_levels = LEVELS.size()


# Fonction pour passer au niveau suivant.
func go_to_next_level():
	current_level_index += 1
	# On recharge la scène de jeu. Elle lira le nouvel index et chargera le bon niveau.
	get_tree().reload_current_scene()


# Fonction pour recommencer le jeu depuis le début.
func restart_game():
	current_level_index = 0
	get_tree().reload_current_scene()
