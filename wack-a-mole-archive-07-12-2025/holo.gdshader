shader_type canvas_item;

// Règle la vitesse du reflet
uniform float vitesse : hint_range(0.1, 5.0) = 0.5;
// Règle la taille des bandes (Plus c'est haut, plus c'est fin)
uniform float echelle : hint_range(0.1, 10.0) = 3.0;
// Règle la transparence globale de l'effet
uniform float opacite : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	// 1. Calcul de l'angle du reflet (Mouvement Diagonal)
	float angle = (UV.x * echelle) + (UV.y * echelle * 0.5) - (TIME * vitesse);
	
	// 2. LA FORMULE "DIAMANT" (Celle du titre Tirage)
	// Base très blanche (0.75) + Variation subtile (0.25)
	// Cela crée des reflets Argentés / Rosés / Bleutés très pâles
	vec3 cristal = vec3(0.75) + vec3(0.25) * cos(angle + vec3(0.0, 2.0, 4.0));
	
	// 3. Ajout de la barre de brillance blanche (L'éclat net)
	float brillance = sin(angle * 2.0); 
	brillance = smoothstep(0.9, 1.0, brillance); // On garde que le pic très blanc
	
	// 4. Mélange du cristal et de l'éclat blanc
	vec3 couleur_finale = mix(cristal, vec3(1.0), brillance * 0.8);
	
	// 5. Application sur la carte
	COLOR.rgb = couleur_finale;
	
	// ASTUCE : On rend transparent les zones sombres pour voir la carte dessous
	// On utilise la luminosité du reflet pour définir l'alpha
	float luminance = (couleur_finale.r + couleur_finale.g + couleur_finale.b) / 3.0;
	
	// Si c'est brillant -> Visible. Si c'est sombre -> Transparent.
	COLOR.a = opacite * (luminance * luminance); 
}