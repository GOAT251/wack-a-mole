extends Node

# --- DONNÉES GLOBALES ---
var equipped_hammer: Resource = null 
var gemmes_equipees: Array = [null, null, null]
var inventaire_gemmes: Array[GemData] = []

func _ready():
	print("PlayerData : Système de sauvegarde prêt.")

# --- GESTION DE L'INVENTAIRE (CORRIGÉ) ---
func ajouter_gemme_inventaire(nouvelle_gemme: GemData):
	inventaire_gemmes.append(nouvelle_gemme)
	
	print("\n💰 INVENTAIRE : Nouvelle gemme reçue !")
	print("   + Nom : ", nouvelle_gemme.nom)
	
	# --- CORRECTION ICI ---
	# On n'affiche plus 'valeur_reelle' qui n'existe plus.
	# On boucle sur la liste des stats générées :
	print("   + Stats générées :")
	for stat in nouvelle_gemme.stats_generees:
		var txt_val = str(stat.valeur)
		if stat.is_percent: txt_val += "%"
		print("      - [Tier ", stat.tier_visuel, "] ", stat.nom, " : ", txt_val)
	# ----------------------
	
	print("   = Total : ", inventaire_gemmes.size())

# --- GESTION DE L'ÉQUIPEMENT ---
func equiper_gemme_dans_slot(index_slot: int, data_gemme: GemData):
	if index_slot < 0 or index_slot >= gemmes_equipees.size():
		printerr("ERREUR PlayerData : Index de slot invalide (", index_slot, ")")
		return

	gemmes_equipees[index_slot] = data_gemme
	print("\n🛡️ ÉQUIPEMENT : Changement effectué sur le slot ", index_slot + 1)
