shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

// --- PS1 Jitter & Resolution ---
uniform float jitter_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float jitter_instability : hint_range(0.0, 0.05) = 0.001;
uniform float virtual_res_scale : hint_range(1.0, 10.0) = 4.0;

// --- Image Controls ---
uniform float grain_intensity : hint_range(0.0, 1.0) = 0.1;
uniform float min_lum : hint_range(0.0, 1.0) = 0.0;
uniform float max_lum : hint_range(0.0, 1.0) = 1.0;
uniform float time_scale : hint_range(0.0, 1.0) = 0.5;

// --- Vignette ---
uniform float vignette_darkness : hint_range(0.0, 1.0) = 0.5;
uniform float vignette_outer_radius : hint_range(0.1, 2.0) = 0.7;
uniform float vignette_inner_radius : hint_range(0.0, 1.9) = 0.2;

// --- Effects (Aberration & Warble) ---
uniform float chromatic_aberration : hint_range(0.0, 0.01) = 0.005;
uniform float warble_amount : hint_range(0.0, 0.01) = 0.002;
uniform float warble_speed : hint_range(0.0, 10.0) = 5.0;

// --- Color ---
uniform bool enable_color_quantization = true;
uniform float color_quant_steps : hint_range(2.0, 64.0) = 32.0;

// Helper Functions
float noise(vec2 p) {
    return (fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 2.0;
}

vec3 soft_light(vec3 A, vec3 B) {
    vec3 branch1 = 2.0 * A * B + A * A * (1.0 - 2.0 * B);
    vec3 branch2 = 2.0 * A * (1.0 - B) + sqrt(A) * (2.0 * B - 1.0);
    vec3 condition = step(0.5, B);
    return mix(branch1, branch2, condition);
}

vec3 quantize_color(vec3 color, float steps) {
    return floor(color * steps) / steps;
}

void fragment() {
    // 1. Setup Resolutions
    vec2 screen_res = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 low_res = screen_res / virtual_res_scale;
    
    // 2. PS1 Jitter (UV Snapping)
    vec2 jitter_uv = SCREEN_UV;
    float time_snap = floor(TIME * 15.0); // Snap noise to 15fps for retro feel
    float jitter_noise = fract(sin(dot(vec2(time_snap), vec2(12.9898, 78.233))) * 43758.5453);
    jitter_uv += (jitter_noise - 0.5) * jitter_instability * jitter_intensity;
    
    // Snapping to the virtual grid
    vec2 grid_uv = floor(jitter_uv * low_res) / low_res;

    // 3. VHS Warble
    vec2 warble_offset = vec2(
        sin(TIME * warble_speed + grid_uv.x * 10.0) * cos(TIME * warble_speed * 0.7 + grid_uv.y * 7.0),
        cos(TIME * warble_speed * 0.8 + grid_uv.y * 11.0) * sin(TIME * warble_speed * 0.9 + grid_uv.x * 8.0)
    ) * warble_amount;
    
    vec2 final_uv = clamp(grid_uv + warble_offset, vec2(0.0), vec2(1.0));

    // 4. Color Sampling with Chromatic Aberration
    vec3 col;
    col.r = texture(SCREEN_TEXTURE, final_uv + vec2(chromatic_aberration, 0.0)).r;
    col.g = texture(SCREEN_TEXTURE, final_uv).g;
    col.b = texture(SCREEN_TEXTURE, final_uv - vec2(chromatic_aberration, 0.0)).b;

    // 5. Color Quantization
    if (enable_color_quantization) {
        col = quantize_color(col, color_quant_steps);
    }

    // 6. Grain
    float lum = dot(col, vec3(0.299, 0.587, 0.114));
    float factor = 1.0 - smoothstep(min_lum, max_lum, lum);
    vec2 noise_uv = final_uv + vec2(sin(TIME * time_scale), cos(TIME * time_scale)) * 20.0;
    vec3 grain = vec3(noise(noise_uv), noise(noise_uv + 0.1), noise(noise_uv + 0.2)) * grain_intensity * factor;
    vec3 processed_color = soft_light(col, clamp(vec3(0.5) + grain, 0.0, 1.0));

    // 7. Vignette
    float aspect = screen_res.x / screen_res.y;
    vec2 v_uv = SCREEN_UV - 0.5;
    v_uv.x *= aspect;
    float dist = length(v_uv);
    float inner_rad = min(vignette_inner_radius, vignette_outer_radius - 0.01); 
    float vignette_pct = smoothstep(vignette_outer_radius, inner_rad, dist);
    processed_color *= mix(1.0 - vignette_darkness, 1.0, vignette_pct);

    COLOR = vec4(processed_color, 1.0);
}