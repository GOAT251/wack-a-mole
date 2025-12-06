extends Control

@export var ligne_haut: HBoxContainer
@export var ligne_bas: HBoxContainer
@export var bouton_fermer: Button

# Assure-toi d'avoir glissé la scène GemInfoPanel DANS ResultatTirage
@onready var info_panel = $GemInfoPanel 

# Mémoire du coffre
var coffre_source = null

func _ready():
	hide()
	# IMPORTANT : Au démarrage, on laisse passer la souris pour ne pas bloquer les coffres derrière
	mouse_filter = Control.MOUSE_FILTER_IGNORE 
	
	if bouton_fermer:
		bouton_fermer.pressed.connect(_on_bouton_fermer_pressed)
	
	# Sécurité : on s'assure que le panel info est caché au début
	if info_panel: info_panel.hide()

func afficher_ces_boutons_la(liste_vrais_boutons, coffre_ref = null):
	coffre_source = coffre_ref
	
	nettoyer_ligne(ligne_haut)
	nettoyer_ligne(ligne_bas)
	
	var compteur = 0
	for bouton in liste_vrais_boutons:
		var copie = bouton.duplicate()
		copie.visible = true
		copie.disabled = false
		copie.mouse_filter = Control.MOUSE_FILTER_STOP
		
		if copie.custom_minimum_size == Vector2.ZERO:
			copie.custom_minimum_size = Vector2(100, 100) 
		
		# Connexion du clic sur la gemme
		if copie.get("data") != null:
			copie.pressed.connect(_on_gemme_clicked.bind(copie.data))
		
		if compteur < 3: 
			if ligne_haut: ligne_haut.add_child(copie)
		else: 
			if ligne_bas: ligne_bas.add_child(copie)	
		compteur += 1

	show()
	move_to_front()
	# IMPORTANT : Maintenant qu'il est visible, on capture les clics
	# Sinon le clic traverse et appuie sur les coffres en dessous !
	mouse_filter = Control.MOUSE_FILTER_STOP 

func _on_gemme_clicked(data_gemme):
	if info_panel:
		info_panel.afficher_infos(data_gemme)
		info_panel.show()
		info_panel.move_to_front()

# --- GESTION DU CLIC SUR LE FOND ---
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			
			# CAS 1 : Si le panel d'info est ouvert...
			if info_panel and info_panel.visible:
				# ... On ferme JUSTE le panel d'info
				info_panel.hide()
				accept_event() # Stop, on ne va pas plus loin !
				return 
			
			# CAS 2 : Si le panel d'info était déjà fermé...
			# ... Alors on ferme tout le panneau de résultats
			fermer_le_panel()

func _on_bouton_fermer_pressed():
	fermer_le_panel()

func fermer_le_panel():
	hide()
	if info_panel: info_panel.hide()
	
	# IMPORTANT : On laisse la souris passer à travers pour pouvoir recliquer sur les coffres
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# On remet le coffre à l'état fermé
	if coffre_source != null and coffre_source.has_method("reset_coffre"):
		coffre_source.reset_coffre()
		coffre_source = null

func nettoyer_ligne(ligne):
	if ligne:
		for enfant in ligne.get_children():
			enfant.queue_free()