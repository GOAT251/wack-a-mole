extends Control

signal demande_equipement(data_gemme)

# --- RÉFÉRENCES ---
@onready var cadre_visuel = $CadreFond
@onready var name_label = $CadreFond/NomLabel
@onready var icon_display = $CadreFond/Icon
@onready var bouton_fermer = $CadreFond/BoutonFermer
@onready var equip_button = $CadreFond/BoutonEquiper
@onready var container_labels = $CadreFond/StatsContainer 
@onready var effet_holo = $MasqueForme 

# --- CADRES ---
@export var frame_lumiere: Texture2D 
@export var frame_feu: Texture2D     
@export var frame_plant: Texture2D   
@export var frame_foudre: Texture2D  
@export var frame_froid: Texture2D   
@export var frame_sombre: Texture2D  

# --- CONFIGURATION ---
const LARGEUR_COLONNE_NOM = 250.0
const CHEMIN_MATERIAU = "res://Resources/Shaders/Mat_TexteMythique.tres"

var current_displayed_item: GemData = null
var materiau_mythique: ShaderMaterial = null

func _ready():
	hide()
	if bouton_fermer: 
		bouton_fermer.pressed.connect(_on_bouton_retour_pressed)
	if equip_button: 
		equip_button.pressed.connect(_on_equip_button_pressed)
		equip_button.hide()
	if effet_holo: 
		effet_holo.hide()
	
	# Chargement du shader
	if ResourceLoader.exists(CHEMIN_MATERIAU):
		materiau_mythique = load(CHEMIN_MATERIAU)
	else:
		printerr("ERREUR : Le fichier matériau '", CHEMIN_MATERIAU, "' n'existe pas ! Le texte mythique sera juste blanc.")

func afficher_infos(data: GemData, mode_equipement: bool = false):
	self.visible = true
	current_displayed_item = data
	
	if name_label: name_label.text = data.nom
	if icon_display: icon_display.texture = data.icon
	
	if container_labels:
		var labels = container_labels.get_children()
		
		# 1. RESET
		for l in labels:
			l.hide()
			l.text = "" 
		
		for i in range(data.stats_generees.size()):
			if i >= labels.size(): break
			
			var stat = data.stats_generees[i]
			var slot_parent = labels[i]
			
			slot_parent.show()
			slot_parent.custom_minimum_size.y = 35 
			
			# --- INJECTION STRUCTURE ---
			var hbox = slot_parent.get_node_or_null("HBoxInterne")
			var lbl_nom = null
			var lbl_val = null
			
			if hbox == null:
				hbox = HBoxContainer.new()
				hbox.name = "HBoxInterne"
				hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
				hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
				hbox.add_theme_constant_override("separation", 10) 
				
				# NOM (Gauche)
				lbl_nom = Label.new()
				lbl_nom.name = "Nom"
				lbl_nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				lbl_nom.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				
				# ALIGNEMENT FORCÉ
				lbl_nom.custom_minimum_size.x = LARGEUR_COLONNE_NOM
				lbl_nom.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
				lbl_nom.size_flags_stretch_ratio = 0
				
				lbl_nom.modulate = Color(0.8, 0.8, 0.8)
				
				# VALEUR (Droite)
				lbl_val = RichTextLabel.new()
				lbl_val.name = "Valeur"
				lbl_val.bbcode_enabled = true
				lbl_val.fit_content = true
				lbl_val.scroll_active = false
				lbl_val.autowrap_mode = TextServer.AUTOWRAP_OFF
				lbl_val.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				lbl_val.size_flags_vertical = Control.SIZE_SHRINK_CENTER
				
				hbox.add_child(lbl_nom)
				hbox.add_child(lbl_val)
				slot_parent.add_child(hbox)
			else:
				lbl_nom = hbox.get_node("Nom")
				lbl_val = hbox.get_node("Valeur")
				lbl_nom.custom_minimum_size.x = LARGEUR_COLONNE_NOM
			
			# --- FONT ---
			var font = slot_parent.get_theme_font("normal_font")
			var f_size = slot_parent.get_theme_font_size("normal_font_size")
			if font:
				lbl_nom.add_theme_font_override("font", font)
				lbl_val.add_theme_font_override("normal_font", font)
			if f_size > 0:
				lbl_nom.add_theme_font_size_override("font_size", f_size)
				lbl_val.add_theme_font_size_override("normal_font_size", f_size)
			
			# --- TEXTE ---
			var val_str = str(stat.valeur)
			if stat.is_percent: val_str += "%"
			var signe = "+"
			if stat.valeur < 0: signe = ""
			
			lbl_nom.text = stat.nom + " :"
			
			# --- COULEUR & SHADER ---
			# Reset du material pour éviter que tout le monde brille
			lbl_val.material = null 
			
			if stat.tier_visuel == 5: # MYTHIQUE
				# On applique le shader
				if materiau_mythique:
					lbl_val.material = materiau_mythique
					# Texte brut blanc (le shader fera la couleur)
					lbl_val.text = signe + val_str
				else:
					# Fallback si pas de shader : Rouge/Or
					lbl_val.text = "[color=#FFD700]" + signe + val_str + "[/color]"
			else:
				# Couleurs normales
				var couleur = Color(_get_couleur_par_tier(stat.tier_visuel))
				lbl_val.text = "[color=#" + couleur.to_html(false) + "]" + signe + val_str + "[/color]"

	if cadre_visuel:
		var dico = {"Paladin": frame_lumiere, "Feu": frame_feu, "Plante": frame_plant, "Foudre": frame_foudre, "Frost": frame_froid, "Sombre": frame_sombre}
		var tex = AfficherInfos.choisir_texture_cadre(data.element, dico)
		if tex: cadre_visuel.texture = tex

	if equip_button: equip_button.visible = mode_equipement
	
	if effet_holo:
		if data.rarete == 5: effet_holo.show() # J'ai remis 5 (Mythique) pour le cadre aussi
		else: effet_holo.hide()

	show()
	move_to_front()

func _get_couleur_par_tier(tier: int) -> String:
	if tier == 1: return "B0B0B0"
	if tier == 2: return "00FF00"
	if tier == 3: return "0088FF"
	if tier == 4: return "AA00FF"
	if tier == 5: return "FFD700"
	return "FFFFFF"

func _on_bouton_retour_pressed():
	self.visible = false

func _on_equip_button_pressed():
	if current_displayed_item:
		demande_equipement.emit(current_displayed_item)
		self.visible = false
