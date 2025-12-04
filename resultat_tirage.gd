extends Control

@export var ligne_haut: HBoxContainer
@export var ligne_bas: HBoxContainer
@export var bouton_fermer: Button

# --- NOUVEAU : Référence au panel d'infos ---
# Assure-toi d'avoir glissé la scène GemInfoPanel DANS ResultatTirage via la chaîne 🔗
@onready var info_panel = $GemInfoPanel 

func _ready():
	hide()
	if bouton_fermer:
		bouton_fermer.pressed.connect(_on_bouton_fermer_pressed)

# Fonction appelée par le Tirage
func afficher_ces_boutons_la(liste_vrais_boutons):
	nettoyer_ligne(ligne_haut)
	nettoyer_ligne(ligne_bas)
	
	var compteur = 0
	for bouton in liste_vrais_boutons:
		# On copie le bouton original
		var copie = bouton.duplicate()
		copie.visible = true
		copie.disabled = false
		copie.mouse_filter = Control.MOUSE_FILTER_STOP # Important pour le clic
		
		# On force une taille mini si besoin
		if copie.custom_minimum_size == Vector2.ZERO:
			copie.custom_minimum_size = Vector2(100, 100) 
		
		# --- LA CONNEXION MAGIQUE ---
		# Quand on clique sur la copie, on ouvre le panel d'info
		# On utilise .bind() pour envoyer les données de CE bouton précis
		if copie.get("data") != null:
			copie.pressed.connect(_on_gemme_clicked.bind(copie.data))
		
		# Placement dans les lignes
		if compteur < 3: 
			if ligne_haut: ligne_haut.add_child(copie)
		else: 
			if ligne_bas: ligne_bas.add_child(copie)	
		compteur += 1

	show()
	move_to_front()

# --- NOUVELLE FONCTION : OUVRIR LA FICHE ---
func _on_gemme_clicked(data_gemme):
	if info_panel:
		info_panel.afficher_infos(data_gemme)
	else:
		printerr("ERREUR : Je ne trouve pas $GemInfoPanel dans la scène ResultatTirage !")

# --- CLIC À CÔTÉ (FERMETURE) ---
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# On ferme le panel de résultat
			hide()
			# On ferme aussi le panel d'infos s'il était ouvert
			if info_panel: info_panel.hide()

func _on_bouton_fermer_pressed():
	hide()
	if info_panel: info_panel.hide()

func nettoyer_ligne(ligne):
	if ligne:
		for enfant in ligne.get_children():
			enfant.queue_free()