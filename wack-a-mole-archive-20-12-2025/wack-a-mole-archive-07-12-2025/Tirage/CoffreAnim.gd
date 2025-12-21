extends TextureButton

@export var img_ouvert: Texture2D
@onready var img_ferme = texture_normal

# --- RÉFÉRENCE VISUELLE (Lumière) ---
@onready var glow_effect = $GlowEffect

# --- PROBABILITÉS DU COFFRE (Pour le tirage du Panel) ---
@export var chance_commune: float = 50.0
@export var chance_rare: float = 30.0
@export var chance_epique: float = 15.0
@export var chance_legendaire: float = 5.0
@export var chance_mythique: float = 0.0

var est_ouvert = false

func _ready():
	# 1. Pivot en bas pour l'écrasement
	pivot_offset = size / 2
	pivot_offset.y = size.y
	
	# 2. Config Lumière
	if glow_effect:
		glow_effect.hide()
		glow_effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Pivot au milieu pour l'explosion
		glow_effect.pivot_offset = glow_effect.size / 2
	
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

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
	
	# --- L'ANIMATION JUICY ---
	var tween = create_tween()
	
	# 1. Écrasement
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.1)
	
	# 2. Changement d'image + Lumière
	tween.tween_callback(changer_visuel_ouverture)
	
	# 3. Rebond
	tween.tween_property(self, "scale", Vector2(0.9, 1.1), 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# 4. Retour normale
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
	
	# --- 5. APPEL DU PANEL (Une fois l'anim finie) ---
	tween.tween_callback(func():
		# On appelle le script principal (Tirage) pour qu'il génère les 6 gemmes
		if owner.has_method("generer_tirage_pour_coffre"):
			owner.generer_tirage_pour_coffre(self)
		else:
			print("ERREUR : Le script principal (Tirage.gd) n'a pas la fonction requis")
	)

# --- FONCTION VISUELLE ---
func changer_visuel_ouverture():
	texture_normal = img_ouvert
	
	# Animation de l'explosion de lumière
	if glow_effect:
		glow_effect.show()
		glow_effect.scale = Vector2(0, 0)
		glow_effect.modulate.a = 0
		
		var t_glow = create_tween()
		t_glow.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t_glow.parallel().tween_property(glow_effect, "scale", Vector2(1.5, 1.5), 0.5)
		t_glow.parallel().tween_property(glow_effect, "modulate:a", 1.0, 0.3)
