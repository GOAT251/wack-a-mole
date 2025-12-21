# Script: hammer_panel_equi.gd
extends Control

# Adapte le chemin si ton bouton est dans un "Fond" !
# Exemple : $Fond/BoutonRetour ou juste $BoutonRetour
@onready var bouton_retour = $BoutonRetour 

func _ready():
	if bouton_retour:
		bouton_retour.pressed.connect(_on_bouton_retour_pressed)
	else:
		print("ERREUR : BoutonRetour introuvable dans Hammer_PanelEQUI")

func _on_bouton_retour_pressed():
	# Le panneau se cache lui-même
	self.hide()