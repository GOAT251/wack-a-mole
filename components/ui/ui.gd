extends CanvasLayer

# --- On précharge l'image dont on aura besoin ---
const ROOT_EFFECT_ICON = preload("res://assets/images/patte taupe racine2.png")

# --- Références aux Nœuds (une seule fois) ---
@onready var score_label = $ScoreLabel
@onready var time_label = $TimeLabel
@onready var lives_container = $LivesContainer
@onready var effect_icon_1 = $StateContainer/EffectSlot1/EffectIcon1


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

# --- Nouvelle fonction pour l'effet ---

func display_root_effect(is_active: bool):
	print("ÉTAPE 3 : UI.GD - ORDRE D'AFFICHAGE REÇU. État = ", is_active)
	if is_active:
		# Si l'effet est actif, on met l'image des ronces dans la texture de l'icône.
		effect_icon_1.texture = ROOT_EFFECT_ICON
	else:
		# Si l'effet est inactif, on vide la texture. L'icône redevient transparente.
		effect_icon_1.texture = null
