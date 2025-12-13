extends Control

# --- SIGNAL ---
# On prévient l'inventaire qu'on veut équiper cette gemme
signal demande_equipement(data_gemme)

# --- RÉFÉRENCES ---
@onready var cadre_visuel = $CadreFond
@onready var icon_visuel = $CadreFond/Icon
@onready var nom_label = $CadreFond/NomLabel
@onready var stats_label = $CadreFond/StatsLabel
@onready var bouton_fermer = $CadreFond/BoutonFermer

# --- NOUVEAU : Le bouton pour équiper ---
# Assure-toi de l'avoir créé dans la scène sous CadreFond !
@onready var bouton_equiper = $CadreFond/BoutonEquiper

# --- LES 6 CADRES ---
@export var frame_lumiere: Texture2D 
@export var frame_feu: Texture2D     
@export var frame_plant: Texture2D   
@export var frame_foudre: Texture2D  
@export var frame_froid: Texture2D   
@export var frame_sombre: Texture2D  

# Variable pour se souvenir de quelle gemme on regarde
var data_actuelle = null

func _ready():
	hide()
	
	if bouton_fermer:
		bouton_fermer.pressed.connect(_on_fermer_pressed)
		
	# Connexion du bouton équiper
	if bouton_equiper:
		bouton_equiper.pressed.connect(_on_bouton_equiper_pressed)
		bouton_equiper.hide() # Caché par défaut

# --- FONCTION MODIFIÉE : Ajout du mode équipement ---
func afficher_infos(data: GemData, mode_equipement: bool = false):
	print("\n--- DIAGNOSTIC PANEL ---")
	
	if data == null: 
		printerr("ERREUR ROUGE : Aucune donnée reçue (data est null) !")
		return
	
	# On stocke la data pour pouvoir l'envoyer si on clique sur Équiper
	data_actuelle = data
	
	print("1. Gemme reçue : ", data.nom)
	print("2. Élément : '", data.element, "'")
	
	# Remplissage Textes
	if nom_label: nom_label.text = data.nom
	if icon_visuel: icon_visuel.texture = data.icon
	if stats_label: stats_label.text = "Puissance : " + str(data.valeur_reelle)
	
	# GESTION DU BOUTON ÉQUIPER
	if bouton_equiper:
		bouton_equiper.visible = mode_equipement
		print("3. Mode Equipement : ", mode_equipement)
	
	# CHOIX DU CADRE
	match data.element:
		"Paladin": 
			if frame_lumiere: cadre_visuel.texture = frame_lumiere
		"Feu":     
			if frame_feu: cadre_visuel.texture = frame_feu
		"Plante":  
			if frame_plant: cadre_visuel.texture = frame_plant
		"Foudre":  
			if frame_foudre: cadre_visuel.texture = frame_foudre
		"Frost":   
			if frame_froid: cadre_visuel.texture = frame_froid
		"Sombre":  
			if frame_sombre: cadre_visuel.texture = frame_sombre
		_: 
			cadre_visuel.texture = frame_feu 

	show()
	move_to_front()
	print("--------------------------------\n")

func _on_fermer_pressed():
	hide()

# --- NOUVELLE FONCTION ---
func _on_bouton_equiper_pressed():
	if data_actuelle:
		print("✅ Clic sur ÉQUIPER -> Envoi du signal...")
		demande_equipement.emit(data_actuelle)
		hide()