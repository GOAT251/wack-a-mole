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
	mouse_filter = Control.MOUSE_FILTER_IGNORE 
	
	if bouton_fermer:
		bouton_fermer.pressed.connect(_on_bouton_fermer_pressed)
	
	if info_panel: info_panel.hide()

func afficher_ces_boutons_la(liste_objets, coffre_ref = null):
	coffre_source = coffre_ref
	
	nettoyer_ligne(ligne_haut)
	nettoyer_ligne(ligne_bas)
	
	var compteur = 0
	for objet in liste_objets:
		# On copie l'objet (que ce soit un Bouton ou une Carte)
		var copie = objet.duplicate()
		copie.visible = true
		copie.disabled = false
		copie.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Taille minimale pour être sûr que ça s'affiche
		if copie.custom_minimum_size == Vector2.ZERO:
			copie.custom_minimum_size = Vector2(100, 100) 
		
		# ============================================================
		# CONNEXION INTELLIGENTE (Le Fix est ici)
		# ============================================================
		var bouton_a_connecter = copie # Par défaut, on pense que c'est le bouton direct
		
		# CAS 1 : C'est une Carte Mystère ? (On vérifie si elle a un enfant caché avec 'data')
		# Comme on vient de dupliquer, les variables script sont peut-être null, 
		# donc on fouille les enfants physiques.
		for enfant in copie.get_children():
			if "data" in enfant and enfant.data != null:
				bouton_a_connecter = enfant
				# On s'assure que le bouton interne pourra recevoir le clic une fois révélé
				bouton_a_connecter.mouse_filter = Control.MOUSE_FILTER_STOP 
				break
		
		# CAS 2 : Connexion du signal
		# On vérifie qu'on a bien trouvé un truc avec de la data
		if "data" in bouton_a_connecter and bouton_a_connecter.data != null:
			if not bouton_a_connecter.pressed.is_connected(_on_gemme_clicked):
				# On connecte le clic de CE bouton spécifique à l'ouverture du panel
				bouton_a_connecter.pressed.connect(_on_gemme_clicked.bind(bouton_a_connecter.data))
		else:
			print("ERREUR : Impossible de trouver la data pour connecter le clic (Objet: ", copie.name, ")")
		
		# ============================================================

		# Placement dans les lignes
		if compteur < 3: 
			if ligne_haut: ligne_haut.add_child(copie)
		else: 
			if ligne_bas: ligne_bas.add_child(copie)	
		compteur += 1

	show()
	move_to_front()
	mouse_filter = Control.MOUSE_FILTER_STOP 

func _on_gemme_clicked(data_gemme):
	print("Clic Gemme détecté ! Ouverture Infos pour : ", data_gemme.nom)
	if info_panel:
		info_panel.afficher_infos(data_gemme)
		info_panel.show()
		info_panel.move_to_front()

# --- GESTION DU CLIC SUR LE FOND ---
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			
			if info_panel and info_panel.visible:
				info_panel.hide()
				accept_event()
				return 
			
			fermer_le_panel()

func _on_bouton_fermer_pressed():
	fermer_le_panel()

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