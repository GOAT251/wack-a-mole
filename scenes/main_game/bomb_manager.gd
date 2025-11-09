extends Node

# --- AJOUT N°1 : On crée une "prise" pour brancher le StatusManager ---
@export var status_manager: Node

func on_bomb_hit():
	# On vérifie que le StatusManager est bien branché avant de l'appeler.
	if status_manager:
		# --- AJOUT N°2 : On appelle le StatusManager pour lui dire de geler le joueur ---
		status_manager.apply_freeze(6.0) # On passe la durée du gel