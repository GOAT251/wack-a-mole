extends Control

# --- RÉFÉRENCES ---
@onready var cadre_visuel = $CadreFond
@onready var icon_visuel = $CadreFond/Icon
@onready var nom_label = $CadreFond/NomLabel
@onready var stats_label = $CadreFond/StatsLabel
@onready var bouton_fermer = $CadreFond/BoutonFermer

# --- LES 6 CADRES ---
@export var frame_lumiere: Texture2D # Pour Paladin
@export var frame_feu: Texture2D     # Pour Feu
@export var frame_plant: Texture2D   # Pour Plante
@export var frame_foudre: Texture2D  # Pour Foudre
@export var frame_froid: Texture2D   # Pour Frost
@export var frame_sombre: Texture2D  # Pour Sombre

func _ready():
	hide()
	if bouton_fermer:
		bouton_fermer.pressed.connect(_on_fermer_pressed)

func afficher_infos(data: GemData):
	print("\n--- DIAGNOSTIC PANEL ---")
	
	if data == null: 
		printerr("ERREUR ROUGE : Aucune donnée reçue (data est null) !")
		return
	
	print("1. Gemme reçue : ", data.nom)
	print("2. Élément lu dans le fichier .tres : '", data.element, "'")
	
	# Remplissage Textes
	if nom_label: nom_label.text = data.nom
	if icon_visuel: icon_visuel.texture = data.icon
	if stats_label: stats_label.text = "Puissance : " + str(data.valeur_reelle)
	
	# CHOIX DU CADRE AVEC DEBUG
	match data.element:
		"Paladin": 
			print("-> Match : PALADIN détecté.")
			if frame_lumiere:
				cadre_visuel.texture = frame_lumiere
				print("-> OK : Texture Paladin appliquée.")
			else:
				printerr("-> ERREUR ROUGE : La case 'Frame Lumiere' est VIDE dans l'inspecteur !")

		"Feu":     
			print("-> Match : FEU détecté.")
			if frame_feu:
				cadre_visuel.texture = frame_feu
				print("-> OK : Texture Feu appliquée.")
			else:
				printerr("-> ERREUR ROUGE : La case 'Frame Feu' est VIDE dans l'inspecteur !")

		"Plante":  
			print("-> Match : PLANTE détecté.")
			if frame_plant:
				cadre_visuel.texture = frame_plant
				print("-> OK : Texture Plante appliquée.")
			else:
				printerr("-> ERREUR ROUGE : La case 'Frame Plant' est VIDE dans l'inspecteur !")

		"Foudre":  
			print("-> Match : FOUDRE détecté.")
			if frame_foudre:
				cadre_visuel.texture = frame_foudre
				print("-> OK : Texture Foudre appliquée.")
			else:
				printerr("-> ERREUR ROUGE : La case 'Frame Foudre' est VIDE dans l'inspecteur !")

		"Frost":   
			print("-> Match : FROST détecté.")
			if frame_froid:
				cadre_visuel.texture = frame_froid
				print("-> OK : Texture Frost appliquée.")
			else:
				printerr("-> ERREUR ROUGE : La case 'Frame Froid' est VIDE dans l'inspecteur !")

		"Sombre":  
			print("-> Match : SOMBRE détecté.")
			if frame_sombre:
				cadre_visuel.texture = frame_sombre
				print("-> OK : Texture Sombre appliquée.")
			else:
				printerr("-> ERREUR ROUGE : La case 'Frame Sombre' est VIDE dans l'inspecteur !")

		_: 
			printerr("-> ERREUR ROUGE : L'élément '", data.element, "' ne correspond à rien dans le MATCH !")
			cadre_visuel.texture = frame_feu 

	show()
	move_to_front()
	print("--------------------------------\n")

func _on_fermer_pressed():
	hide()