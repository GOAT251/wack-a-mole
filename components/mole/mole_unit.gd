# Dans MoleUnit.gd (et tous les autres)

extends Area2D

signal hit

@onready var appear_player = $AnimationAppearMole
@onready var disappear_player = $AnimationDisappearMole
@onready var sprite = $MoleSprite
@onready var collision = $MoleCollision
# --- AJOUT : Référence au nouveau timer ---
@onready var collision_timer = $CollisionActivationTimer

func _ready():
	input_event.connect(_on_input_event)
	disappear_player.animation_finished.connect(_on_animation_finished)
	# --- AJOUT : On connecte le signal du timer ---
	collision_timer.timeout.connect(enable_collision)
	
	sprite.visible = false

func appear():
	disappear_player.stop()
	sprite.visible = true
	
	# La collision est désactivée au début
	set_collision_state(false)
	# On demande au timer de s'activer dans 0.1s
	collision_timer.start(0.1)
	
	appear_player.play("appear")

func disappear():
	appear_player.stop()
	# On s'assure que le timer d'activation est arrêté
	collision_timer.stop()
	set_collision_state(false)
	disappear_player.play("disappear")

# --- NOUVELLE FONCTION ---
# Cette fonction est appelée par le timer après 0.1s.
func enable_collision():
	set_collision_state(true)

# ... (le reste du code ne change pas)
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("hit")

func _on_animation_finished(anim_name):
	if anim_name == "disappear":
		sprite.visible = false

func set_collision_state(is_enabled: bool):
	collision.disabled = not is_enabled