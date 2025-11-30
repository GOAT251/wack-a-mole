extends Control

@onready var resultat_panel = $ResultatTirage 

func _ready():
	randomize()
	print("--- LE JEU EST PRÊT ---")

# Fonction appelée par le coffre
func generer_tirage_pour_coffre(coffre):
	print("ÉTAPE 1 : Le coffre a demandé un tirage.")
	
	# 1. Vérification du groupe
	var tous_mes_boutons = get_tree().get_nodes_in_group("boutons_gemmes_pool")
	print("ÉTAPE 2 : Nombre de boutons trouvés dans le groupe 'boutons_gemmes_pool' : ", tous_mes_boutons.size())
	
	if tous_mes_boutons.size() == 0:
		printerr("ERREUR ROUGE : Le groupe est vide ! As-tu bien mis ta scène 'GemCollection' (avec tes 30 boutons) DANS la scène Tirage ?")
		return

	# 2. Sélection
	var selection_finale = []
	for i in range(6):
		var bouton_choisi = tous_mes_boutons.pick_random()
		selection_finale.append(bouton_choisi)
	
	print("ÉTAPE 3 : J'ai sélectionné 6 boutons. Envoi au panel...")
	
	# 3. Envoi au panel
	if resultat_panel:
		resultat_panel.afficher_ces_boutons_la(selection_finale)
	else:
		printerr("ERREUR ROUGE : Je ne trouve pas le nœud $ResultatTirage !")