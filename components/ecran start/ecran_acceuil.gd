# Fichier : ecran_accueil.gd
extends CanvasLayer

# --- On précharge les deux images du bouton ---
# ATTENTION : Mettez les bons chemins ici !
const BOUTON_NORMAL = preload("res://assets/images/ecran accueil/boutonEN.png")
const BOUTON_PRESSE = preload("res://assets/images/ecran accueil/boutonENA.png")

# --- Références aux Nœuds ---
@onready var titre_anime = $TitreEcranAccueil
@onready var bouton_visuel = $BoutonJouer # C'est maintenant un TextureRect
@onready var bouton_invisible = $BoutonPleinEcran

func _ready():
	titre_anime.play("default") # ou "play"
	
	# On met l'image normale au début
	bouton_visuel.texture = BOUTON_NORMAL
	
	# On connecte les signaux du bouton invisible
	bouton_invisible.button_down.connect(_on_ecran_appui_commence)
	bouton_invisible.button_up.connect(_on_ecran_appui_termine)
	bouton_invisible.pressed.connect(_on_ecran_presse)

# Appelé quand on appuie sur l'écran
func _on_ecran_appui_commence():
	# On change la texture MANUELLEMENT
	bouton_visuel.texture = BOUTON_PRESSE

# Appelé quand on relâche le clic
func _on_ecran_appui_termine():
	# On remet la texture MANUELLEMENT
	bouton_visuel.texture = BOUTON_NORMAL

# Appelé quand un clic complet a eu lieu
func _on_ecran_presse():
	# On change de scène
	get_tree().change_scene_to_file("res://scenes/main_game/menu.tscn")
