shader_type canvas_item;

uniform float vitesse : hint_range(0.0, 5.0) = 0.3;
uniform float opacite : hint_range(0.0, 1.0) = 0.5;

// AJOUT : Echelle réglable très bas
uniform float echelle : hint_range(0.01, 50.0) = 10.0;

void fragment() {
	vec2 pos = SCREEN_UV;

	// Calcul avec l'échelle
	float mouvement = (pos.x * echelle + pos.y * echelle * 0.5) - (TIME * vitesse);

	// Reflet
	float reflet = sin(mouvement * 10.0);
	reflet = smoothstep(0.9, 1.0, reflet);

	// --- COULEUR BLEUE ---
	vec3 couleur_bleue = vec3(0.0, 0.5, 1.0);

	vec3 rendu_final = mix(couleur_bleue, vec3(1.0), reflet);

	COLOR.rgb = rendu_final;
	COLOR.a = opacite + (reflet * 0.5);
}