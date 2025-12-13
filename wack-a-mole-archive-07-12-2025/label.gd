extends Label

# La largeur max que le texte ne doit pas dépasser
# Si tu laisses à 0, il utilisera la taille actuelle du Label
@export var largeur_max: float = 0.0

func _ready():
	# On se connecte au signal qui détecte quand le label change de taille ou de texte
	item_rect_changed.connect(ajuster_taille)
	ajuster_taille()

# Fonction appelée automatiquement quand le texte change
func set_text(valeur):
	super.text = valeur
	ajuster_taille()

func ajuster_taille():
	# 1. On remet la taille normale pour mesurer
	scale = Vector2.ONE
	
	# 2. On détermine la limite (soit la variable export, soit la taille du noeud)
	var limite = largeur_max
	if limite <= 0:
		limite = size.x
	
	# 3. On mesure la largeur réelle du texte
	var font = get_theme_font("font")
	var font_size = get_theme_font_size("font_size")
	var largeur_texte = font.get_string_size(text, horizontal_alignment, -1, font_size).x
	
	# 4. Si ça dépasse, on réduit le scale
	if largeur_texte > limite and limite > 0:
		var ratio = limite / largeur_texte
		scale = Vector2(ratio, ratio)
	else:
		scale = Vector2.ONE
