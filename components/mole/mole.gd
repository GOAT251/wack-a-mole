extends Area2D

signal mole_hit
signal friend_hit
signal bomb_hit
signal gold_mole_hit

var is_active = false

@onready var units = {
	"mole": $MoleUnit,
	"friend": $FriendUnit,
	"bomb": $BombRoot,
	"gold_mole": $GoldMoleUnit
}

@onready var visibility_timer = $VisibilityTime
var current_unit = null
var status_manager: Node

func _ready():
	visibility_timer.timeout.connect(hide_target)
	
	for unit_type in units:
		var unit = units[unit_type]
		unit.hit.connect(_on_any_unit_hit.bind(unit_type))
		unit.disappeared.connect(_on_unit_disappeared)

func show_target(type):
	if is_active: return

	is_active = true
	current_unit = units[type]
	
	if type == "bomb" and status_manager:
		current_unit.status_manager = status_manager
		
	current_unit.show_unit()
	visibility_timer.start()

func hide_target():
	if not is_active or current_unit == null: return
	
	visibility_timer.stop()
	current_unit.hide_unit()

func _on_any_unit_hit(unit_type):
	emit_signal(unit_type + "_hit")
	hide_target()

func _on_unit_disappeared():
	current_unit = null
	is_active = false