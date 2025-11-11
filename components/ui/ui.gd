# Fichier : ui.gd
extends CanvasLayer

# --- On précharge uniquement ce dont l'UI a DIRECTEMENT besoin ---
const RootedEffectScene = preload("res://assets/images/effet root animation/rooted_effect.tscn")

# --- Références aux Nœuds ---
@onready var score_label = $ScoreLabel
@onready var time_label = $TimeLabel
@onready var lives_container = $LivesContainer
# NOUVEAU : Une référence vers notre nouveau manager
@onready var effect_icon_manager = $EffectIconManager

var root_effect_instance = null

# --- Fonctions de mise à jour (ne changent pas) ---
func update_score(new_score):
	score_label.text = "Score: " + str(new_score)

func update_time(new_time):
	time_label.text = "Temps: " + str(new_time)

func update_lives(current_lives):
	var hearts = lives_container.get_children()
	for i in hearts.size():
		hearts[i].visible = ! (i >= current_lives)

# --- Fonctions de réception d'ordres (maintenant très simples) ---

func display_root_effect(is_active: bool):
	# On transmet l'ordre au manager.
	effect_icon_manager.set_root_status(is_active)
	
	# La logique de l'animation en plein écran reste ici car elle est
	# ajoutée à l'UI (le CanvasLayer), pas au manager.
	if is_active:
		if not is_instance_valid(root_effect_instance):
			root_effect_instance = RootedEffectScene.instantiate()
			add_child(root_effect_instance)
	else:
		if is_instance_valid(root_effect_instance):
			root_effect_instance.start_disappear()
			root_effect_instance = null

func display_x2_effect(is_active: bool):
	# On transmet l'ordre au manager.
	effect_icon_manager.set_x2_status(is_active)