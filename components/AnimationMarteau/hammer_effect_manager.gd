# Fichier : hammer_effect_manager.gd
extends Node

const HAMMER_SCENE = preload("res://components/AnimationMarteau/marteau_animation.tscn")

var hammer_to_play_id = ""

func _ready():
	# Au début de la partie, on demande à GameProgress quel marteau a été choisi.
	var equipped_hammer = GameProgress.current_hammer_id
	
	# On garde simplement en mémoire le nom du marteau à jouer.
	# Si GameProgress donne un nom invalide, on utilisera "paladin_hammer" par défaut.
	if equipped_hammer == "" or not HAMMER_SCENE.can_instantiate():
		hammer_to_play_id = "paladin_hammer" # Sécurité
	else:
		hammer_to_play_id = equipped_hammer

# _input() est appelé à chaque clic.
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		
		# On vérifie qu'on a bien un marteau à jouer.
		if hammer_to_play_id != "":
			
			# --- LA NOUVELLE LOGIQUE ---
			
			# 1. On crée une instance de la scène MÈRE (MarteauAnimation).
			var hammer_container = HAMMER_SCENE.instantiate()
			
			# 2. On la place à la position du clic.
			hammer_container.global_position = event.position
			
			# 3. On l'ajoute à la racine du jeu.
			get_tree().root.add_child(hammer_container)
			
			# 4. Maintenant, on cherche l'enfant qui a le bon nom.
			var target_animation = hammer_container.get_node(hammer_to_play_id)
			
			# 5. Si on l'a trouvé...
			if target_animation:
				# ...on le rend visible et on lance son animation.
				# (Assurez-vous que tous les autres sont invisibles par défaut dans la scène)
				target_animation.visible = true
				target_animation.play("default") # ou le nom de votre animation
