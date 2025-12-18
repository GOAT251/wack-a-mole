extends Control

signal demande_equipement(data_gemme)

# --- RÉFÉRENCES ---
@onready var cadre_visuel = $CadreFond
@onready var name_label = $CadreFond/NomLabel
@onready var icon_display = $CadreFond/Icon
@onready var bouton_fermer = $CadreFond/BoutonFermer
@onready var equip_button = $CadreFond/BoutonEquiper
@onready var container_labels = $CadreFond/StatsContainer 

# --- MASQUES (GLISSE-LES DEPUIS LA SCÈNE) ---
@export_group("Effets Holographiques (Masques)")
@export var mask_commun: Polygon2D
@export var mask_rare: Polygon2D
@export var mask_epique: Polygon2D
@export var mask_leg: Polygon2D
@export var mask_mythique: Polygon2D

# --- CADRES ---
@export_group("Cadres des Éléments")
@export var frame_lumiere: Texture2D 
@export var frame_feu: Texture2D     
@export var frame_plant: Texture2D   
@export var frame_foudre: Texture2D  
@export var frame_froid: Texture2D   
@export var frame_sombre: Texture2D  

# --- SHADER TEXTE ---
@export_group("Shaders")
@export var materiau_mythique: ShaderMaterial

var current_displayed_item: GemData = null
const LARGEUR_COLONNE_NOM = 250.0

func _ready():
	hide()
	if bouton_fermer: bouton_fermer.pressed.connect(_on_bouton_retour_pressed)
	if equip_button: equip_button.pressed.connect(_on_equip_button_pressed); equip_button.hide()
	
	# On cache les masques au démarrage
	_cacher_tous_les_masques()

func afficher_infos(data: GemData, mode_equipement: bool = false):
	self.visible = true
	current_displayed_item = data
	
	# 1. Textes & Icone
	if name_label: name_label.text = data.nom
	if icon_display: icon_display.texture = data.icon
	
	# 2. Stats
	if container_labels:
		var labels = container_labels.get_children()
		for l in labels: l.hide(); l.text = "" 
		
		for i in range(data.stats_generees.size()):
			if i >= labels.size(): break
			var stat = data.stats_generees[i]
			var slot_parent = labels[i]
			slot_parent.show()
			slot_parent.custom_minimum_size.y = 35 
			
			var hbox = slot_parent.get_node_or_null("HBoxInterne")
			var lbl_nom = null
			var lbl_val = null
			
			if hbox == null:
				hbox = HBoxContainer.new()
				hbox.name = "HBoxInterne"
				hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
				hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
				hbox.add_theme_constant_override("separation", 10) 
				lbl_nom = Label.new(); lbl_nom.name = "Nom"; lbl_nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT; lbl_nom.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				lbl_nom.custom_minimum_size.x = LARGEUR_COLONNE_NOM; lbl_nom.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN; lbl_nom.modulate = Color(0.8, 0.8, 0.8)
				lbl_val = RichTextLabel.new(); lbl_val.name = "Valeur"; lbl_val.bbcode_enabled = true; lbl_val.fit_content = true; lbl_val.scroll_active = false; lbl_val.size_flags_horizontal = Control.SIZE_EXPAND_FILL; lbl_val.size_flags_vertical = Control.SIZE_SHRINK_CENTER
				hbox.add_child(lbl_nom); hbox.add_child(lbl_val); slot_parent.add_child(hbox)
			else:
				lbl_nom = hbox.get_node("Nom"); lbl_val = hbox.get_node("Valeur")
				lbl_nom.custom_minimum_size.x = LARGEUR_COLONNE_NOM
			
			var font = slot_parent.get_theme_font("normal_font")
			var f_size = slot_parent.get_theme_font_size("normal_font_size")
			if font:
				lbl_nom.add_theme_font_override("font", font); lbl_val.add_theme_font_override("normal_font", font)
			if f_size > 0:
				lbl_nom.add_theme_font_size_override("font_size", f_size); lbl_val.add_theme_font_size_override("normal_font_size", f_size)
			
			lbl_nom.text = stat.nom + " :"
			var val_str = str(stat.valeur) + ("%" if stat.is_percent else "")
			var signe = "+" if stat.valeur >= 0 else ""
			
			lbl_val.material = null 
			if stat.tier_visuel == 5: 
				if materiau_mythique: lbl_val.material = materiau_mythique; lbl_val.text = signe + val_str
				else: lbl_val.text = "[color=#FF4400]" + signe + val_str + "[/color]"
			else:
				lbl_val.text = "[color=#" + _get_couleur_par_tier(stat.tier_visuel).to_html(false) + "]" + signe + val_str + "[/color]"

	# 3. Cadre
	if cadre_visuel:
		var dico = {"Paladin": frame_lumiere, "Feu": frame_feu, "Plante": frame_plant, "Foudre": frame_foudre, "Frost": frame_froid, "Sombre": frame_sombre}
		var tex = AfficherInfos.choisir_texture_cadre(data.element, dico)
		if tex: cadre_visuel.texture = tex

	# 4. Bouton
	if equip_button: equip_button.visible = mode_equipement
	
	# 5. MASQUES
	_cacher_tous_les_masques()
	
	var masque_actif = null
	if data.rarete == 1: masque_actif = mask_commun
	elif data.rarete == 2: masque_actif = mask_rare
	elif data.rarete == 3: masque_actif = mask_epique
	elif data.rarete == 4: masque_actif = mask_leg
	elif data.rarete == 5: masque_actif = mask_mythique
	
	if masque_actif:
		masque_actif.show()
		# On s'assure qu'on remet le material si le debug l'avait enlevé
		# (Note: Tu devras réassigner tes materials dans l'inspecteur si tu as sauvegardé pendant le debug)

	show()
	move_to_front()

func _cacher_tous_les_masques():
	if mask_commun: mask_commun.hide()
	if mask_rare: mask_rare.hide()
	if mask_epique: mask_epique.hide()
	if mask_leg: mask_leg.hide()
	if mask_mythique: mask_mythique.hide()

func _get_couleur_par_tier(tier: int) -> Color:
	if tier == 1: return Color(0.7,0.7,0.7)
	if tier == 2: return Color(0,1,0)
	if tier == 3: return Color(0,0.5,1)
	if tier == 4: return Color(0.6,0,1)
	if tier == 5: return Color(1,0.8,0)
	return Color.WHITE

func _on_bouton_retour_pressed(): self.visible = false
func _on_equip_button_pressed():
	if current_displayed_item: demande_equipement.emit(current_displayed_item); self.visible = false