# Dans ItemInfoPanel.gd
extends Control

# --- Références aux Nœuds de base ---
@onready var name_label = $Fond/NameLabel
@onready var icon_display = $Fond/IconImage
@onready var description_label = $Fond/DescriptionLabel
@onready var bouton_retour = $Fond/BoutonRetour

# --- NOUVEAU : Références directes aux labels des stats ---
@onready var flat_damage_label = $Fond/StatsContainer/FlatDamageStat/ValueLabel
@onready var swing_speed_label = $Fond/StatsContainer/SwingSpeedStat/ValueLabel
@onready var crit_rate_label = $Fond/StatsContainer/CritRateStat/ValueLabel
# Ajoutez d'autres références ici pour vos autres stats...


func _ready():
	bouton_retour.pressed.connect(_on_bouton_retour_pressed)


func show_with_data(data: UnlockableItemData):
	self.visible = true
	
	# Mise à jour des infos générales (ne change pas)
	name_label.text = data.item_name
	icon_display.texture = data.icon
	description_label.text = data.description
	
	# --- MODIFIÉ : On met à jour chaque stat individuellement ---
	
	# On convertit les nombres en texte et on les assigne au bon label.
	flat_damage_label.text = str(data.flat_damage)
	
	# Pour les nombres à virgule, on peut les formater joliment.
	swing_speed_label.text = "%.2f" % data.swing_speed 
	
	# Pour les pourcentages, on multiplie par 100.
	crit_rate_label.text = "%d%%" % (data.crit_rate * 100)
	
	# Continuez pour les autres stats...
	# exemple_autre_stat_label.text = str(data.autre_stat)


func _on_bouton_retour_pressed():
	self.visible = false
