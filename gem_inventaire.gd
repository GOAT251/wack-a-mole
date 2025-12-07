extends Control

@export var container_principal: VBoxContainer 
@export var gem_collection_source: Control 

var tous_les_slots: Array = []
var debug_fait = false

func _ready():
	call_deferred("initialiser_inventaire")

func initialiser_inventaire():
	if gem_collection_source == null:
		printerr("ERREUR : Glisse 'GemCollection' dans l'inspecteur !")
		return
	
	tous_les_slots.clear()
	if container_principal:
		for ligne in container_principal.get_children():
			if ligne.get_child_count() > 0:
				for bouton in ligne.get_children():
					tous_les_slots.append(bouton)
	
	mettre_a_jour_affichage()

func mettre_a_jour_affichage():
	var inventaire = []
	if has_node("/root/PlayerData"):
		inventaire = get_node("/root/PlayerData").inventaire_gemmes

	# Debug Collection (une fois)
	if not debug_fait:
		print("--- DIAGNOSTIC COLLECTION ---")
		var test = []
		recuperer_tout_le_monde_recursif(gem_collection_source, test)
		print("Objets trouvés : ", test.size())
		debug_fait = true

	for i in range(tous_les_slots.size()):
		var slot = tous_les_slots[i]
		
		# Nettoyage
		if slot.has_node("Clone"): slot.get_node("Clone").queue_free()
		slot.disabled = true
		slot.modulate.a = 0.5
		if "data" in slot: slot.data = null
		slot.texture_normal = null
		if slot.has_node("icon"): slot.get_node("icon").texture = null

		# --- REMPLISSAGE ---
		if i < inventaire.size():
			var la_data = inventaire[i]
			slot.disabled = false
			slot.modulate.a = 1.0
			
			var bouton_original = trouver_bouton_bulldozer(la_data)
			
			if bouton_original:
				# 1. CLONAGE
				var clone = bouton_original.duplicate()
				clone.name = "Clone"
				slot.add_child(clone)
				clone.data = la_data 
				
				# 2. RESET TOTAL (La méthode forte)
				# On remet tout à zéro, pas d'ancrage, pas de position
				clone.set_anchors_preset(Control.PRESET_TOP_LEFT)
				clone.position = Vector2.ZERO
				clone.pivot_offset = Vector2.ZERO # On annule le pivot pour l'instant
				
				# 3. CALCUL DU SCALE
				var t_org = clone.size.x
				if t_org <= 1: t_org = 300.0
				var t_slot = slot.size.x
				if t_slot <= 1: t_slot = 100.0
				
				var ratio = (t_slot / t_org) * 0.90 # On réduit un peu (90%)
				clone.scale = Vector2(ratio, ratio)
				
				# 4. CENTRAGE MANUEL (Sans Pivot)
				# On calcule la taille finale du bouton une fois réduit
				var taille_finale_x = t_org * ratio
				var taille_finale_y = clone.size.y * ratio
				
				# On calcule l'espace vide restant dans le slot
				var espace_x = t_slot - taille_finale_x
				var espace_y = slot.size.y - taille_finale_y
				
				# On divise par 2 pour centrer
				clone.position = Vector2(espace_x / 2, espace_y / 2)
				
				# 5. DEBUG POSITION (Regarde ta console !)
				if i == 0:
					print("\n🔎 DEBUG CLONE 0 :")
					print("   Pos Originale (mémoire) : ", bouton_original.position)
					print("   Pos Clone Finale : ", clone.position)
				
				clone.mouse_filter = Control.MOUSE_FILTER_IGNORE
			else:
				print("❌ PAS TROUVÉ : ", la_data.nom)

# --- FONCTIONS UTILITAIRES ---
func trouver_bouton_bulldozer(data_cible):
	var element_nom = nettoyer_nom(data_cible.element)
	var rarete_str = str(data_cible.rarete)
	
	var tous_les_enfants = []
	recuperer_tout_le_monde_recursif(gem_collection_source, tous_les_enfants)
	
	for enfant in tous_les_enfants:
		var nom = enfant.name.to_lower()
		if element_nom in nom and rarete_str in nom:
			return enfant
	return null

func recuperer_tout_le_monde_recursif(parent, liste):
	for enfant in parent.get_children():
		liste.append(enfant)
		if enfant.get_child_count() > 0:
			recuperer_tout_le_monde_recursif(enfant, liste)

func nettoyer_nom(nom_brut: String) -> String:
	var n = nom_brut.to_lower()
	if "végétale" in n or "vegetale" in n: return "plante"
	if "paladin" in n or "lumière" in n or "lumiere" in n: return "lumiere"
	if "frost" in n or "glace" in n or "froid" in n: return "froid"
	return n
