shader_type spatial;
render_mode cull_disabled, blend_mix;
uniform float emission_strength : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    vec4 base_color = COLOR;
	// Adjust UV coordinates so that y = 0.5 is the center
    float gradient = 1.0 - abs(UV.y - 0.5) * 2.0;
	ALBEDO = base_color.rgb * gradient;
    EMISSION = base_color.rgb * emission_strength * gradient;
	// Apply the gradient to transparency
    ALPHA = base_color.a * gradient;
}


//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
