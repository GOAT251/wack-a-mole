extends TextureButton

signal level_selected(level_path)

@export var level_path: String = ""
@export var level_number: int = 1
@export var unlocked_texture: Texture2D
@export var locked_texture: Texture2D

@onready var label_node = $LevelNumberLabel

func _ready():
	# --- AJOUT CRUCIAL ICI ---
	# On connecte le signal "pressed" du bouton à notre fonction _on_pressed.
	# Sans cette ligne, le clic ne fait rien.
	pressed.connect(_on_pressed)

	if label_node:
		label_node.text = str(level_number)

func update_visuals(is_unlocked):
	if not label_node:
		return
		
	if is_unlocked:
		self.disabled = false
		self.texture_normal = unlocked_texture
		label_node.show()
	else:
		self.disabled = true
		self.texture_normal = locked_texture
		label_node.hide()

func _on_pressed():
	# Message de débogage pour voir si le clic est bien détecté.
	print("Icône cliquée ! J'envoie le signal 'level_selected' pour : ", level_path)
	emit_signal("level_selected", level_path)
