# Fichier : poof_effect.gd
extends AnimatedSprite2D

func _ready():
	# On se connecte à notre signal de fin.
	animation_finished.connect(hide)