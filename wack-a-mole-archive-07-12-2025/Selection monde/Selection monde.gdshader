shader_type canvas_item;

// Couleurs et paramètres modifiables dans l'inspecteur
uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 1.0, 0.5); // Blanc semi-transparent
uniform float shine_speed : hint_range(0.0, 5.0) = 1.0; // Vitesse
uniform float shine_size : hint_range(0.01, 1.0) = 0.2; // Taille de la barre de brillance

void fragment() {
    // Récupère la couleur actuelle du pixel (texte + bordure)
    vec4 current_color = texture(TEXTURE, UV);
    
    // Si le pixel est transparent, on ne dessine rien (on garde la transparence)
    if (current_color.a == 0.0) {
        discard;
    }
    
    // Calcul de la position de la barre de brillance (mouvement diagonal)
    // On utilise le temps (TIME) pour l'animer
    float shine_position = (UV.x + UV.y) / 2.0; 
    float time_offset = mod(TIME * shine_speed, 2.0); // Boucle l'animation
    
    // Création de la barre lumineuse avec smoothstep pour un bord doux
    float shine = smoothstep(time_offset - shine_size, time_offset, shine_position) 
                - smoothstep(time_offset, time_offset + shine_size, shine_position);
    
    // Appliquer la brillance par dessus la couleur existante
    // On utilise max() pour ne pas assombrir la couleur originale
    vec3 final_color = mix(current_color.rgb, shine_color.rgb, shine * shine_color.a);
    
    COLOR = vec4(final_color, current_color.a);
}