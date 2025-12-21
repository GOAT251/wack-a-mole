extends Node

# --- DONNÉES GLOBALES ---

# Le Marteau (avec un setter pour recalculer dès qu'on le change)
var equipped_hammer: Resource = null:
	set(valeur):
		equipped_hammer = valeur
		print("\n🔨 MARTEAU ÉQUIPÉ : ", valeur.item_name if valeur else "Aucun")
		recalculer_stats_joueur()

# Les 3 Slots d'équipement
var gemmes_equipees: Array = [null, null, null]

# L'Inventaire complet
var inventaire_gemmes: Array[GemData] = []

# --- BILAN DE PUISSANCE (C'est ici que le jeu lira tes stats) ---
var stats_actuelles = null

func _ready():
	print("PlayerData : Système de sauvegarde prêt.")
	# On fait un calcul initial (pour avoir les stats de base du joueur)
	recalculer_stats_joueur()

# --- GESTION DE L'INVENTAIRE (Appelé par le Tirage) ---
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

# --- GESTION DE L'ÉQUIPEMENT (Appelé par l'Inventaire) ---
func equiper_gemme_dans_slot(index_slot: int, data_gemme: GemData):
	if index_slot < 0 or index_slot >= gemmes_equipees.size():
		printerr("ERREUR PlayerData : Index de slot invalide (", index_slot, ")")
		return

	# 1. On applique le changement
	gemmes_equipees[index_slot] = data_gemme
	print("\n🛡️ ÉQUIPEMENT : Changement effectué sur le slot ", index_slot + 1)
	
	# 2. IMPORTANT : On recalcule toutes les stats du joueur !
	recalculer_stats_joueur()

# --- MOTEUR DE CALCUL ---
func recalculer_stats_joueur():
	print("📊 CALCUL DES STATS GLOBALES (Marteau + Gemmes)...")
	
	# On appelle ton nouveau calculateur
	# (Assure-toi d'avoir créé le script StatsCalculator.gd comme vu juste avant)
	if StatsCalculator:
		stats_actuelles = StatsCalculator.calculer_tout(equipped_hammer, gemmes_equipees)
		
		# Debug pour vérifier que ça marche
		print("   > Dégâts Finaux : ", stats_actuelles.degats_finaux)
		print("   > Vitesse Atq   : ", stats_actuelles.vitesse_attaque)
		print("   > Critique      : ", stats_actuelles.chance_critique * 100, "%")
		print("   > Multi Score   : x", stats_actuelles.score_multiplier)
		print("   > Temps Extra   : +", stats_actuelles.temps_extra, "s")
	else:
		printerr("🔴 ERREUR : La classe StatsCalculator n'est pas trouvée !")