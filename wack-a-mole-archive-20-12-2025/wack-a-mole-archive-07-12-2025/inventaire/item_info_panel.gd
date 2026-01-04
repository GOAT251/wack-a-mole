extends Control

# --- RÉFÉRENCES UI ---
@onready var equip_button = $EquipButton
@onready var bouton_retour = $Fond/BoutonRetour
@onready var name_label = $Fond/NameLabel
@onready var icon_display = $Fond/IconImage
@onready var description_label = $Fond/DescriptionLabel
@onready var container_labels = $Fond/StatsContainer

# --- SYSTÈME LEVEL UP ---
@onready var level_up_button = $Fond/BoutonLevelUp
@onready var label_cout_upgrade = $Fond/BoutonLevelUp/LabelCoutUpgrade

# --- SYSTÈME DE LOCK ---
@onready var fond_lock = $Fond/FondLock
@onready var unlock_button = $Fond/FondLock/BoutonUnlock 
@onready var label_current = $Fond/FondLock/LabelCurrent
@onready var label_max = $Fond/FondLock/LabelMax

# --- IMAGES SHARDS ---
@onready var img_shard_1 = $Fond/imageshard1
@onready var img_shard_2 = $Fond/imageshard2

# --- CONFIGURATION ---
const LARGEUR_COLONNE_NOM = 220.0
const PRIX_DEBLOCAGE = 20

@export var fichier_regles: GemGenRules 
@export var materiau_mythique: ShaderMaterial 
@export var scene_shard: PackedScene

var current_displayed_item: UnlockableItemData = null

func _ready():
	if equip_button: equip_button.pressed.connect(_on_equip_pressed)
	if bouton_retour: bouton_retour.pressed.connect(_on_bouton_retour_pressed)
	if unlock_button: unlock_button.pressed.connect(_on_unlock_pressed)
	if level_up_button: level_up_button.pressed.connect(_on_level_up_pressed)
	hide()

func show_with_data(data: UnlockableItemData):
	self.visible = true
	current_displayed_item = data
	
	if name_label: name_label.text = data.item_name
	if icon_display: icon_display.texture = data.icon
	if description_label: description_label.text = data.description
	
	_update_etat_verrouillage()
	_generer_affichage_stats()

func _update_etat_verrouillage():
	var shards = PlayerData.get_nombre_shards(current_displayed_item.item_name)
	
	if current_displayed_item.is_unlocked:
		# --- ÉTAT DÉBLOQUÉ ---
		if fond_lock: fond_lock.hide()
		if img_shard_1: img_shard_1.hide()
		if img_shard_2: img_shard_2.hide()
		equip_button.show()
		equip_button.disabled = false
	else:
		# --- ÉTAT VERROUILLÉ ---
		if fond_lock: fond_lock.show()
		_afficher_shard_sur(img_shard_1)
		_afficher_shard_sur(img_shard_2)
		equip_button.hide()
		
		# COLORATION VERT/ROUGE DES SHARDS (REMISE ICI)
		if label_current:
			label_current.text = str(shards)
			label_current.modulate = Color.GREEN if shards >= PRIX_DEBLOCAGE else Color.RED
		if label_max: 
			label_max.text = str(PRIX_DEBLOCAGE)
		
		if unlock_button:
			unlock_button.disabled = (shards < PRIX_DEBLOCAGE)
			unlock_button.modulate = Color(1, 0.85, 0) if shards >= PRIX_DEBLOCAGE else Color(0.5, 0.5, 0.5)

	# --- MISE À JOUR BOUTON LEVEL UP ---
	if level_up_button and label_cout_upgrade:
		if current_displayed_item.current_level >= current_displayed_item.MAX_LEVEL:
			label_cout_upgrade.text = "MAX"
			level_up_button.modulate = Color(0.5, 0.5, 0.5)
		else:
			var cout = current_displayed_item.get_upgrade_cost()
			label_cout_upgrade.text = str(cout)
			# Couleur dynamique pour le bouton d'amélioration
			level_up_button.modulate = Color.WHITE if shards >= cout else Color(1, 0.4, 0.4)

func _generer_affichage_stats():
	if not container_labels: return
	var labels = container_labels.get_children()
	for l in labels: l.hide(); l.text = ""; for child in l.get_children(): child.queue_free()
	
	var liste_stats = _preparer_stats_marteau(current_displayed_item)
	
	for i in range(liste_stats.size()):
		if i >= labels.size(): break
		var info_stat = liste_stats[i]; var slot = labels[i]; slot.show(); slot.custom_minimum_size.y = 35 
		var hbox = HBoxContainer.new(); hbox.set_anchors_preset(15); hbox.add_theme_constant_override("separation", 10) 
		var lbl_nom = Label.new(); lbl_nom.horizontal_alignment = 2; lbl_nom.custom_minimum_size.x = LARGEUR_COLONNE_NOM; lbl_nom.modulate = Color(0.8, 0.8, 0.8); lbl_nom.text = info_stat.nom + " :"
		var lbl_val = RichTextLabel.new(); lbl_val.bbcode_enabled = true; lbl_val.fit_content = true; lbl_val.scroll_active = false; lbl_val.size_flags_horizontal = 3; lbl_val.size_flags_vertical = 4
		hbox.add_child(lbl_nom); hbox.add_child(lbl_val); slot.add_child(hbox)
		
		if info_stat.tier == 5:
			if materiau_mythique: lbl_val.material = materiau_mythique; lbl_val.text = info_stat.valeur 
			else: lbl_val.text = "[rainbow]" + info_stat.valeur + "[/rainbow]"
		else: lbl_val.text = "[color=" + info_stat.couleur + "]" + info_stat.valeur + "[/color]"

func _preparer_stats_marteau(data: UnlockableItemData) -> Array:
	var liste = []
	var m = data.get_level_multiplier() 
	
	# RESTAURATION DE TOUTES LES STATS
	if data.flat_damage > 0: liste.append(_analyser("flat_damage", "Dégâts Bruts", int(data.flat_damage * m), false))
	if data.damage_bonus_percent > 0: liste.append(_analyser("damage_bonus_percent", "% Dégâts", data.damage_bonus_percent * m, true))
	if data.swing_speed != 1.0: liste.append(_analyser("swing_speed", "Vitesse Frappe", abs((data.swing_speed-1)*100) * m, true, "+"))
	if data.crit_rate > 0: liste.append(_analyser("crit_rate", "Critique", (data.crit_rate * m)*100, true))
	if data.crit_damage > 1.5: liste.append(_analyser("crit_damage", "Dégâts Crit.", (data.crit_damage * m)*100, true))
	if data.flat_score_bonus > 0: liste.append(_analyser("flat_score_bonus", "Points Bonus", int(data.flat_score_bonus * m), false))
	if data.score_multiplier > 1.0: liste.append(_analyser("score_multiplier", "Multiplicateur", data.score_multiplier * m, true, "x", false))
	if data.golden_mole_luck > 0: liste.append(_analyser("golden_mole_luck", "Chance Dorée", (data.golden_mole_luck * m)*100, true))
	
	return liste

func _analyser(key, nom, val, pct, signe="+", show_pct=true) -> Dictionary:
	var tier = 1
	if fichier_regles:
		var cfg = _trouver_config(key)
		if cfg:
			if val >= cfg.t5.x: tier = 5
			elif val >= cfg.t4.x: tier = 4
			elif val >= cfg.t3.x: tier = 3
			elif val >= cfg.t2.x: tier = 2
	
	var col = "#00FF00"
	if tier == 2: col = "#0088FF"
	elif tier == 3: col = "#AA00FF"
	elif tier == 4: col = "#FFD700"
	elif tier == 5: col = "#FF4400"
	
	var txt = signe + str(val) + ("%" if pct and show_pct else "")
	return {"nom": nom, "valeur": txt, "couleur": col, "tier": tier}

func _on_level_up_pressed():
	if PlayerData.upgrade_marteau(current_displayed_item):
		show_with_data(current_displayed_item) # Rafraîchit tout avec les nouveaux chiffres

func _on_unlock_pressed():
	if PlayerData.depenser_shards(current_displayed_item.item_name, PRIX_DEBLOCAGE):
		current_displayed_item.is_unlocked = true
		show_with_data(current_displayed_item)

func _on_equip_pressed():
	PlayerData.equipped_hammer = current_displayed_item
	PlayerData.recalculer_stats_joueur()
	self.visible = false

func _trouver_config(key):
	if fichier_regles.stat_fixe.key == key: return fichier_regles.stat_fixe
	for c in fichier_regles.pool_basique: if c.key == key: return c
	for c in fichier_regles.pool_bonus: if c.key == key: return c
	return null

func _afficher_shard_sur(parent_node: Control):
	if parent_node == null or scene_shard == null: return
	parent_node.show()
	for child in parent_node.get_children(): child.queue_free()
	var shard = scene_shard.instantiate()
	if shard.has_method("setup"): shard.setup(current_displayed_item)
	parent_node.add_child(shard)
	shard.set_anchors_preset(Control.PRESET_FULL_RECT)

func _on_bouton_retour_pressed(): self.visible = false
