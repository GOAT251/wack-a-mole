extends Control

@export var ligne_haut: HBoxContainer
@export var ligne_bas: HBoxContainer
@export var bouton_fermer: Button

func _ready():
	hide()
	if bouton_fermer:
		bouton_fermer.pressed.connect(_on_bouton_fermer_pressed)

# Fonction appelée par le Tirage
func afficher_ces_boutons_la(liste_vrais_boutons):
	print("--- AFFICHAGE RESULTATS ---")
	
	# 1. ON NETTOIE LES "FAUX" BOUTONS (Ceux que tu as mis dans l'éditeur)
	nettoyer_ligne(ligne_haut)
	nettoyer_ligne(ligne_bas)
	
	# 2. ON PLACE LES VRAIS BOUTONS
	var compteur = 0
	
	for bouton in liste_vrais_boutons:
		var copie = bouton.duplicate()
		copie.visible = true
		copie.disabled = false
		
		# On s'assure que le bouton a une taille minimale pour être visible
		# (Au cas où tes boutons originaux soient mal réglés)
		if copie.custom_minimum_size == Vector2.ZERO:
			copie.custom_minimum_size = Vector2(100, 100) 
		
		if compteur < 3:
			ligne_haut.add_child(copie)
		else:
			ligne_bas.add_child(copie)
			
		compteur += 1

	# 3. ON AFFICHE
	show()
	move_to_front()

# Petite fonction utilitaire pour vider une boite
func nettoyer_ligne(ligne):
	if ligne:
		for enfant in ligne.get_children():
			enfant.queue_free()

func _on_bouton_fermer_pressed():
	hide()