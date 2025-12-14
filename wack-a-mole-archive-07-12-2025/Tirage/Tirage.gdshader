shader_type canvas_item;

// Règle la vitesse du reflet
uniform float vitesse : hint_range(0.1, 5.0) = 2.0;
// Règle la taille des reflets
uniform float echelle : hint_range(0.1, 10.0) = 3.0;

void fragment() {
	// On récupère la forme du texte
	vec4 couleur_origine = texture(TEXTURE, UV);
	
	if (couleur_origine.a > 0.0) {
		
		// Calcul de l'angle du reflet (Diagonale pour faire plus "reflet")
		// On mixe X et Y pour incliner l'effet
		float angle = (UV.x * echelle) + (UV.y * echelle * 0.5) - (TIME * vitesse);
		
		// --- LA FORMULE CRISTAL ---
		// Au lieu de couleurs fortes (0.5 + 0.5), on utilise une base très blanche (0.75 + 0.25)
		// Cela crée des teintes pastels très lumineuses.
		vec3 cristal = vec3(0.75) + vec3(0.25) * cos(angle + vec3(0.0, 2.0, 4.0));
		
		// OPTIONNEL : Ajout d'une barre de brillance blanche (L'éclat)
		// Ça crée une ligne blanche qui passe par dessus
		float brillance = sin(angle * 2.0); // Fréquence de la brillance
		brillance = smoothstep(0.9, 1.0, brillance); // On ne garde que les pics très blancs
		
		// On mélange le cristal et la brillance blanche
		vec3 couleur_finale = mix(cristal, vec3(1.0), brillance * 0.8);
		
		COLOR.rgb = couleur_finale;
		COLOR.a = couleur_origine.a;
		
	} else {
		COLOR = vec4(0.0);
	}
}