extends CanvasLayer

# Raccourcis vers les labels qui sont DANS CETTE SCÈNE
@onready var score_label = $ScoreLabel
@onready var time_label = $TimeLabel

# Une fonction que la scène Main pourra appeler pour mettre à jour le score
func update_score(new_score):
	score_label.text = "Score: " + str(new_score)

# Une fonction que la scène Main pourra appeler pour mettre à jour le temps
func update_time(new_time):
	time_label.text = "Temps: " + str(new_time)
