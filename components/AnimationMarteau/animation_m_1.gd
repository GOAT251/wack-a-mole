# Script à attacher à CHAQUE scène d'explosion
extends AnimatedSprite2D

func _ready():
	animation_finished.connect(queue_free)
	play("default") # ou le nom de votre animation d'explosion