extends Node

signal lives_updated(new_lives)
signal no_more_lives

var lives = 3

func remove_lives(amount):
	lives -= amount
	if lives < 0:
		lives = 0
	
	emit_signal("lives_updated", lives)
	
	if lives <= 0:
		emit_signal("no_more_lives")

func reset():
	lives = 3
	emit_signal("lives_updated", lives)