extends TextureButton

@export var icones_rarete: Array[Texture2D]

var vrai_bouton_gemme: Control = null
var est_revele = false

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	pressed.connect(_on_pressed)
	
	# Le pivot au centre est nécessaire pour l'effet de retournement
	pivot_offset = size / 2 
	
	# RÉPARATION POST-DUPLICATION (Vital car ResultatTirage fait .duplicate())
	if vrai_bouton_gemme == null:
		for enfant in get_children():
			if enfant.name != "PointInterrogation":
				vrai_bouton_gemme = enfant
				print("[DEBUG] Enfant retrouvé : ", enfant.name)
				break

func setup(bouton_gemme, data):
	# print("[DEBUG] Setup de la carte pour : ", data.nom)
	vrai_bouton_gemme = bouton_gemme
	add_child(vrai_bouton_gemme)
	
	# 1. Image du ?
	var index = data.rarete - 1
	if has_node("PointInterrogation") and index >= 0 and index < icones_rarete.size():
		$PointInterrogation.texture = icones_rarete[index]
	
	# 2. On cache le bouton gemme pour l'instant
	vrai_bouton_gemme.hide()
	vrai_bouton_gemme.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_pressed():
	if est_revele: return
	est_revele = true
	
	var tween = create_tween()
	
	# 1. Fermeture
	tween.tween_property(self, "scale:x", 0.0, 0.15)
	
	# 2. Le Changement
	tween.tween_callback(func():
		# On cache le dos
		self.texture_normal = null 
		if has_node("PointInterrogation"): $PointInterrogation.hide()
		
		if vrai_bouton_gemme:
			vrai_bouton_gemme.show()
			vrai_bouton_gemme.mouse_filter = Control.MOUSE_FILTER_STOP
			
			# ==========================================================
			# CENTRAGE ET SCALE (FIT TO BOX)
			# ==========================================================
			
			# 1. RESET TOTAL
			vrai_bouton_gemme.set_anchors_preset(Control.PRESET_TOP_LEFT)
			vrai_bouton_gemme.position = Vector2.ZERO
			vrai_bouton_gemme.rotation = 0
			vrai_bouton_gemme.scale = Vector2.ONE
			vrai_bouton_gemme.pivot_offset = Vector2.ZERO
			
			# 2. SUPPRESSION DES CONTRAINTES DE TAILLE
			# On récupère la taille qu'il voudrait avoir
			var taille_originale_souhaitee = Vector2(300, 300) 
			if vrai_bouton_gemme.size.x > 1:
				taille_originale_souhaitee = vrai_bouton_gemme.size
			
			# On lui interdit d'imposer sa taille
			vrai_bouton_gemme.custom_minimum_size = Vector2.ZERO
			vrai_bouton_gemme.size = taille_originale_souhaitee 
			
			# 3. CALCUL DU RATIO
			# On compare la taille de la carte à la taille du bouton
			var ratio_x = self.size.x / taille_originale_souhaitee.x
			var ratio_y = self.size.y / taille_originale_souhaitee.y
			var ratio = min(ratio_x, ratio_y)
			
			# --- MODIFICATION ICI : 1.0 POUR 100% DE LA TAILLE ---
			ratio = ratio * 1.0
			# -----------------------------------------------------
			
			# 4. APPLICATION SCALE
			vrai_bouton_gemme.scale = Vector2(ratio, ratio)
			
			# 5. CENTRAGE
			var taille_visuelle = taille_originale_souhaitee * ratio
			var espace_libre = self.size - taille_visuelle
			vrai_bouton_gemme.position = espace_libre / 2
			
			# Update visuel
			if vrai_bouton_gemme.has_method("update_visuals"):
				vrai_bouton_gemme.update_visuals()
				
		else:
			printerr("🔴 ERREUR : Le bouton gemme est introuvable !")
	)
	
	# 3. Ouverture
	tween.tween_property(self, "scale:x", 1.0, 0.15)
