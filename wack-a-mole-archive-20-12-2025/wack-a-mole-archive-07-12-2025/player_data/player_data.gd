extends Node

# --- DONNÉES GLOBALES ---
var equipped_hammer: Resource = null 

# Les 3 Slots d'équipement (null = vide au départ)
var gemmes_equipees: Array = [null, null, null]

# L'Inventaire des gemmes
var inventaire_gemmes: Array[GemData] = []

# --- NOUVEAU : INVENTAIRE DES SHARDS (Marteaux) ---
# Dictionnaire : { "Nom du Marteau": Quantité }
var inventaire_shards: Dictionary = {}

func _ready():
	print("PlayerData : Système de sauvegarde prêt.")
	recalculer_stats_joueur()

# --- GESTION DES SHARDS (C'EST ÇA QUI MANQUAIT) ---
func ajouter_shards(nom_marteau: String, quantite: int):
	# Si le marteau n'est pas encore dans la liste, on l'ajoute à 0
	if not inventaire_shards.has(nom_marteau):
		inventaire_shards[nom_marteau] = 0
	
	# On ajoute la quantité
	inventaire_shards[nom_marteau] += quantite
	
	print("💎 LOOT : +", quantite, " éclats pour '", nom_marteau, "' (Total: ", inventaire_shards[nom_marteau], ")")


# --- GESTION DE L'INVENTAIRE GEMMES ---
func ajouter_gemme_inventaire(nouvelle_gemme: GemData):
	inventaire_gemmes.append(nouvelle_gemme)
	print("💰 GEMME : ", nouvelle_gemme.nom, " ajoutée.")

# --- GESTION DE L'ÉQUIPEMENT ---
func equiper_gemme_dans_slot(index_slot: int, data_gemme: GemData):
	if index_slot < 0 or index_slot >= gemmes_equipees.size():
		return
	gemmes_equipees[index_slot] = data_gemme
	recalculer_stats_joueur()

# --- MOTEUR DE CALCUL STATS ---
var stats_actuelles = null

func recalculer_stats_joueur():
	if StatsCalculator:
		stats_actuelles = StatsCalculator.calculer_tout(equipped_hammer, gemmes_equipees)