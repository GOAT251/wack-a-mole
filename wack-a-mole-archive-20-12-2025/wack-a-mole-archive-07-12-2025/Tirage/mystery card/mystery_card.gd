extends TextureButton

# Signal pour déverrouiller le bouton fermer du panel
signal carte_ouverte

@export var icones_rarete: Array[Texture2D]

# --- NOEUDS EFFETS ---
@onready var particules = $ParticulesExplosion
@onready var audio_player = $AudioReveal

var vrai_bouton_gemme: Control = null
var est_revele = false
var data_memoire = null

# TAILLE FIXE DE LA CARTE (150x150)
var taille_carte_fixe = Vector2(150, 150) 

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	pressed.connect(_on_pressed)
	pivot_offset = size / 2 
	
	# RÉPARATION AUTOMATIQUE
	if vrai_bouton_gemme == null:
		for enfant in get_children():
			if enfant.name != "PointInterrogation" and enfant.name != "ParticulesExplosion" and enfant.name != "AudioReveal":
				vrai_bouton_gemme = enfant
				break

func setup(bouton_gemme, data):
	vrai_bouton_gemme = bouton_gemme
	data_memoire = data
	add_child(vrai_bouton_gemme)
	
	# Gestion image ? (Compatible Gemme et Marteau)
	var index = 0
	if "rarete" in data:
		index = data.rarete - 1
	elif data.get("rarete") != null: # Sécurité pour certains objets
		index = data.rarete - 1
	
	if has_node("PointInterrogation") and index >= 0 and index < icones_rarete.size():
		$PointInterrogation.texture = icones_rarete[index]
	
	vrai_bouton_gemme.hide()
	vrai_bouton_gemme.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func _on_pressed():
	if est_revele: return
	est_revele = true
	
	carte_ouverte.emit()
	
	if audio_player and audio_player.stream:
		audio_player.play()
	
	var tween = create_tween()
	
	# 1. Fermeture
	tween.tween_property(self, "scale:x", 0.0, 0.15)
	
	# 2. Changement et Layout
	tween.tween_callback(func():
		self.texture_normal = null 
		if has_node("PointInterrogation"): $PointInterrogation.hide()
		
		if vrai_bouton_gemme:
			vrai_bouton_gemme.show()
			vrai_bouton_gemme.mouse_filter = Control.MOUSE_FILTER_STOP
			
			_appliquer_layout_force()
			
			if vrai_bouton_gemme.has_method("update_visuals"):
				vrai_bouton_gemme.update_visuals()
				
			# ON LANCE LES EFFETS ICI
			_lancer_effets_speciaux()
		else:
			printerr("🔴 ERREUR : Le bouton gemme est introuvable !")
	)
	
	# 3. Ouverture
	tween.tween_property(self, "scale:x", 1.0, 0.15)

func _appliquer_layout_force():
	vrai_bouton_gemme.set_anchors_preset(Control.PRESET_TOP_LEFT)
	vrai_bouton_gemme.position = Vector2.ZERO
	vrai_bouton_gemme.rotation = 0
	vrai_bouton_gemme.scale = Vector2.ONE
	vrai_bouton_gemme.pivot_offset = Vector2.ZERO
	
	var taille_originale_souhaitee = Vector2(300, 300) 
	if vrai_bouton_gemme.size.x > 1:
		taille_originale_souhaitee = vrai_bouton_gemme.size
	
	vrai_bouton_gemme.custom_minimum_size = Vector2.ZERO
	vrai_bouton_gemme.size = taille_originale_souhaitee 
	
	var ratio_x = self.size.x / taille_originale_souhaitee.x
	var ratio_y = self.size.y / taille_originale_souhaitee.y
	var ratio = min(ratio_x, ratio_y) * 1.0
	
	vrai_bouton_gemme.scale = Vector2(ratio, ratio)
	
	var taille_visuelle = taille_originale_souhaitee * ratio
	var espace_libre = self.size - taille_visuelle
	vrai_bouton_gemme.position = espace_libre / 2

func _lancer_effets_speciaux():
	if data_memoire == null: 
		print("❌ Pas de data mémoire pour les effets.")
		return
	
	# On essaie de lire la rareté de façon souple
	var r = 1
	if "rarete" in data_memoire:
		r = data_memoire.rarete
	elif data_memoire.get("rarete") != null:
		r = data_memoire.get("rarete")
		
	# --- GESTION DES PARTICULES ---
	if particules:
		print("✨ Lancement particules pour Rareté : ", r)
		
		var couleur = Color.WHITE
		var est_arc_en_ciel = false
		var doit_exploser = false
		
		# Reset du mode Arc-en-ciel
		particules.hue_variation_min = 0
		particules.hue_variation_max = 0
		particules.color_ramp = null
		if "color_initial_ramp" in particules:
			particules.color_initial_ramp = null
		
		if r == 5: # Mythique -> ARC EN CIEL 🌈
			est_arc_en_ciel = true
			doit_exploser = true
		elif r == 4: # Légendaire -> OR
			couleur = Color.GOLD
			doit_exploser = true
		elif r == 3: # Epique -> VIOLET
			couleur = Color.PURPLE
			doit_exploser = true
		elif r == 2: # Rare -> BLEU
			couleur = Color.BLUE
			doit_exploser = true
		elif r == 1: # Commun -> BLANC/GRIS (Ajouté pour que tu voies l'effet !)
			couleur = Color(0.8, 0.8, 0.8, 0.5)
			doit_exploser = true
			
		if doit_exploser:
			particules.top_level = true 
			particules.global_position = self.get_global_rect().get_center()
			particules.z_index = 100 
			
			if est_arc_en_ciel:
				# Dégradé Arc-en-ciel manuel
				var gradient = Gradient.new()
				gradient.set_color(0, Color.RED)
				gradient.add_point(0.2, Color.YELLOW)
				gradient.add_point(0.4, Color.GREEN)
				gradient.add_point(0.6, Color.CYAN)
				gradient.add_point(0.8, Color.BLUE)
				gradient.add_point(1.0, Color.MAGENTA)
				
				if "color_initial_ramp" in particules:
					particules.color_initial_ramp = gradient
				else:
					particules.color_ramp = gradient
				particules.color = Color.WHITE
			else:
				particules.color = couleur
			
			particules.restart()
			particules.emitting = true
	else:
		print("❌ Noeud Particules introuvable.")
	
	# --- SHAKE ---
	if r >= 3:
		var shake = create_tween()
		var pos_actuelle = vrai_bouton_gemme.position
		var force = 5.0
		if r >= 4: force = 10.0
		
		for i in range(5):
			var decalage = Vector2(randf_range(-force, force), randf_range(-force, force))
			shake.tween_property(vrai_bouton_gemme, "position", pos_actuelle + decalage, 0.05)
		
		shake.tween_property(vrai_bouton_gemme, "position", pos_actuelle, 0.05)