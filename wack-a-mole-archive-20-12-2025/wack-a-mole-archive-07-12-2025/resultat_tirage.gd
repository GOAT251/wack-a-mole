extends Control

@export var ligne_haut: HBoxContainer
@export var ligne_bas: HBoxContainer
@export var bouton_fermer: Button
@onready var info_panel = $GemInfoPanel 

var coffre_source = null
var nombre_cartes_total = 0
var nombre_cartes_ouvertes = 0
var tirage_termine = false

func _ready():
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE 
	if bouton_fermer: bouton_fermer.pressed.connect(_on_bouton_fermer_pressed)
	if info_panel: info_panel.hide()

func afficher_ces_boutons_la(liste_objets, coffre_ref = null):
	coffre_source = coffre_ref
	
	# Reset
	nombre_cartes_total = 0
	nombre_cartes_ouvertes = 0
	tirage_termine = false
	if bouton_fermer: bouton_fermer.hide()
	
	nettoyer_ligne(ligne_haut)
	nettoyer_ligne(ligne_bas)
	
	var compteur = 0
	var liste_anim = []
	
	for objet in liste_objets:
		var copie = objet.duplicate()
		
		# Visuel initial
		copie.visible = true
		copie.scale = Vector2.ZERO 
		copie.mouse_filter = Control.MOUSE_FILTER_STOP
		
		if copie.custom_minimum_size == Vector2.ZERO:
			copie.custom_minimum_size = Vector2(100, 100) 
		
		# Gestion Verrouillage (Carte Mystère)
		if copie.has_signal("carte_ouverte"):
			nombre_cartes_total += 1
			copie.carte_ouverte.connect(_on_une_carte_s_ouvre)
		
		# Recherche du bouton interne (Gemme ou Shard)
		var bouton_interne = copie 
		for enfant in copie.get_children():
			if "data" in enfant and enfant.data != null:
				bouton_interne = enfant
				bouton_interne.mouse_filter = Control.MOUSE_FILTER_STOP 
				break
		
		if "data" in bouton_interne and bouton_interne.data != null:
			
			# ============================================================
			# 🚨 MODIF ICI : FILTRE GEMME VS MARTEAU 🚨
			# ============================================================
			# On ne connecte le clic QUE si c'est une Gemme (GemData)
			# Si c'est un Marteau (UnlockableItemData), on ne fait rien au clic (pas de panel)
			if bouton_interne.data is GemData:
				if not bouton_interne.pressed.is_connected(_on_gemme_clicked):
					bouton_interne.pressed.connect(_on_gemme_clicked.bind(bouton_interne.data))
			
			# ============================================================
			# RESTAURATION DE LA MÉMOIRE (POUR LES EFFETS VISUELS)
			# ============================================================
			# Ça c'est important pour que tes cartes mystères aient la bonne couleur de particules
			if "data_memoire" in copie:
				copie.data_memoire = bouton_interne.data
		
		# Placement
		if compteur < 3: 
			if ligne_haut: ligne_haut.add_child(copie)
		else: 
			if ligne_bas: ligne_bas.add_child(copie)	
		
		liste_anim.append(copie)
		compteur += 1
	
	if nombre_cartes_total == 0:
		deverrouiller_fermeture()

	show()
	move_to_front()
	mouse_filter = Control.MOUSE_FILTER_STOP 
	
	# Animation
	_animer_distribution(liste_anim)

func _animer_distribution(cartes):
	var delai = 0.0
	for carte in cartes:
		var tween = create_tween()
		tween.tween_property(carte, "scale", Vector2(1.1, 1.1), 0.25).set_delay(delai).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(carte, "scale", Vector2(1.0, 1.0), 0.1)
		delai += 0.1

func _on_une_carte_s_ouvre():
	nombre_cartes_ouvertes += 1
	if nombre_cartes_ouvertes >= nombre_cartes_total:
		deverrouiller_fermeture()

func deverrouiller_fermeture():
	tirage_termine = true
	if bouton_fermer: bouton_fermer.show()

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if info_panel and info_panel.visible:
			info_panel.hide()
			accept_event()
			return 
		if not tirage_termine: return 
		fermer_le_panel()

func _on_bouton_fermer_pressed():
	if not tirage_termine: return
	fermer_le_panel()
	
func _on_gemme_clicked(data_gemme):
	if info_panel:
		info_panel.afficher_infos(data_gemme)
		info_panel.show()
		info_panel.move_to_front()

func fermer_le_panel():
	hide()
	if info_panel: info_panel.hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if coffre_source != null and coffre_source.has_method("reset_coffre"):
		coffre_source.reset_coffre()
		coffre_source = null

func nettoyer_ligne(ligne):
	if ligne:
		for enfant in ligne.get_children():
			enfant.queue_free()
