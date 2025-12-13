extends Node

# --- DONNÉES GLOBALES ---
var equipped_hammer: Resource = null 

# Les 3 Slots d'équipement (null = vide au départ)
var gemmes_equipees: Array = [null, null, null]

# L'Inventaire complet
var inventaire_gemmes: Array[GemData] = []

func _ready():
	print("PlayerData : Système de sauvegarde prêt. (Inventaire vide)")
	# Plus aucune injection de gemmes ici !

# --- GESTION DE L'INVENTAIRE (Appelé par le Tirage) ---
func ajouter_gemme_inventaire(nouvelle_gemme: GemData):
	inventaire_gemmes.append(nouvelle_gemme)
	
	print("\n💰 INVENTAIRE : Nouvelle gemme reçue !")
	print("   + Nom : ", nouvelle_gemme.nom)
	print("   + Stats : ", nouvelle_gemme.valeur_reelle)
	print("   = Total : ", inventaire_gemmes.size())

# --- GESTION DE L'ÉQUIPEMENT (Appelé par l'Inventaire) ---
func equiper_gemme_dans_slot(index_slot: int, data_gemme: GemData):
	# Sécurité
	if index_slot < 0 or index_slot >= gemmes_equipees.size():
		printerr("ERREUR PlayerData : Index de slot invalide (", index_slot, ")")
		return

	# On remplace la gemme dans le slot ciblé
	gemmes_equipees[index_slot] = data_gemme
	
	print("\n🛡️ ÉQUIPEMENT : Changement effectué !")
	print("   > Slot ", index_slot + 1, " contient maintenant : ", data_gemme.nom)