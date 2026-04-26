shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

// --- PS1 Jitter Settings ---
uniform float jitter_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float virtual_resolution_upscale : hint_range(1.0, 10.0) = 4.0;
uniform float instability : hint_range(0.0, 0.05) = 0.001;

void fragment() {
    // 1. Get the screen resolution
    vec2 screen_res = 1.0 / SCREEN_PIXEL_SIZE;
    
    // 2. Define a "Virtual Grid"
    // PS1 had low precision. We simulate this by scaling down, 
    // flooring the math, and scaling back up.
    vec2 low_res = screen_res / virtual_resolution_upscale;
    
    // 3. Apply the Jitter
    // We add a tiny bit of time-based noise to the UVs before snapping 
    // to create that "shaky" vertex feel.
    vec2 jitter_uv = SCREEN_UV;
    float noise = fract(sin(dot(vec2(floor(TIME * 15.0)), vec2(12.9898, 78.233))) * 43758.5453);
    jitter_uv += (noise - 0.5) * instability * jitter_intensity;
    
    // 4. Snap to the virtual grid (The "Crunchy" movement)
    vec2 grid_uv = floor(jitter_uv * low_res) / low_res;
    
    // 5. Sample the texture
    vec3 col = texture(SCREEN_TEXTURE, grid_uv).rgb;
    
    COLOR = vec4(col, 1.0);
}