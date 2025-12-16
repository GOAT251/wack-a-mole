class_name AfficherInfos
extends RefCounted

static func generer_texte_stats(data: GemData) -> String:
	print("   [AfficherInfos] Calcul des stats pour : ", data.nom)
	
	if data.stats_generees.is_empty():
		print("   [AfficherInfos] ⚠️ ATTENTION : Liste des stats vide !")
		return "Aucune statistique."
		
	var texte_final = ""
	
	for stat in data.stats_generees:
		var couleur = _get_couleur_par_tier(stat.tier_visuel)
		var val_str = str(stat.valeur)
		if stat.is_percent: val_str += "%"
		
		if stat.tier_visuel == 5: 
			texte_final += "[rainbow freq=0.5 sat=0.8 val=1.0]" + stat.nom + " : " + val_str + "[/rainbow]\n"
		else:
			texte_final += "[color=" + couleur + "]" + stat.nom + " : " + val_str + "[/color]\n"
			
	print("   [AfficherInfos] Texte généré avec succès.")
	return texte_final

static func choisir_texture_cadre(element: String, textures_dispo: Dictionary) -> Texture2D:
	print("   [AfficherInfos] Choix texture pour élément : ", element)
	if textures_dispo.has(element):
		return textures_dispo[element]
	elif textures_dispo.has("Feu"):
		return textures_dispo["Feu"]
	return null

static func _get_couleur_par_tier(tier: int) -> String:
	match tier:
		1: return "#B0B0B0"
		2: return "#00FF00"
		3: return "#0088FF"
		4: return "#AA00FF"
		5: return "#FFD700"
	return "#FFFFFF"