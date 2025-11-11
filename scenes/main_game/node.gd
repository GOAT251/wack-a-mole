extends Node

signal score_updated(new_score)

var score = 0

func add_points(points):
	score += points
	emit_signal("score_updated", score)

func reset():
	score = 0
	emit_signal("score_updated", score)