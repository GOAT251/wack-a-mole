# Le script est attaché à la scène level_1.tscn
extends Node2D

# PAS DE "class_name" ICI. C'est la correction la plus importante.

# Les variables sont exportées pour être réglées dans l'Inspecteur
# pour CE niveau spécifique.
@export var time_left: int = 30
@export var target_score: int = 10
@export var spawn_speed: float = 1.0
@export var friend_chance: float = 0.2
@export var bomb_chance: float = 0.2 
@export var gold_mole_chance: float = 0.2