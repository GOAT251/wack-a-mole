extends Control

# Attention au chemin : VisuelMarteau est ENFANT de FormeEclat
@onready var visuel_marteau = $FormeEclat/VisuelMarteau
@onready var forme_eclat = $FormeEclat

func setup(data_marteau: UnlockableItemData):
	if data_marteau and visuel_marteau:
		visuel_marteau.texture = data_marteau.icon
		
		# Optionnel : Tu peux teinter la pierre selon l'élément
		# if "element" in data_marteau:
		# 	match data_marteau.element:
		# 		"Feu": forme_eclat.self_modulate = Color(1, 0.8, 0.8)