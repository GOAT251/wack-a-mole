shader_type canvas_item;

// Règle la vitesse du reflet
uniform float vitesse : hint_range(0.001, 5.0) = 0.5;
// Règle la taille des bandes (Plus c'est haut, plus c'est fin)
uniform float echelle : hint_range(0.001, 10.0) = 3.0;
// Règle la transparence globale de l'effet
uniform float opacite : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 couleur_texte = texture(TEXTURE, UV);
    
    // On ne touche qu'aux pixels qui existent (le texte), pas le fond transparent
    if (couleur_texte.a > 0.0) {
        // 1. Calcul de l'angle du reflet
        float angle = (UV.x * echelle) + (UV.y * echelle * 0.5) - (TIME * vitesse);
        
        // 2. LA FORMULE "DIAMANT"
        vec3 cristal = vec3(0.75) + vec3(0.25) * cos(angle + vec3(0.0, 2.0, 4.0));
        
        // 3. Eclat blanc
        float brillance = sin(angle * 2.0); 
        brillance = smoothstep(0.9, 1.0, brillance); 
        
        // 4. Mélange final
        vec3 final = mix(cristal, vec3(1.0), brillance * 0.8);
        
        COLOR.rgb = final;
        COLOR.a = couleur_texte.a * opacite;
    } else {
        // Si c'est le fond transparent, on laisse transparent
        COLOR = vec4(0.0);
    }
}