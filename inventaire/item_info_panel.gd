extends Control

# --- RÉFÉRENCES ---

# CORRECTION : Le bouton est maintenant à la racine
@onready var equip_button = $EquipButton

# Les autres éléments sont toujours dans "Fond" (ne change pas si tu ne les as pas bougés)
@onready var name_label = $Fond/NameLabel
@onready var icon_display = $Fond/IconImage
@onready var description_label = $Fond/DescriptionLabel
@onready var bouton_retour = $Fond/BoutonRetour
@onready var flat_damage_label = $Fond/StatsContainer/FlatDamageStat/ValueLabel

var current_displayed_item: UnlockableItemData = null

func _ready():
	# Connexion du bouton EquipButton
	if equip_button:
		if not equip_button.pressed.is_connected(_on_equip_button_pressed):
			equip_button.pressed.connect(_on_equip_button_pressed)
	else:
		print("ERREUR : EquipButton n'est pas trouvé à la racine ($EquipButton)")

	# Connexion du bouton Retour
	if bouton_retour:
		if not bouton_retour.pressed.is_connected(_on_bouton_retour_pressed):
			bouton_retour.pressed.connect(_on_bouton_retour_pressed)


func show_with_data(data: UnlockableItemData):
	self.visible = true
	current_displayed_item = data
	
	# Mise à jour des textes (avec sécurité au cas où un nœud manque)
	if name_label: name_label.text = data.item_name
	if icon_display: icon_display.texture = data.icon
	if description_label: description_label.text = data.description
	if flat_damage_label: flat_damage_label.text = str(data.flat_damage)

	# GESTION DU BOUTON (Actif ou Grisé selon si débloqué)
	#if equip_button:
		#equip_button.disabled = not data.is_unlocked


func _on_bouton_retour_pressed():
	self.visible = false


func _on_equip_button_pressed():
	if current_displayed_item and PlayerData:
		PlayerData.equipped_hammer = current_displayed_item
		print("Succès : Marteau équipé -> ", current_displayed_item.item_name)
