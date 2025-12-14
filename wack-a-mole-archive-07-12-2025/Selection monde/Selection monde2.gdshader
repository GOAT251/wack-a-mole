shader_type canvas_item;

// Vitesse du clignotement
uniform float speed : hint_range(0.0, 10.0) = 3.0;
// À quel point ça devient foncé au minimum (0.5 = 50% de la couleur originale)
uniform float min_brightness : hint_range(0.0, 1.0) = 0.7;
// À quel point ça devient brillant au maximum (1.5 = 150%, très éclatant)
uniform float max_brightness : hint_range(1.0, 3.0) = 1.3;

void fragment() {
    vec4 current_color = texture(TEXTURE, UV);

    // Si le pixel est transparent, on l'ignore
    if (current_color.a == 0.0) {
        discard;
    }

    // ASTUCE : On calcule la luminosité du pixel actuel.
    // Si c'est ta bordure (vert clair), la luminosité sera haute.
    // Si c'est ton texte (vert foncé), la luminosité sera basse.
    float brightness = (current_color.r + current_color.g + current_color.b) / 3.0;

    // SEUIL : On décide que si la luminosité est > 0.3, c'est la bordure.
    // (Ajuste 0.3 si jamais ton texte foncé clignote aussi)
    if (brightness > 0.3) {
        // Formule mathématique pour faire une vague (oscillation) entre 0 et 1
        float wave = (sin(TIME * speed) + 1.0) * 0.5;

        // On mélange entre la luminosité min et max
        float intensity = mix(min_brightness, max_brightness, wave);

        // On applique la nouvelle couleur
        COLOR = vec4(current_color.rgb * intensity, current_color.a);
    } else {
        // C'est le texte foncé, on le laisse tranquille
        COLOR = current_color;
    }
}