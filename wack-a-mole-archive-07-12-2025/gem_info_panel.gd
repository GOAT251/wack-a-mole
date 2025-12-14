extends Control

# Signal pour l'équipement
signal demande_equipement(data_gemme)

# --- RÉFÉRENCES ---
# On pointe vers "CadreFond" comme tu l'as demandé
@onready var cadre_visuel = $CadreFond

# On cherche les enfants DANS CadreFond
# (Vérifie que tes noeuds s'appellent bien comme ça dans l'éditeur !)
@onready var name_label = $CadreFond/NomLabel
@onready var icon_display = $CadreFond/Icon
@onready var stats_rich_label = $CadreFond/StatsRichLabel 
@onready var bouton_fermer = $CadreFond/BoutonFermer

# Le bouton Equiper (S'il est dans CadreFond ou à la racine ? Je le mets dans CadreFond par défaut)
# Si tu l'as mis à la racine, change la ligne en : @onready var equip_button = $EquipButton
@onready var equip_button = $CadreFond/BoutonEquiper

# --- CADRES ---
@export var frame_lumiere: Texture2D 
@export var frame_feu: Texture2D     
@export var frame_plant: Texture2D   
@export var frame_foudre: Texture2D  
@export var frame_froid: Texture2D   
@export var frame_sombre: Texture2D  

var current_displayed_item: GemData = null

func _ready():
	hide()
	
	# Sécurités de connexion
	if bouton_fermer and not bouton_fermer.pressed.is_connected(_on_bouton_retour_pressed):
		bouton_fermer.pressed.connect(_on_bouton_retour_pressed)
	
	if equip_button and not equip_button.pressed.is_connected(_on_equip_button_pressed):
		equip_button.pressed.connect(_on_equip_button_pressed)
		equip_button.hide()

func afficher_infos(data: GemData, mode_equipement: bool = false):
	self.visible = true
	current_displayed_item = data
	
	# 1. Mise à jour des textes de base
	if name_label: name_label.text = data.nom
	if icon_display: icon_display.texture = data.icon
	
	# 2. GÉNÉRATION DU BLOC DE STATS
	if stats_rich_label:
		var texte_final = ""
		for stat in data.stats_generees:
			var couleur = _get_couleur_par_tier(stat.tier_visuel)
			var val_str = str(stat.valeur)
			if stat.is_percent: val_str += "%"
			
			if stat.tier_visuel == 5: # Mythique
				texte_final += "[rainbow freq=0.5 sat=0.8 val=1.0]" + stat.nom + " : " + val_str + "[/rainbow]\n"
			else:
				texte_final += "[color=" + couleur + "]" + stat.nom + " : " + val_str + "[/color]\n"
		
		stats_rich_label.text = texte_final

	# 3. Gestion du bouton équiper
	if equip_button:
		equip_button.visible = mode_equipement

	# 4. Mise à jour du cadre (On appelle la fonction corrigée)
	_update_frame_visual(data.element)

func _update_frame_visual(element_name):
	# On utilise la référence 'cadre_visuel' qui pointe vers $CadreFond
	if cadre_visuel == null:
		printerr("ERREUR : Noeud 'CadreFond' introuvable !")
		return

	match element_name:
		"Paladin": if frame_lumiere: cadre_visuel.texture = frame_lumiere
		"Feu":     if frame_feu: cadre_visuel.texture = frame_feu
		"Plante":  if frame_plant: cadre_visuel.texture = frame_plant
		"Foudre":  if frame_foudre: cadre_visuel.texture = frame_foudre
		"Frost":   if frame_froid: cadre_visuel.texture = frame_froid
		"Sombre":  if frame_sombre: cadre_visuel.texture = frame_sombre
		_: 
			# Par défaut (si aucun match), on met Feu ou on ne change rien
			if frame_feu: cadre_visuel.texture = frame_feu

func _get_couleur_par_tier(tier: int) -> String:
	match tier:
		1: return "#B0B0B0" 
		2: return "#00FF00" 
		3: return "#0088FF" 
		4: return "#AA00FF" 
		5: return "#FFD700" 
	return "#FFFFFF"

func _on_bouton_retour_pressed():
	self.visible = false

func _on_equip_button_pressed():
	if current_displayed_item:
		demande_equipement.emit(current_displayed_item)
		self.visible = false
