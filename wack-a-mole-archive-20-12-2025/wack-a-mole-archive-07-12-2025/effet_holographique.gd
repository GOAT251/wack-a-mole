shader_type canvas_item;

uniform sampler2D grain_tex : hint_default_white;

void fragment() {
	// TEST 1 : Est-ce que les UV marchent ?
	// Tu devrais voir un dégradé (Noir en haut gauche -> Rouge/Vert en bas droite)
	vec4 test_uv = vec4(UV.x, UV.y, 0.0, 1.0);
	
	// TEST 2 : Est-ce que la texture de bruit charge ?
	// Tu devrais voir ton motif de bruit en noir et blanc
	vec4 test_bruit = texture(grain_tex, UV);
	
	// --- DECOMMENTE UNE SEULE LIGNE CI-DESSOUS POUR TESTER ---
	
	// A. Si tu vois du ROUGE/VERT, les UV sont bons. Si c'est NOIR, le noeud est buggé.
	COLOR = test_uv; 
	
	// B. Si tu vois du BRUIT, la texture marche. Si c'est BLANC/NOIR UNI, la texture est vide.
	// COLOR = test_bruit;
}
