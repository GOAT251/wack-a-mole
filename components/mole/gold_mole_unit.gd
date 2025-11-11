extends Area2D

signal hit

@onready var appear_player = $AnimationAppearGoldMoleUnit
@onready var disappear_player = $AnimationDisappearGoldMoleUnit
@onready var sprite = $GoldMoleSprite
@onready var collision = $GoldMoleCollision
@onready var collision_timer = $CollisionActivationTimer

func _ready():
	input_event.connect(_on_input_event)
	disappear_player.animation_finished.connect(_on_animation_finished)
	collision_timer.timeout.connect(enable_collision)
	sprite.visible = false

func appear():
	disappear_player.stop()
	sprite.visible = true
	set_collision_state(false)
	collision_timer.start(0.1)
	appear_player.play("appear")

func disappear():
	appear_player.stop()
	collision_timer.stop()
	set_collision_state(false)
	disappear_player.play("disappear")

func enable_collision():
	set_collision_state(true)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("hit")

func _on_animation_finished(anim_name):
	if anim_name == "disappear":
		sprite.visible = false

func set_collision_state(is_enabled: bool):
	collision.disabled = not is_enabled
