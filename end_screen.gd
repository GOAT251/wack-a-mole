extends CanvasLayer

signal restart_game
signal next_level

@onready var message_label = $ColorRect/EndMessageLabel
@onready var restart_button = $ColorRect/RestartButton
@onready var next_level_button = $ColorRect/NextLevelButton


func _ready():
	if restart_button:
		restart_button.pressed.connect(_on_restart_button_pressed)
	if next_level_button:
		next_level_button.pressed.connect(_on_next_level_button_pressed)


func set_message(did_win, has_next_level):
	if restart_button: restart_button.visible = false
	if next_level_button: next_level_button.visible = false
	
	if did_win:
		if message_label: message_label.text = "Niveau Réussi !"
		if has_next_level and next_level_button:
			next_level_button.visible = true
		else:
			if message_label: message_label.text = "Félicitations, jeu terminé !"
			if restart_button: restart_button.visible = true
	else:
		if message_label: message_label.text = "Game Over"
		if restart_button: restart_button.visible = true


func _on_restart_button_pressed():
	# ESPION N°1
	print("--- DANS end_screen.gd: Clic sur le bouton Recommencer ! Émission du signal 'restart_game'.")
	emit_signal("restart_game")
	queue_free()


func _on_next_level_button_pressed():
	# ESPION N°2
	print("--- DANS end_screen.gd: Clic sur le bouton Niveau Suivant ! Émission du signal 'next_level'.")
	emit_signal("next_level")
	queue_free()