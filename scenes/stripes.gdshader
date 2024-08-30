shader_type spatial;
render_mode cull_disabled, blend_mix;
uniform float emission_strength : hint_range(0.0, 5.0) = 1.0;
uniform sampler2D uv_offset_texture : hint_default_black;
uniform vec2 uv_offset_scale = vec2(0.2, 0.1);
uniform vec2 time_scale = vec2(0.3, 0.0);
uniform float face_distortion = 0.1;
/*
void vertex() {
	vec2 base_uv_offset = UV * uv_offset_scale;
	base_uv_offset += TIME * time_scale;
	float noise = texture(uv_offset_texture, base_uv_offset).r * 1.0;
	float texture_based_offset = noise * 2.0 - 1.0;
	texture_based_offset *= 1.0 - UV.y;

	VERTEX.y += texture_based_offset;
	VERTEX.z += texture_based_offset * face_distortion;
	VERTEX.x += texture_based_offset * -face_distortion;
}*/

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
