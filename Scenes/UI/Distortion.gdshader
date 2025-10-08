shader_type canvas_item;

uniform sampler2D curve;
uniform float rotation_speed = -1.0; // radians per second
uniform float distortion_strength : hint_range(0.0, 1.0) = 0.6;

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    vec2 vecToCenter = center - UV;

    // Rotate over time
    float angle = TIME * rotation_speed;
    mat2 rot = mat2(
        vec2(cos(angle), sin(angle)),
        vec2(-sin(angle), cos(angle))
    );

    vec2 rotated = rot * vecToCenter;
    float distToCenter = length(rotated);

    // Sample curve for distortion intensity (use x-axis of curve texture)
    float curveVal = texture(curve, vec2(distToCenter, 0.0)).r;

    // Direction from center, scaled by curve
    vec2 dir = distToCenter > 0.0001 ? rotated / distToCenter : vec2(0.0);
    vec2 offset = dir * distortion_strength * curveVal;

    // Distort within the sprite texture itself
    vec4 tex = texture(TEXTURE, UV + offset);

    COLOR = tex;
}
