extends AnimatedSprite2D

func _ready():
    # Lance l'animation tout de suite
    play("default")
    # Se connecte à la fin de l'animation
    animation_finished.connect(func(): queue_free())