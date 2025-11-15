extends Panel # Ou TextureRect

@onready var item_icon = $ItemIcon
@onready var item_name = $ItemName

# Cette fonction sera appelée par l'inventaire pour configurer la carte.
func set_data(icon_texture, name):
	item_icon.texture = icon_texture
	item_name.text = name