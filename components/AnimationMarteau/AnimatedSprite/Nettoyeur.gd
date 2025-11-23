extends Node2D

func _ready():
	# On cherche l'enfant qui est l'AnimatedSprite2D
	# (Cette boucle permet de le trouver peu importe son nom)
	for child in get_children():
		if child is AnimatedSprite2D:
			
			# 1. On lance l'animation sur l'enfant
			child.play("default")
			
			# 2. Quand l'ENFANT a fini, il demande à la RACINE (self) de se supprimer
			child.animation_finished.connect(queue_free)
			
			# On a trouvé, on s'arrête là
			return
