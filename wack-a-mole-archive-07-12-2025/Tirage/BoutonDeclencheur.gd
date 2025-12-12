extends TextureButton

@export var coffre_a_afficher: Control
static var dernier_coffre_actif: Control = null

func _ready():
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	
	# Vérification au lancement
	print("[DEBUG] Bouton ", self.name, " est prêt.")
	if coffre_a_afficher == null:
		printerr("[ERREUR CRITIQUE] Le bouton ", self.name, " n'a pas de Coffre cible dans l'inspecteur !")
	else:
		print("[DEBUG] -> Cible de ", self.name, " : ", coffre_a_afficher.name)

func _on_pressed():
	print("\n--- CLIC SUR ", self.name, " ---")
	
	if not coffre_a_afficher:
		printerr("STOP : Pas de coffre assigné !")
		return

	# 1. Gestion de l'ancien coffre
	if dernier_coffre_actif != null:
		print("Ancien coffre détecté : ", dernier_coffre_actif.name)
		
		if dernier_coffre_actif != coffre_a_afficher:
			print(" -> Je cache l'ancien : ", dernier_coffre_actif.name)
			dernier_coffre_actif.visible = false # On utilise visible = false au lieu de hide() pour être sûr
			
			if dernier_coffre_actif.has_method("reset_coffre"):
				dernier_coffre_actif.reset_coffre()
		else:
			print(" -> C'est le même coffre, je ne le cache pas.")
	else:
		print("Pas d'ancien coffre actif.")

	# 2. Gestion du nouveau coffre
	print("J'affiche le nouveau : ", coffre_a_afficher.name)
	coffre_a_afficher.visible = true
	
	if coffre_a_afficher.has_method("reset_coffre"):
		print(" -> Reset du coffre (remise à zéro de l'état)")
		coffre_a_afficher.reset_coffre()
	else:
		printerr("ATTENTION : Le coffre ", coffre_a_afficher.name, " n'a pas de script CoffreAnim ou de fonction reset_coffre !")

	# 3. Mise à jour mémoire
	dernier_coffre_actif = coffre_a_afficher
	
	# 4. VÉRIFICATION DE SURVIE
	if self.visible == false:
		printerr("ALERTE : Je viens de disparaître ! (", self.name, ")")
		printerr("Une autre ligne de code ou un parent m'a caché.")
	else:
		print("État fin du clic : Tout semble OK.")