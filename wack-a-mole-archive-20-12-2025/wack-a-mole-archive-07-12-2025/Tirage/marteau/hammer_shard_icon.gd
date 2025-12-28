extends Control

# Tes chemins exacts d'après le screenshot
@onready var forme_eclat = $FormeEclat
@onready var visuel_marteau = $FormeEclat/VisuelMarteau

# --- C'EST CETTE VARIABLE QUI MANQUAIT POUR LES EFFETS ---
# La carte mystère vient lire ça pour savoir quelle couleur de particules lancer
var data = null 
# ---------------------------------------------------------

func setup(data_marteau: UnlockableItemData):
	# 1. On sauvegarde les infos (Rareté, Nom...) dans la mémoire du shard
	data = data_marteau
	
	# 2. On affiche l'image
	if data_marteau and visuel_marteau:
		visuel_marteau.texture = data_marteau.icon
		
		# (Optionnel) On s'assure que le marteau reste bien cadré dans l'éclat
		visuel_marteau.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		visuel_marteau.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# (Optionnel) Teinter la forme de l'éclat selon l'élément
		if forme_eclat and "element" in data_marteau:
			match data_marteau.element:
				"Feu": forme_eclat.self_modulate = Color(1, 0.8, 0.8)
				"Glace": forme_eclat.self_modulate = Color(0.8, 0.9, 1)
				"Foudre": forme_eclat.self_modulate = Color(1, 1, 0.8)
				"Sombre": forme_eclat.self_modulate = Color(0.9, 0.8, 1)
				"Plante": forme_eclat.self_modulate = Color(0.8, 1, 0.8)
				_: forme_eclat.self_modulate = Color.WHITE