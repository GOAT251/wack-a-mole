extends Node

# --- DONNÉES EXISTANTES ---
var equipped_hammer: Resource = null # Ton marteau (je garde ton code)

# --- NOUVEAU : L'INVENTAIRE DES GEMMES ---
# On stocke ici les instances uniques de GemData
var inventaire_gemmes: Array[GemData] = []

func _ready():
	print("PlayerData : Système de sauvegarde prêt.")

# Fonction appelée par le Tirage pour ajouter une gemme
func ajouter_gemme_inventaire(nouvelle_gemme: GemData):
	# 1. On ajoute la gemme à la liste
	inventaire_gemmes.append(nouvelle_gemme)
	
	# 2. Feedback dans la console pour vérifier que ça marche
	print("\n💰 INVENTAIRE MIS À JOUR !")
	print("   + Ajout de : ", nouvelle_gemme.nom)
	print("   + Stats : ", nouvelle_gemme.valeur_reelle) # On affiche la stat unique
	print("   = Total Gemmes possédées : ", inventaire_gemmes.size())