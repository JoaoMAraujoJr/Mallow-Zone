shader_type canvas_item;

uniform sampler2D curve;
uniform float rotation_speed = -1.0; // radians per second
uniform float distortion_strength : hint_range(0.0, 1.0) = 0.6;

// Iridescence controls
uniform float iridescence_scale : hint_range(0.0, 10.0) = 3.0;
uniform float iridescence_intensity : hint_range(0.0, 1.0) = 0.5;
uniform vec2 light_dir = vec2(0.5, -0.5);
uniform vec2 scroll = vec2(0.0, 0.0); // scroll speed
uniform float angle_deg : hint_range(-360.0, 360.0) = 0.0;

// ===== Helper: HSV → RGB =====
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 iridescent_color(float v) {
    float hue = fract(v * iridescence_scale);
    return hsv2rgb(vec3(hue, 1.0, 1.0));
}

void fragment() {
    vec2 center = vec2(0.5);
    vec2 vecToCenter = center - UV;

    // ===== Distortion rotation =====
    float rot_angle = TIME * rotation_speed;
    mat2 rot = mat2(
        vec2(cos(rot_angle), sin(rot_angle)),
        vec2(-sin(rot_angle), cos(rot_angle))
    );

    vec2 rotated = rot * vecToCenter;
    float distToCenter = length(rotated);

    // Sample curve for distortion intensity
    float curveVal = texture(curve, vec2(distToCenter, 0.0)).r;

    // Direction from center, scaled by curve
    vec2 dir = distToCenter > 0.0001 ? rotated / distToCenter : vec2(0.0);
    vec2 offset = dir * distortion_strength * curveVal;

    // Distorted UVs (still confined to sprite)
    vec2 distortedUV = UV + offset;

    // ===== Iridescence computation =====
    float base_angle = radians(angle_deg);
    mat2 base_rot = mat2(
        vec2(cos(base_angle), sin(base_angle)),
        vec2(-sin(base_angle), cos(base_angle))
    );

    vec2 uv_center = distortedUV - 0.5;
    uv_center = base_rot * uv_center;
    uv_center += scroll * TIME;
    float ang = dot(normalize(light_dir), uv_center);

    vec3 rainbow = iridescent_color(ang);
    vec3 base_color = mix(vec3(1.0), rainbow, iridescence_intensity);

    // ===== Final color =====
    vec4 tex = texture(TEXTURE, distortedUV);
    COLOR = vec4(base_color * tex.rgb, tex.a);
}
