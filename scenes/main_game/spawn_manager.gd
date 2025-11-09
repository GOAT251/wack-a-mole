extends Node

# On a besoin de savoir où se trouvent les trous de taupes
@export var level_container: Node2D
# On a besoin de connaître les règles du niveau
@export var level_data: Node

@onready var spawn_timer = Timer.new()

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

func start_spawning():
	if not level_data or not level_container:
		printerr("SpawnManager: Level data or container not set!")
		return
	spawn_timer.wait_time = level_data.spawn_speed
	spawn_timer.start()

func stop_spawning():
	spawn_timer.stop()

func reset():
	spawn_timer.stop()
	level_data = null

func _on_spawn_timer_timeout():
	if not level_data: return

	var grid = level_container.get_child(0).get_node("GridContainer")
	var mole_holes = grid.get_children()
	var interactive_holes = []
	for hole in mole_holes:
		# On s'assure que l'enfant est bien un trou de taupe qui peut être activé
		if hole.has_method("show_target"):
			interactive_holes.append(hole)
	
	if interactive_holes.is_empty():
		return
	
	var random_hole = interactive_holes.pick_random()
	if not random_hole.is_active:
		var roll = randf()

		# On récupère les probabilités de manière sécurisée
		var bomb_chance = level_data.bomb_chance if "bomb_chance" in level_data else 0.0
		var friend_chance = level_data.friend_chance if "friend_chance" in level_data else 0.0
		var gold_mole_chance = level_data.gold_mole_chance if "gold_mole_chance" in level_data else 0.0
		
		# On décide quelle cible faire apparaître en cumulant les chances
		if roll < bomb_chance:
			random_hole.show_target("bomb")
		elif roll < bomb_chance + friend_chance:
			random_hole.show_target("friend")
		elif roll < bomb_chance + friend_chance + gold_mole_chance:
			random_hole.show_target("gold_mole")
		else:
			random_hole.show_target("mole")