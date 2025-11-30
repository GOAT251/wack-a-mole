extends Control

# Glisse ta scène "GemButton.tscn" ici dans l'inspecteur
@export var scene_bouton_gemme: PackedScene

# La grille où on va ranger les boutons
@onready var grille = $GridContainer

# --- LISTE TEMPORAIRE POUR TESTER ---
# Glisse ici 6 fichiers .tres pour simuler l'inventaire
@export var inventaire_joueur: Array[GemData]

func _ready():
	# Petite sécurité pour être sûr que tout est chargé
	call_deferred("afficher_inventaire")

func afficher_inventaire():
	# 0. Sécurité : Est-ce qu'on a bien assigné la scène du bouton ?
	if not scene_bouton_gemme:
		printerr("ERREUR ROUGE : Tu as oublié de glisser 'GemButton.tscn' dans la case 'Scene Bouton Gemme' de GemCollection !")
		return

	# 1. On vide la grille
	for enfant in grille.get_children():
		enfant.queue_free()
	
	# 2. On crée les boutons
	print("Création de ", inventaire_joueur.size(), " boutons de gemmes...")
	
	for data_gemme in inventaire_joueur:
		if data_gemme: # On vérifie que la donnée n'est pas vide
			
			# A. On fabrique le bouton
			var nouveau_bouton = scene_bouton_gemme.instantiate()
			
			# B. IMPORTANT : On l'ajoute à l'écran D'ABORD
			# Cela permet au bouton de lancer son _ready() et de trouver son icône
			grille.add_child(nouveau_bouton)
			
			# C. ENSUITE, on lui donne les infos
			# (Assure-toi que ton script GemButton a bien une variable 'data')
			nouveau_bouton.data = data_gemme
			
			# D. On force la mise à jour visuelle si le bouton a la fonction
			if nouveau_bouton.has_method("update_visuals"):
				nouveau_bouton.update_visuals()
