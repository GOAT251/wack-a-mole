extends TextureButton

# Le coffre (BoutonCoffre) que ce bouton doit faire apparaître
@export var coffre_a_afficher: Control

# Variable partagée entre tous les boutons pour savoir lequel est ouvert
static var dernier_coffre_ouvert: Control = null

func _ready():
	# Connexion du signal
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

func _on_pressed():
	if coffre_a_afficher:
		
		# 1. GESTION DE L'ANCIEN COFFRE
		# Si un autre coffre était ouvert, on le cache
		if dernier_coffre_ouvert and dernier_coffre_ouvert != coffre_a_afficher:
			dernier_coffre_ouvert.hide()
		
		# 2. GESTION DU MIEN (Toggle)
		# On inverse la visibilité (Visible <-> Caché)
		coffre_a_afficher.visible = not coffre_a_afficher.visible
		
		# 3. MISE A JOUR DE LA MÉMOIRE ET RESET
		if coffre_a_afficher.visible:
			# Je deviens le dernier coffre ouvert
			dernier_coffre_ouvert = coffre_a_afficher
			
			# IMPORTANT : On le remet à l'état "Fermé" pour l'animation
			if coffre_a_afficher.has_method("reset_coffre"):
				coffre_a_afficher.reset_coffre()
				
		else:
			# Si je viens de me fermer, il n'y a plus de coffre ouvert
			dernier_coffre_ouvert = null
			
	else:
		print("ERREUR : Pas de cible assignée pour ", self.name)