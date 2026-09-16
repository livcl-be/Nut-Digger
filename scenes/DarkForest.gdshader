shader_type canvas_item;
uniform float hue = 1;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	vec3 color = COLOR.rgb;
	mat3 RGB_to_YIQ = mat3(
		vec3(0.2959, 0.5959, 0.2115),
		vec3(0.5870, -0.2774, -0.5229),
		vec3(0.1140, -0.3216, 0.3114)
	);
	color= RGB_to_YIQ * color;
	
	float sin_hue = sin(hue);
	float cos_hue = cos(hue);

	mat3 hue_Shift = mat3(
		vec3(1.0,0,0),
		vec3(0,cos_hue,-sin_hue),
		vec3(0,sin_hue,cos_hue)
	);
	color = hue_Shift * color;
	color = inverse(RGB_to_YIQ) * color;
	COLOR = vec4(color, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
