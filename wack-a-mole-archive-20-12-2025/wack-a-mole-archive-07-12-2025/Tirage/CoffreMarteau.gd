class_name CoffreMarteau
extends TextureButton

# --- VISUEL ---
@export_group("Visuel")
@export var img_ouvert: Texture2D
@onready var img_ferme = texture_normal
@onready var glow_effect = $GlowEffect

# --- CONFIGURATION DU LOOT ---
@export_group("Table de Loot (A remplir en parallèle)")
@export var liste_marteaux: Array[UnlockableItemData]
@export var liste_poids: Array[float] # Ex: 100.0, 50.0, 1.0

# --- LIAISON VISUELLE (C'est ça qu'il te manquait !) ---
@export_group("Liaison Visuelle")
# Écris ici le NOM EXACT du bouton dans HammerCollection (ex: "BoutonFeu")
@export var nom_bouton_ref: String = "" 

var est_ouvert = false

func _ready():
	pivot_offset = size / 2
	pivot_offset.y = size.y
	
	if glow_effect:
		glow_effect.hide()
		glow_effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glow_effect.pivot_offset = glow_effect.size / 2
	
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

# --- TIRAGE AU SORT PONDÉRÉ ---
func piocher_marteau_hasard() -> UnlockableItemData:
	# 1. Sécurité
	if liste_marteaux.size() == 0:
		printerr("ERREUR : Le coffre ", name, " est vide !")
		return null
		
	if liste_marteaux.size() != liste_poids.size():
		printerr("ERREUR CRITIQUE : Dans ", name, ", les listes Marteaux et Poids n'ont pas la même taille !")
		return liste_marteaux[0]

	# 2. Calcul du poids total
	var total_poids = 0.0
	for p in liste_poids:
		total_poids += p
	
	# 3. Le Tirage
	var roll = randf_range(0.0, total_poids)
	var cumul = 0.0
	
	# 4. Sélection du gagnant
	for i in range(liste_marteaux.size()):
		cumul += liste_poids[i]
		if roll <= cumul:
			return liste_marteaux[i]
			
	return liste_marteaux[0]

func reset_coffre():
	est_ouvert = false
	disabled = false
	texture_normal = img_ferme
	scale = Vector2(1, 1)
	if glow_effect: glow_effect.hide()

func _on_pressed():
	if est_ouvert: return
	est_ouvert = true
	disabled = true 
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.1)
	tween.tween_callback(changer_visuel_ouverture)
	tween.tween_property(self, "scale", Vector2(0.9, 1.1), 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
	
	tween.tween_callback(func():
		# On envoie 'self' (le coffre) au script principal
		if owner.has_method("generer_tirage_pour_coffre"):
			owner.generer_tirage_pour_coffre(self)
		else:
			print("ERREUR : Script Tirage manquant.")
	)

func changer_visuel_ouverture():
	if img_ouvert: texture_normal = img_ouvert
	if glow_effect:
		glow_effect.show()
		glow_effect.scale = Vector2(0, 0)
		glow_effect.modulate.a = 0
		var t = create_tween()
		t.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(glow_effect, "scale", Vector2(1.5, 1.5), 0.5)
		t.parallel().tween_property(glow_effect, "modulate:a", 1.0, 0.3)