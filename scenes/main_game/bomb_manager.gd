# Dans BombManager.gd

extends Node

# Cette fonction est appelée par game.gd mais elle est vide.
# La vraie logique de la bombe est dans BombRoot.gd.
# On la garde pour que la connexion dans game.gd ne casse pas.
func on_bomb_hit():
	pass