extends Node

@export var level_container: Node2D
@export var level_data: Node

@onready var spawn_timer = Timer.new()

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

func start_spawning():
	# MOUCHARD N°1 : Est-ce qu'on reçoit l'ordre ?
	print("--- SpawnManager: Ordre de démarrage reçu. ---")

	if not level_data or not level_container:
		printerr("--- SpawnManager ERREUR FATALE: Les données du niveau ou le conteneur sont MANQUANTS ! ---")
		return

	# MOUCHARD N°2 : Est-ce que les données sont valides ?
	print("--- SpawnManager: Données valides. Démarrage du timer avec une durée de ", level_data.spawn_speed, " secondes. ---")
	spawn_timer.wait_time = level_data.spawn_speed
	spawn_timer.start()

func stop_spawning():
	spawn_timer.stop()

func _on_spawn_timer_timeout():
	# MOUCHARD N°3 : Est-ce que le timer se déclenche ? (LE PLUS IMPORTANT)
	print("--- SpawnManager: _on_spawn_timer_timeout DÉCLENCHÉ ! ---")
	
	if level_container.get_child_count() == 0:
		print("SpawnManager INFO: Le LevelContainer est vide, attente du chargement.")
		return

	var grid = level_container.get_child(0).get_node("GridContainer")
	if not grid:
		printerr("--- SpawnManager ERREUR: GridContainer non trouvé dans le niveau ! ---")
		return

	var mole_holes = grid.get_children()
	if mole_holes.is_empty():
		print("--- SpawnManager INFO: Pas de trous de taupe trouvés dans le GridContainer.")
		return
	
	var random_hole = mole_holes.pick_random()
	
	# MOUCHARD N°4 : Est-ce qu'on essaie de faire apparaître une taupe ?
	print("--- SpawnManager: Tentative de spawn dans un trou. Est-il actif ? ", random_hole.is_active)
	
	if random_hole.has_signal("mole_hit") and not random_hole.is_active:
		var roll = randf()
		var bomb_chance = 0.0
		if "bomb_chance" in level_data: bomb_chance = level_data.bomb_chance
		var gold_mole_chance = 0.0
		if "gold_mole_chance" in level_data: gold_mole_chance = level_data.gold_mole_chance
		var friend_chance = level_data.friend_chance
		
		if roll < bomb_chance:
			random_hole.show_target("bomb")
		elif roll < bomb_chance + gold_mole_chance:
			random_hole.show_target("gold_mole")
		elif roll < bomb_chance + gold_mole_chance + friend_chance:
			random_hole.show_target("friend")
		else:
			random_hole.show_target("mole")
