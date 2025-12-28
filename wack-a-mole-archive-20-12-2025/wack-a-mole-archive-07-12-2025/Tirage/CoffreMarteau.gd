extends TextureButton

# --- VISUEL ---
@export_group("Visuel")
@export var img_ouvert: Texture2D
@onready var img_ferme = texture_normal
@onready var glow_effect = $GlowEffect

# --- CONTENU DU COFFRE (MARTEAUX) ---
@export_group("Table de Loot (Parallèle)")
@export var liste_marteaux: Array[UnlockableItemData]
@export var liste_poids: Array[float] 

# --- LIAISON VISUELLE ---
@export_group("Liaison Visuelle")
@export var nom_bouton_ref: String = "" 

# --- PROBABILITÉS RARETÉ ---
@export_group("Probabilités Rareté (Shards)")
@export var chance_commune: float = 50.0
@export var chance_rare: float = 30.0
@export var chance_epique: float = 15.0
@export var chance_legendaire: float = 4.0 # Or
@export var chance_mythique: float = 1.0   # Prismatique

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

# --- TIRAGE MARTEAU ---
func piocher_marteau_hasard() -> UnlockableItemData:
	if liste_marteaux.size() == 0:
		printerr("ERREUR : Le coffre ", name, " est vide !")
		return null
		
	if liste_marteaux.size() != liste_poids.size():
		printerr("ERREUR CRITIQUE : Listes Marteaux/Poids de tailles différentes !")
		return liste_marteaux[0]

	var total_poids = 0.0
	for p in liste_poids: total_poids += p
	
	var roll = randf_range(0.0, total_poids)
	var cumul = 0.0
	
	for i in range(liste_marteaux.size()):
		cumul += liste_poids[i]
		if roll <= cumul:
			return liste_marteaux[i]
			
	return liste_marteaux[0]

# --- FONCTION DE RÉSULTAT COMPLET (Celle que Tirage appelle) ---
func piocher_resultat_complet() -> Dictionary:
	var marteau = piocher_marteau_hasard()
	
	# Calcul de la rareté du tirage (pour la quantité et la couleur)
	var roll_rarete = randf_range(0.0, 100.0)
	var seuil = 0.0
	var rarete_resultat = 1
	
	seuil += chance_commune
	if roll_rarete < seuil: rarete_resultat = 1
	else:
		seuil += chance_rare
		if roll_rarete < seuil: rarete_resultat = 2
		else:
			seuil += chance_epique
			if roll_rarete < seuil: rarete_resultat = 3
			else:
				seuil += chance_legendaire
				if roll_rarete < seuil: rarete_resultat = 4
				else: rarete_resultat = 5

	return { "data": marteau, "rarete": rarete_resultat }

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
