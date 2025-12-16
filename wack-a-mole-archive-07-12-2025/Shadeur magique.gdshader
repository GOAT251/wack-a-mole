shader_type canvas_item;

// La texture de bruit (nuages)
uniform sampler2D bruit_tex : repeat_enable;

// La couleur de ta magie (ex: Violet sombre, Vert toxique...)
uniform vec4 couleur : source_color = vec4(0.2, 0.0, 0.4, 1.0);

// Réglages
uniform float vitesse_x = 0.05;
uniform float vitesse_y = 0.02;
uniform float opacite : hint_range(0.0, 1.0) = 0.3;
uniform float echelle : hint_range(0.1, 5.0) = 1.0;

void fragment() {
	// 1. Coordonnées écran (pour éviter les bugs d'UV du polygone)
	vec2 pos = SCREEN_UV * echelle;

	// 2. Mouvement
	pos.x += TIME * vitesse_x;
	pos.y += TIME * vitesse_y;

	// 3. Lecture du bruit
	// On prend la valeur de gris de la texture
	float valeur_bruit = texture(bruit_tex, pos).r;

	// 4. Application
	// On applique la couleur choisie
	COLOR.rgb = couleur.rgb;

	// L'alpha dépend du bruit (pour faire des trous comme de la fumée)
	// et de l'opacité globale
	COLOR.a = valeur_bruit * opacite;
}