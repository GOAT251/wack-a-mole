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
	
	# Config Carte
	custom_minimum_size = taille_carte_fixe
	size = taille_carte_fixe
	
	# RÉPARATION AUTOMATIQUE (Si duplication)
	if vrai_bouton_gemme == null:
		for enfant in get_children():
			if enfant.name != "PointInterrogation" and enfant.name != "ParticulesExplosion" and enfant.name != "AudioReveal":
				vrai_bouton_gemme = enfant
				break

func setup(bouton_gemme, data):
	vrai_bouton_gemme = bouton_gemme
	data_memoire = data
	add_child(vrai_bouton_gemme)
	
	# --- CORRECTION ICI : GESTION SANS RARETÉ ---
	var index = 0 # Par défaut : 0 (Commun / Gris)
	
	# On vérifie si la donnée possède la propriété "rarete" (Gemmes)
	if "rarete" in data:
		index = data.rarete - 1
	
	# Si c'est un Marteau (pas de rareté), ça restera 0 (Gris)
	# ---------------------------------------------

	if has_node("PointInterrogation") and index >= 0 and index < icones_rarete.size():
		$PointInterrogation.texture = icones_rarete[index]
	
	# 2. On cache le bouton gemme pour l'instant
	vrai_bouton_gemme.hide()
	vrai_bouton_gemme.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func _on_pressed():
	if est_revele: return
	est_revele = true
	
	# Signal pour le panel
	carte_ouverte.emit()
	
	# Son
	if audio_player and audio_player.stream:
		audio_player.play()
	
	var tween = create_tween()
	
	# 1. Fermeture
	tween.tween_property(self, "scale:x", 0.0, 0.15)
	
	# 2. Changement et Layout
	tween.tween_callback(func():
		# On cache le dos
		self.texture_normal = null 
		if has_node("PointInterrogation"): $PointInterrogation.hide()
		
		if vrai_bouton_gemme:
			vrai_bouton_gemme.show()
			vrai_bouton_gemme.mouse_filter = Control.MOUSE_FILTER_STOP
			
			_appliquer_layout_force()
			
			# Update visuel
			if vrai_bouton_gemme.has_method("update_visuals"):
				vrai_bouton_gemme.update_visuals()
				
			# Effets visuels
			_lancer_effets_speciaux()
		else:
			printerr("🔴 ERREUR : Le bouton gemme est introuvable !")
	)
	
	# 3. Ouverture
	tween.tween_property(self, "scale:x", 1.0, 0.15)

func _appliquer_layout_force():
	# 1. RESET TOTAL
	vrai_bouton_gemme.set_anchors_preset(Control.PRESET_TOP_LEFT)
	vrai_bouton_gemme.position = Vector2.ZERO
	vrai_bouton_gemme.rotation = 0
	vrai_bouton_gemme.scale = Vector2.ONE
	vrai_bouton_gemme.pivot_offset = Vector2.ZERO
	
	# 2. SUPPRESSION DES CONTRAINTES DE TAILLE
	var taille_originale_souhaitee = Vector2(300, 300) 
	if vrai_bouton_gemme.size.x > 1:
		taille_originale_souhaitee = vrai_bouton_gemme.size
	
	vrai_bouton_gemme.custom_minimum_size = Vector2.ZERO
	vrai_bouton_gemme.size = taille_originale_souhaitee 
	
	# 3. CALCUL DU RATIO (Fit to Box)
	var ratio_x = self.size.x / taille_originale_souhaitee.x
	var ratio_y = self.size.y / taille_originale_souhaitee.y
	var ratio = min(ratio_x, ratio_y)
	
	# Ratio 1.0 pour remplir 100% de la carte
	ratio = ratio * 1.0
	
	# 4. APPLICATION
	vrai_bouton_gemme.scale = Vector2(ratio, ratio)
	
	# 5. CENTRAGE
	var taille_visuelle = taille_originale_souhaitee * ratio
	var espace_libre = self.size - taille_visuelle
	vrai_bouton_gemme.position = espace_libre / 2

func _lancer_effets_speciaux():
	if data_memoire == null: return
	
	# --- GESTION DES PARTICULES ---
	if particules:
		print("--- LANCEMENT PARTICULES (Rareté: ", data_memoire.rarete, ") ---")
		
		# 1. RESET COMPLET
		particules.color = Color.WHITE
		particules.hue_variation_min = 0.0
		particules.hue_variation_max = 0.0
		particules.color_ramp = null
		# Pour Godot 4
		if "color_initial_ramp" in particules:
			particules.color_initial_ramp = null
		
		var couleur = Color.WHITE
		var est_arc_en_ciel = false
		var doit_exploser = false
		
		if data_memoire.rarete == 5: # Mythique -> ARC EN CIEL 🌈
			print("   > Mode : MYTHIQUE (Gradient Arc-en-ciel)")
			est_arc_en_ciel = true
			doit_exploser = true
			
		elif data_memoire.rarete == 4: # Légendaire -> OR
			couleur = Color.GOLD
			doit_exploser = true
			
		elif data_memoire.rarete == 3: # Epique -> VIOLET
			couleur = Color.PURPLE
			doit_exploser = true
			
		elif data_memoire.rarete == 2: # Rare -> BLEU
			couleur = Color.BLUE
			doit_exploser = true
			
		if doit_exploser:
			# Layout
			particules.top_level = true 
			particules.global_position = self.get_global_rect().get_center()
			particules.z_index = 100 
			
			if est_arc_en_ciel:
				# --- CRÉATION DU GRADIENT ARC-EN-CIEL ---
				var gradient = Gradient.new()
				# On définit les points (Offset 0 à 1, Couleur)
				gradient.set_color(0, Color.RED)
				gradient.add_point(0.15, Color.ORANGE)
				gradient.add_point(0.3, Color.YELLOW)
				gradient.add_point(0.5, Color.GREEN)
				gradient.add_point(0.7, Color.CYAN)
				gradient.add_point(0.85, Color.BLUE)
				gradient.add_point(1.0, Color.MAGENTA)
				
				# On l'applique. 
				# Si tu es sur Godot 4 : color_initial_ramp (Couleur fixe à la naissance)
				# Si tu es sur Godot 3 : color_ramp (La couleur changera pendant la vie de la particule)
				if "color_initial_ramp" in particules:
					particules.color_initial_ramp = gradient
				else:
					particules.color_ramp = gradient
				
				particules.color = Color.WHITE # Important pour que le gradient se voie
			else:
				# Cas Normal (Une seule couleur)
				particules.color = couleur
			
			particules.restart()
			particules.emitting = true
	
	# --- SHAKE (Inchangé) ---
	if data_memoire.rarete >= 3:
		var shake = create_tween()
		var pos_actuelle = vrai_bouton_gemme.position
		var force = 5.0
		if data_memoire.rarete >= 4: force = 10.0
		
		for i in range(5):
			var decalage = Vector2(randf_range(-force, force), randf_range(-force, force))
			shake.tween_property(vrai_bouton_gemme, "position", pos_actuelle + decalage, 0.05)
		
		shake.tween_property(vrai_bouton_gemme, "position", pos_actuelle, 0.05)
