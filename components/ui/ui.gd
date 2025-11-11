extends CanvasLayer

# --- On précharge l'image dont on aura besoin ---
# NOTE: Cette ligne n'est plus utilisée, vous pouvez la supprimer si vous voulez.
const ROOT_EFFECT_ICON = preload("res://assets/images/patte taupe racine2.png")

# On doit pré-charger la SCÈNE (.tscn) de l'animation, pas la ressource (.tres).
const RootedEffectScene = preload("res://animations effets/effet root aniamtion/rooted_effect.tscn") # VÉRIFIEZ CE CHEMIN !

# Une variable pour garder en mémoire l'effet quand il est affiché.
var rooted_effect_instance = null

# --- Références aux Nœuds (une seule fois) ---
@onready var score_label = $ScoreLabel
@onready var time_label = $TimeLabel
@onready var lives_container = $LivesContainer

# --- Fonctions de mise à jour de l'UI ---

func update_score(new_score):
	score_label.text = "Score: " + str(new_score)

func update_time(new_time):
	time_label.text = "Temps: " + str(new_time)

func update_lives(current_lives):
	var hearts = lives_container.get_children()
	for i in hearts.size():
		if i < current_lives:
			hearts[i].visible = true
		else:
			hearts[i].visible = false

# Fonction pour afficher ou cacher l'effet de "root".
func display_root_effect(is_active: bool):
	if is_active:
		# Si l'effet est actif, on crée l'animation
		if not rooted_effect_instance:
			rooted_effect_instance = RootedEffectScene.instantiate()
			add_child(rooted_effect_instance)
	else:
		# Si l'effet est inactif, on détruit l'animation
		if rooted_effect_instance:
			rooted_effect_instance.queue_free()
			rooted_effect_instance = null