extends CanvasLayer

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# On s'assure que l'animation se lance dès que la scène est créée.
	animated_sprite.play("play")