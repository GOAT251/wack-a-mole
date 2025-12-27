extends TextureButton

# --- LA LIGNE QUI MANQUAIT ---
# C'est ici que tu vas glisser le fichier .tres du marteau (Feu, Glace, etc.)
@export var data: UnlockableItemData 
# -----------------------------

func _ready():
	# On vérifie qu'on a bien donné une donnée au bouton
	if data and data.icon:
		
		# On cherche le noeud VisuelMarteau dans la hiérarchie que tu as décrite
		var visuel = get_node_or_null("HammerShardIcon/FormeEclat/VisuelMarteau")
		
		if visuel:
			visuel.texture = data.icon
		else:
			printerr("ERREUR : Impossible de trouver 'VisuelMarteau' dans ", name)
			printerr("Vérifie que la hiérarchie est bien : HammerShardIcon -> FormeEclat -> VisuelMarteau")
