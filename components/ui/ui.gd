extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var time_label = $TimeLabel
# NOUVEAU RACCOURCI vers notre conteneur de vies
@onready var lives_container = $LivesContainer


func update_score(new_score):
	score_label.text = "Score: " + str(new_score)

func update_time(new_time):
	time_label.text = "Temps: " + str(new_time)

# NOUVELLE FONCTION pour mettre à jour l'affichage des vies
func update_lives(current_lives):
	# On récupère tous les cœurs (nos TextureRects)
	var hearts = lives_container.get_children()
	
	# On boucle sur chaque cœur
	for i in hearts.size():
		if i < current_lives:
			# Si l'index du cœur est inférieur au nombre de vies, on le montre
			hearts[i].visible = true
		else:
			# Sinon, on le cache
			hearts[i].visible = false
