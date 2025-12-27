shader_type canvas_item;

// --- COULEURS ---
// Le dégradé du fond (Noir vers Gris foncé ou Bleu nuit)
uniform vec4 fond_haut : source_color = vec4(0.1, 0.1, 0.15, 1.0); // Un peu plus clair en haut
uniform vec4 fond_bas : source_color = vec4(0.0, 0.0, 0.0, 1.0);   // Noir pur en bas

// Les couleurs du motif (Tes dorés)
uniform vec4 or_base : source_color = vec4(0.5, 0.35, 0.1, 1.0);
uniform vec4 or_brillant : source_color = vec4(1.0, 0.9, 0.5, 1.0);

// --- REGLAGES ---
uniform float echelle : hint_range(1.0, 50.0) = 8.0;   // Taille losanges
uniform float epaisseur : hint_range(0.01, 0.5) = 0.03; // Finesse du trait
uniform float vitesse : hint_range(0.0, 2.0) = 0.05;    // Défilement du motif
uniform float brillance_vitesse : hint_range(0.0, 5.0) = 1.5; // Vitesse de l'éclat

// Fonction de rotation
vec2 rotate(vec2 uv, float angle) {
	mat2 rotation = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
	return uv * rotation;
}

void fragment() {
	// 1. LE FOND DÉGRADÉ VERTICAL
	// UV.y va de 0 (Haut) à 1 (Bas).
	// On mélange la couleur du haut et du bas.
	vec3 fond_final = mix(fond_haut.rgb, fond_bas.rgb, UV.y);
	
	// 2. LE MOTIF (LOSANGES) - Comme l'ancien shader
	vec2 uv_rot = rotate(UV, 0.785398); // 45 degrés
	vec2 mouvement = vec2(TIME * vitesse * 0.5, TIME * vitesse);
	vec2 grille = fract((uv_rot + mouvement) * echelle);
	
	// Calcul des lignes fines
	float lignes_x = smoothstep(0.5 - epaisseur, 0.5, abs(grille.x - 0.5));
	float lignes_y = smoothstep(0.5 - epaisseur, 0.5, abs(grille.y - 0.5));
	float motif_grille = max(lignes_x, lignes_y);
	
	// 3. LA BRILLANCE DORÉE
	float reflet = sin((UV.x + UV.y - TIME * brillance_vitesse) * 2.0);
	reflet = smoothstep(0.85, 1.0, reflet); // Pic de brillance
	
	// 4. MÉLANGE FINAL
	// Couleur de la ligne (Or sombre + Eclat blanc/or)
	vec3 couleur_trait = mix(or_base.rgb, or_brillant.rgb, reflet);
	
	// On applique le trait par dessus le fond dégradé
	// Le '0.5' à la fin gère l'opacité globale des traits (pour qu'ils ne soient pas trop agressifs)
	vec3 rendu = mix(fond_final, couleur_trait, motif_grille * 0.5); 
	
	COLOR.rgb = rendu;
	COLOR.a = 1.0;
}