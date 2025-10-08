shader_type canvas_item;

uniform sampler2D noise_tex : source_color, repeat_enable; // your noise texture
uniform float threshold : hint_range(0.0, 1.0) = 0.0; // controls dissolve progress
uniform vec4 edge_color : source_color = vec4(1.0, 1.0,  1.0, 1.0); // glowing edge color
uniform float edge_width : hint_range(0.0, 0.5) = 0.05; // edge thickness

void fragment() {
    vec4 albedo = texture(TEXTURE, UV);
    float noise_val = texture(noise_tex, UV).r;

    // Reverse dissolve → pixels appear when noise < threshold
	float dissolve = smoothstep(threshold, threshold - edge_width, noise_val);

    // Calculate glowing edge
    float edge = smoothstep(threshold - edge_width * 2.0, threshold - edge_width, noise_val) - dissolve;

    vec4 final_color = mix(edge_color, albedo, dissolve);
    final_color.a *= dissolve;

    COLOR = final_color;
}
