shader_type canvas_item;

uniform sampler2D masque_forme : hint_default_white; // Glisse ton image noire et blanche ici

void fragment() {
	vec4 couleur_marteau = texture(TEXTURE, UV); // L'image du marteau
	float decoupe = texture(masque_forme, UV).r; // La forme de l'éclat
	
	// On affiche le marteau SEULEMENT là où le masque est blanc
	COLOR = couleur_marteau;
	COLOR.a *= decoupe; 
}