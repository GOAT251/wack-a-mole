# Dans ItemInfoPanel.gd
extends Control

# --- Références aux Nœuds ---
@onready var name_label = $Fond/NameLabel
@onready var icon_display = $Fond/IconImage # Ou le nom que vous aviez choisi
@onready var description_label = $Fond/DescriptionLabel
@onready var stats_label = $Fond/StatsLabel
# NOUVEAU : Référence vers votre bouton retour.
# Assurez-vous que le chemin est correct ! Ici, je suppose qu'il est aussi dans "Fond".
@onready var bouton_retour = $Fond/BoutonRetour


# --- Fonctions de Godot ---

# NOUVEAU : La fonction _ready est appelée une fois au démarrage de la scène.
# C'est l'endroit parfait pour connecter les signaux.
func _ready():
	# On connecte le signal "pressed" (quand on clique) du bouton retour
	# à la fonction que nous allons créer juste en dessous.
	bouton_retour.pressed.connect(_on_bouton_retour_pressed)


# --- Fonctions Personnalisées ---

# La fonction qui affiche le panneau avec les bonnes données.
func show_with_data(data: UnlockableItemData):
	self.visible = true
	
	name_label.text = data.item_name
	icon_display.texture = data.icon
	description_label.text = data.description
	
	var stats_text = "Dégâts de base : %d\nVitesse de frappe : %.2f" % [data.flat_damage, data.swing_speed]
	
	if data.crit_rate > 0:
		stats_text += "\nChance de critique : %d%%" % (data.crit_rate * 100)

	stats_label.text = stats_text

# NOUVEAU : La fonction qui est appelée quand on clique sur le bouton retour.
func _on_bouton_retour_pressed():
	# On cache simplement le panneau entier.
	self.visible = false
