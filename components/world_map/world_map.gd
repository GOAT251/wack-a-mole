extends Control

func _ready():
	# On parcourt tous les enfants de cette scène
	for node in get_children():
		# Si un enfant est une de nos icônes de niveau...
		if node is TextureButton and node.has_method("update_visuals"):
			# On récupère le chemin qu'on a défini dans l'Inspecteur
			var level_path = node.level_path
			
			# On demande au GameProgress si ce niveau est débloqué
			var is_unlocked = level_path in GameProgress.unlocked_levels
			
			# On met à jour son apparence (lock/unlock)
			node.update_visuals(is_unlocked)
			
			# On se connecte à son signal pour savoir quand il est cliqué
			node.level_selected.connect(_on_level_icon_selected)

# Dans world_map.gd

func _on_level_icon_selected(level_path_to_play):
	# Message de débogage pour voir si la carte a bien reçu l'ordre.
	print("Carte du monde a reçu le signal ! Lancement du niveau : ", level_path_to_play)
	GameProgress.play_level(level_path_to_play)