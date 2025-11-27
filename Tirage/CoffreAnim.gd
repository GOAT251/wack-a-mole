extends TextureButton

@export var img_ouvert: Texture2D

@onready var img_ferme = texture_normal
@onready var icon_display = $IconDisplay 

var est_ouvert = false

func _ready():
	pivot_offset = size / 2
	pivot_offset.y = size.y
	
	if icon_display:
		icon_display.hide()
		icon_display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

func reset_coffre():
	est_ouvert = false
	disabled = false
	texture_normal = img_ferme
	scale = Vector2(1, 1)
	if icon_display: 
		icon_display.hide()

# --- LA FONCTION PRINCIPALE ---
func _on_pressed():
	if est_ouvert: return
	
	est_ouvert = true
	disabled = true 
	
	var tween = create_tween()
	
	# 1. On écrase
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.1)
	
	# 2. On change l'image (via une vraie fonction, plus de parenthèse qui traîne)
	tween.tween_callback(changer_image_ouverture)
	
	# 3. Rebond
	tween.tween_property(self, "scale", Vector2(0.9, 1.1), 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# 4. Retour normale
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
	
	# 5. Apparition gemme (via une vraie fonction aussi)
	tween.tween_callback(lancer_anim_gemme)

# --- LES NOUVELLES FONCTIONS SÉPARÉES ---
# (Plus propre, pas d'erreur de fin de fichier)

func changer_image_ouverture():
	texture_normal = img_ouvert

func lancer_anim_gemme():
	if icon_display:
		icon_display.show()
		icon_display.scale = Vector2(0,0)
		
		var t = create_tween()
		t.tween_property(icon_display, "scale", Vector2(1,1), 0.3).set_trans(Tween.TRANS_BACK)
