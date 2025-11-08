extends Node

signal time_updated(new_time)
signal time_is_up

var time_left = 0
@onready var timer = Timer.new()

func _ready():
	# On configure le timer principal du jeu (celui qui fait "tic-tac")
	timer.wait_time = 1.0
	timer.timeout.connect(_on_second_passed)
	add_child(timer)

func start_countdown(duration):
	time_left = duration
	emit_signal("time_updated", time_left)
	timer.start()

func stop_countdown():
	timer.stop()

func reset():
	timer.stop()
	time_left = 0
	emit_signal("time_updated", time_left)

func _on_second_passed():
	time_left -= 1
	emit_signal("time_updated", time_left)
	if time_left <= 0:
		timer.stop()
		emit_signal("time_is_up")