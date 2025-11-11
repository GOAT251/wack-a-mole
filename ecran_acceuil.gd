# Fichier : ecran_accueil.gd
# À attacher au nœud racine "EcranAccueil"

# CORRECTION : On dit au script qu'il est fait pour un CanvasLayer.
extends CanvasLayer

# On prend une référence à notre titre animé.
@onready var titre_anime = $TitreEcranAccueil

# La fonction _ready() est appelée automatiquement par Godot.
func _ready():
	# On dit simplement au titre de jouer son animation.
	titre_anime.play("default")