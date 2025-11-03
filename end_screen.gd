extends CanvasLayer

signal restart_game

# Ces chemins correspondent à la structure où tout est DANS le ColorRect.
@onready var message_label = $ColorRect/EndMessageLabel
@onready var restart_button = $ColorRect/RestartButton


func _ready():
	# Ce 'if' est une sécurité. Si le bouton n'est pas trouvé, le jeu ne plantera pas.
	if restart_button:
		restart_button.pressed.connect(_on_restart_button_pressed)
	else:
		print("ERREUR: Le nœud 'RestartButton' est introuvable dans end_screen.tscn")


func set_message(did_win):
	# Ce 'if' est une sécurité.
	if message_label:
		if did_win:
			message_label.text = "Niveau Réussi !"
		else:
			message_label.text = "Game Over"
	else:
		print("ERREUR: Le nœud 'EndMessageLabel' est introuvable dans end_screen.tscn")


func _on_restart_button_pressed():
	emit_signal("restart_game")
	queue_free()
