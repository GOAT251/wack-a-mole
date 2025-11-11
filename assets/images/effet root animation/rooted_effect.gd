# Fichier : rooted_effect.gd
# À attacher à la racine de rooted_effect.tscn

extends CanvasLayer # Ou le type de votre noeud racine

# MODIFICATION CLÉ : On récupère le NŒUD qui contient les sprites.
# Assurez-vous que ce nœud s'appelle bien "root_sprites"
# et qu'il est un enfant direct du nœud qui porte ce script.
@onready var sprite_container = $root_sprites

func _ready():
	# On récupère tous les enfants du conteneur.
	var all_sprites = sprite_container.get_children()
	
	# On leur dit de jouer l'animation "play".
	for sprite in all_sprites:
		sprite.play("play")

# C'est la fonction que l'UI va appeler pour dire "disparais".
func start_disappear():
	var all_sprites = sprite_container.get_children()
	if all_sprites.is_empty():
		queue_free()
		return

	# On leur dit à tous de jouer l'animation "play" À L'ENVERS.
	for sprite in all_sprites:
		sprite.play_backwards("play")

	# On attend que le PREMIER sprite ait fini son animation pour se détruire.
	all_sprites[0].animation_finished.connect(queue_free, CONNECT_ONE_SHOT)
