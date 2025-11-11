extends CanvasLayer

# --- On précharge les DEUX choses dont on aura besoin ---
const ROOT_EFFECT_ICON = preload("res://assets/images/patte taupe racine2.png")
# MODIFICATION 1 : On précharge la scène de l'animation
const RootedEffectScene = preload("res://assets/images/effet root animation/rooted_effect.tscn")

# --- Références aux Nœuds ---
@onready var score_label = $ScoreLabel
@onready var time_label = $TimeLabel
@onready var lives_container = $LivesContainer
@onready var effect_icon_1 = $StateContainer/EffectSlot1/EffectIcon1

# MODIFICATION 2 : On ajoute une variable pour garder en mémoire l'animation
var root_effect_instance = null

# --- Fonctions de mise à jour de l'UI (ne changent pas) ---

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

# --- Fonction pour l'effet (gère maintenant les DEUX effets) ---

func display_root_effect(is_active: bool):
	print("UI.GD - Ordre d'affichage reçu. État = ", is_active)
	
	if is_active:
		# --- GESTION DE L'ICÔNE (votre code, ne change pas) ---
		effect_icon_1.texture = ROOT_EFFECT_ICON
		
		# --- GESTION DE L'ANIMATION (ne change pas) ---
		# On s'assure qu'il n'y en a pas déjà une
		if is_instance_valid(root_effect_instance):
			return
		
		# On crée la scène d'animation et on l'ajoute à l'UI
		root_effect_instance = RootedEffectScene.instantiate()
		add_child(root_effect_instance)
		
	else:
		# --- GESTION DE L'ICÔNE (votre code, ne change pas) ---
		effect_icon_1.texture = null
		
		# --- MODIFICATION CLÉ : GESTION DE LA DISPARITION DE L'ANIMATION ---
		# On vérifie si l'animation existe
		if is_instance_valid(root_effect_instance):
			# On ne la détruit plus brutalement.
			# On appelle la fonction start_disappear() du script de l'effet.
			root_effect_instance.start_disappear()
			
			# On vide la variable pour être prêt pour la prochaine fois.
			root_effect_instance = null