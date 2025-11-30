extends TextureButton

# C'est ici que tu glisseras le fichier .tres manuellement
@export var data: GemData 

# On garde juste la référence vers l'image au cas où on veut faire un effet 
# (comme le griser si pas débloqué), mais on ne change PAS la texture.
@onready var icon_display = $Icon # Assure-toi que ton enfant s'appelle Icon (ou IconDisplay)

func _ready():
	# On ne fait RIEN ici. 
	# C'est toi qui as mis l'image dans l'éditeur, on la laisse telle quelle.
	pass

func _pressed():
	if data:
		print("J'ai cliqué sur : ", data.nom)
		# Plus tard : Ouvrir le panel de stats avec 'data'