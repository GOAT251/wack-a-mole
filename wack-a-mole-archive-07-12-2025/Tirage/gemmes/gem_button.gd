@tool
extends TextureButton

@export var data: GemData:
	set(val):
		data = val
		if is_inside_tree(): update_visuals()

# --- TOUS TES CADRES (A remplir dans l'inspecteur) ---
@export_group("Cadres")
@export var cadre_feu: Texture2D
@export var cadre_frost: Texture2D
@export var cadre_plante: Texture2D
@export var cadre_sombre: Texture2D
@export var cadre_paladin: Texture2D
@export var cadre_foudre: Texture2D

func _ready():
	update_visuals()

func update_visuals():
	# Si pas de data, on ne touche à rien (on garde ton design manuel)
	if not data: return

	# 1. GESTION DE L'ICÔNE (Sans le % qui plante)
	# On cherche un enfant qui s'appelle "icon" ou "Icon" ou "IconDisplay"
	var icon_node = get_node_or_null("icon")
	if not icon_node: icon_node = get_node_or_null("Icon")
	if not icon_node: icon_node = get_node_or_null("IconDisplay")
	
	# Si on a trouvé le nœud ET qu'il y a une image dans la data, on la met
	if icon_node and data.icon:
		icon_node.texture = data.icon

	# 2. GESTION DU CADRE
	var nouveau_cadre: Texture2D = null
	
	match data.element:
		"Feu": nouveau_cadre = cadre_feu
		"Frost": nouveau_cadre = cadre_frost
		"Plante": nouveau_cadre = cadre_plante
		"Sombre": nouveau_cadre = cadre_sombre
		"Paladin": nouveau_cadre = cadre_paladin
		"Foudre": nouveau_cadre = cadre_foudre
	
	# IMPORTANT : On ne change l'image que si on a bien trouvé un cadre correspondant
	if nouveau_cadre:
		texture_normal = nouveau_cadre
	else:
		# Si nouveau_cadre est vide, c'est que tu n'as pas rempli l'inspecteur !
		# On ne fait rien pour ne pas casser ton visuel existant.
		pass