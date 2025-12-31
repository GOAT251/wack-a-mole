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
	# On fait un calcul initial des stats
	recalculer_stats_joueur()

# --- GESTION DE L'INVENTAIRE GEMMES (Appelé par le Tirage) ---
func ajouter_gemme_inventaire(nouvelle_gemme: GemData):
	inventaire_gemmes.append(nouvelle_gemme)
	
	print("\n💰 INVENTAIRE : Nouvelle gemme reçue !")
	print("   + Nom : ", nouvelle_gemme.nom)
	
	print("   + Stats générées :")
	for stat in nouvelle_gemme.stats_generees:
		var txt_val = str(stat.valeur)
		if stat.is_percent: txt_val += "%"
		print("      - [Tier ", stat.tier_visuel, "] ", stat.nom, " : ", txt_val)
	
	print("   = Total : ", inventaire_gemmes.size())

# --- GESTION DES SHARDS (Marteaux) ---
func ajouter_shards(nom_marteau: String, quantite: int):
	# Si le marteau n'est pas encore dans la liste, on l'ajoute à 0
	if not inventaire_shards.has(nom_marteau):
		inventaire_shards[nom_marteau] = 0
	
	# On ajoute la quantité
	inventaire_shards[nom_marteau] += quantite
	
	print("💎 LOOT : +", quantite, " éclats pour '", nom_marteau, "' (Total: ", inventaire_shards[nom_marteau], ")")

# --- GESTION DU DÉBLOCAGE MARTEAUX ---
func get_nombre_shards(nom_marteau: String) -> int:
	if inventaire_shards.has(nom_marteau):
		return inventaire_shards[nom_marteau]
	return 0

func depenser_shards(nom_marteau: String, prix: int) -> bool:
	var en_stock = get_nombre_shards(nom_marteau)
	
	if en_stock >= prix:
		inventaire_shards[nom_marteau] -= prix
		print("🔨 DÉBLOCAGE : ", prix, " shards dépensés pour ", nom_marteau)
		return true # Succès
	else:
		print("❌ Pas assez de shards !")
		return false # Echec

# --- GESTION DE L'ÉQUIPEMENT (Appelé par l'Inventaire) ---
func equiper_gemme_dans_slot(index_slot: int, data_gemme: GemData):
	if index_slot < 0 or index_slot >= gemmes_equipees.size():
		printerr("ERREUR PlayerData : Index de slot invalide (", index_slot, ")")
		return

	# On remplace la gemme dans le slot ciblé
	gemmes_equipees[index_slot] = data_gemme
	
	print("\n🛡️ ÉQUIPEMENT : Changement effectué sur le slot ", index_slot + 1)
	
	# IMPORTANT : On recalcule les stats globales
	recalculer_stats_joueur()

# --- MOTEUR DE CALCUL STATS ---
var stats_actuelles = null

func recalculer_stats_joueur():
	if StatsCalculator: # Vérifie que la classe existe
		stats_actuelles = StatsCalculator.calculer_tout(equipped_hammer, gemmes_equipees)
		# print("Stats Recalculées (Dégâts : ", stats_actuelles.degats_finaux, ")")