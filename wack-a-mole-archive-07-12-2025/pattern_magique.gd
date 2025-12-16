extends TextureRect

@export var vitesse_x = 2.0
@export var vitesse_y = 1.0

func _process(delta):
	# On accède à la texture de bruit interne
	if texture and texture is NoiseTexture2D:
		# On déplace l'offset du bruit pour créer un effet de "fumée qui coule"
		texture.noise.offset.x += vitesse_x * delta
		texture.noise.offset.y += vitesse_y * delta