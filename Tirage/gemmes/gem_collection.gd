extends Control

# Glisse ta scène "GemButton.tscn" ici dans l'inspecteur
@export var scene_bouton_gemme: PackedScene

# La grille où on va ranger les boutons
@onready var grille = $GridContainer

# --- LISTE TEMPORAIRE POUR TESTER ---
@export var inventaire_joueur: Array[GemData]

func _ready():
	# 1. IMPORTANT : On cache toute la collection au démarrage !
	# Elle ne sert que de base de données, elle ne doit pas gêner les clics du joueur.
	self.visible = false 
	
	# Petite sécurité pour être sûr que tout est chargé avant de remplir
	call_deferred("afficher_inventaire")

func afficher_inventaire():
	# 0. Sécurité
	if not scene_bouton_gemme:
		# On ne crie pas d'erreur si c'est juste une banque vide, mais on prévient
		# printerr("GemCollection : Pas de scène bouton assignée.")
		return

	# 1. On vide la grille (nettoyage)
	if grille:
		for enfant in grille.get_children():
			enfant.queue_free()
	
	# 2. On crée les boutons modèles
	# (Le script Tirage viendra les lire ici, même si la collection est cachée)
	
	for data_gemme in inventaire_joueur:
		if data_gemme: 
			var nouveau_bouton = scene_bouton_gemme.instantiate()
			
			if grille:
				grille.add_child(nouveau_bouton)
				
				# On injecte les données
				nouveau_bouton.data = data_gemme
				
				# Mise à jour visuelle
				if nouveau_bouton.has_method("update_visuals"):
					nouveau_bouton.update_visuals()
				
				# IMPORTANT : On s'assure que ces boutons modèles ne bloquent pas la souris
				# (Au cas où la collection deviendrait visible par erreur)
				nouveau_bouton.mouse_filter = Control.MOUSE_FILTER_IGNORE