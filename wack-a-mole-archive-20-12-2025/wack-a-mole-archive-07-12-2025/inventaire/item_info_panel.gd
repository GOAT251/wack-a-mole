extends Control

# --- RÉFÉRENCES ---
@onready var equip_button = $EquipButton
@onready var bouton_retour = $Fond/BoutonRetour
@onready var name_label = $Fond/NameLabel
@onready var icon_display = $Fond/IconImage
@onready var description_label = $Fond/DescriptionLabel
@onready var container_labels = $Fond/StatsContainer

var current_displayed_item: UnlockableItemData = null
const LARGEUR_COLONNE_NOM = 220.0

# --- CONFIGURATION (DRAG & DROP) ---
@export var fichier_regles: GemGenRules 

# AJOUT : Glisse ton "Mat_TexteMythique.tres" ici !
@export var materiau_mythique: ShaderMaterial 

func _ready():
	if equip_button: equip_button.pressed.connect(_on_equip_button_pressed)
	if bouton_retour: bouton_retour.pressed.connect(_on_bouton_retour_pressed)
	hide()
	
	if fichier_regles == null:
		printerr("⚠️ Attention : 'ReglesGemmes.tres' n'est pas assigné dans ItemInfoPanel.")

func show_with_data(data: UnlockableItemData):
	self.visible = true
	current_displayed_item = data
	
	if name_label: name_label.text = data.item_name
	if icon_display: icon_display.texture = data.icon
	if description_label: description_label.text = data.description
	
	if equip_button:
		equip_button.disabled = false
		equip_button.modulate = Color.WHITE

	# GÉNÉRATION DES STATS
	if container_labels:
		var labels = container_labels.get_children()
		
		# NETTOYAGE
		for l in labels: 
			l.hide(); l.text = ""; for child in l.get_children(): child.queue_free()
		
		# CALCUL
		var liste_stats = _preparer_stats_marteau(data)
		
		# REMPLISSAGE
		for i in range(liste_stats.size()):
			if i >= labels.size(): break
			var info_stat = liste_stats[i]
			var slot_parent = labels[i]
			slot_parent.show()
			slot_parent.custom_minimum_size.y = 35 
			
			var hbox = HBoxContainer.new()
			hbox.name = "AlignementBox"
			hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
			hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
			hbox.add_theme_constant_override("separation", 10) 
			
			var lbl_nom = Label.new()
			lbl_nom.name = "Nom"
			lbl_nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			lbl_nom.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl_nom.custom_minimum_size.x = LARGEUR_COLONNE_NOM
			lbl_nom.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			lbl_nom.modulate = Color(0.8, 0.8, 0.8)
			
			var lbl_val = RichTextLabel.new()
			lbl_val.name = "Valeur"
			lbl_val.bbcode_enabled = true
			lbl_val.fit_content = true
			lbl_val.scroll_active = false
			lbl_val.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lbl_val.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			
			# STYLE
			var font_perso = slot_parent.get_theme_font("normal_font")
			var size_perso = slot_parent.get_theme_font_size("normal_font_size")
			if font_perso == null: font_perso = slot_parent.get_theme_font("font")
			if size_perso <= 0: size_perso = slot_parent.get_theme_font_size("font_size")
			
			if font_perso:
				lbl_nom.add_theme_font_override("font", font_perso); lbl_val.add_theme_font_override("normal_font", font_perso)
			if size_perso > 0:
				lbl_nom.add_theme_font_size_override("font_size", size_perso); lbl_val.add_theme_font_size_override("normal_font_size", size_perso)
			
			# TEXTE NOM
			lbl_nom.text = info_stat.nom + " :"
			
			# --- GESTION COULEUR / SHADER ---
			lbl_val.material = null # Reset important !
			
			if info_stat.tier == 5:
				# CAS MYTHIQUE : ON APPLIQUE LE SHADER
				if materiau_mythique:
					lbl_val.material = materiau_mythique
					# Texte blanc pur pour laisser le shader faire les couleurs
					lbl_val.text = info_stat.valeur 
				else:
					# Fallback si tu as oublié de glisser le shader
					lbl_val.text = "[rainbow freq=0.5 sat=0.8 val=1.0]" + info_stat.valeur + "[/rainbow]"
			else:
				# CAS NORMAL
				var couleur_hex = info_stat.couleur
				lbl_val.text = "[color=" + couleur_hex + "]" + info_stat.valeur + "[/color]"
			
			hbox.add_child(lbl_nom); hbox.add_child(lbl_val); slot_parent.add_child(hbox)

# --- CONVERTISSEUR INTELLIGENT ---
func _preparer_stats_marteau(data: UnlockableItemData) -> Array:
	var liste = []
	
	if data.flat_damage > 0:
		liste.append(_analyser_stat("flat_damage", "Dégâts Bruts", data.flat_damage, false))
	if data.damage_bonus_percent > 0:
		liste.append(_analyser_stat("damage_bonus_percent", "% Dégâts", data.damage_bonus_percent, true))
	if data.swing_speed != 1.0:
		var val = (data.swing_speed - 1.0) * 100
		var signe = "+" if val > 0 else ""
		liste.append(_analyser_stat("swing_speed", "Vitesse Frappe", abs(val), true, signe))
	if data.crit_rate > 0:
		liste.append(_analyser_stat("crit_rate", "Critique", data.crit_rate * 100, true))
	if data.crit_damage > 1.5:
		liste.append(_analyser_stat("crit_damage", "Dégâts Crit.", data.crit_damage * 100, true, "", false))
	if data.flat_score_bonus > 0:
		liste.append(_analyser_stat("flat_score_bonus", "Points Bonus", data.flat_score_bonus, false))
	if data.score_multiplier > 1.0:
		liste.append(_analyser_stat("score_multiplier", "Multiplicateur", data.score_multiplier, true, "x", false))
	if data.golden_mole_luck > 0:
		liste.append(_analyser_stat("golden_mole_luck", "Chance Dorée", data.golden_mole_luck, true))
		
	return liste

# --- COMPARATEUR ---
func _analyser_stat(key: String, nom_affich: String, valeur: float, is_percent: bool, signe_force: String = "+", afficher_pourcent: bool = true) -> Dictionary:
	var tier = 1 
	var couleur = "#00FF00" # Vert par défaut
	
	if fichier_regles:
		var config = _trouver_config_dans_rules(key)
		if config:
			if valeur >= config.t5.x: tier = 5
			elif valeur >= config.t4.x: tier = 4
			elif valeur >= config.t3.x: tier = 3
			elif valeur >= config.t2.x: tier = 2
			else: tier = 1
	
	match tier:
		1: couleur = "#00FF00" # Vert
		2: couleur = "#0088FF" # Bleu
		3: couleur = "#AA00FF" # Violet
		4: couleur = "#FFD700" # Or
		5: couleur = "#FFFFFF" # Blanc (Base pour le Shader)
	
	var val_str = signe_force + str(valeur)
	if is_percent and afficher_pourcent: val_str += "%"
	
	return { "nom": nom_affich, "valeur": val_str, "couleur": couleur, "tier": tier }

func _trouver_config_dans_rules(key: String):
	if fichier_regles.stat_fixe.key == key: return fichier_regles.stat_fixe
	for c in fichier_regles.pool_basique:
		if c.key == key: return c
	for c in fichier_regles.pool_bonus:
		if c.key == key: return c
	return null

func _on_bouton_retour_pressed(): self.visible = false
func _on_equip_button_pressed():
	if current_displayed_item and PlayerData:
		PlayerData.equipped_hammer = current_displayed_item
		print("Succès : Marteau équipé")
		self.visible = false