extends CanvasLayer

# Raccourcis vers les labels de cette scène.
@onready var score_label = $ScoreLabel
@onready var time_label = $TimeLabel

# Fonction pour mettre à jour le score, appelée par "main.gd".
func update_score(new_score):
	score_label.text = "Score: " + str(new_score)

# Fonction pour mettre à jour le temps, appelée par "main.gd".
func update_time(new_time):
	time_label.text = "Temps: " + str(new_time)
