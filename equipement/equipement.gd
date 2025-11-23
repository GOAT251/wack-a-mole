extends Control

# --- RÉFÉRENCES ---
@onready var info_panel = $ItemInfoPanel

# --- CORRECTION ICI ---
# On met le nom exact de votre NOUVEAU panel (vérifiez que c'est bien ce nom dans la scène à gauche)
@onready var hammer_list = $Hammer_PanelEQUI 

@onready var bouton_marteau = $BoutonMarteau

func _ready():
	# On s'assure que les panels existent avant de les cacher pour éviter les erreurs
	if info_panel: info_panel.hide()
	if hammer_list: hammer_list.hide()

	if bouton_marteau:
		bouton_marteau.pressed.connect(_on_bouton_marteau_pressed)

	# Connexion des boutons (SmartButtons)
	var buttons = get_tree().get_nodes_in_group("smart_buttons")
	for btn in buttons:
		if not btn.item_clicked.is_connected(_on_item_clicked):
			btn.item_clicked.connect(_on_item_clicked)

func _on_item_clicked(data):
	# 1. On affiche les infos
	info_panel.show_with_data(data)
	
	# 2. On met le panel d'info au premier plan
	info_panel.move_to_front() 

func _on_bouton_marteau_pressed():
	if hammer_list.visible:
		hammer_list.hide()
		info_panel.hide()
	else:
		hammer_list.show()
		# On met la liste au premier plan (mais derrière l'info panel si on clique sur un item après)
		hammer_list.move_to_front()
