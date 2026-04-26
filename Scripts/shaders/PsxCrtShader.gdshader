shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap, repeat_enable;

// --- Controles de Imagem ---
uniform float grain_intensity : hint_range(0.0, 1.0) = 0.1;
uniform float min_lum : hint_range(0.0, 1.0) = 0.0;
uniform float max_lum : hint_range(0.0, 1.0) = 1.0;
uniform float time_scale : hint_range(0.0, 1.0) = 0.5;

// --- Vinheta ---
uniform float vignette_darkness : hint_range(0.0, 1.0) = 0.5;
uniform float vignette_outer_radius : hint_range(0.1, 2.0) = 0.7;
uniform float vignette_inner_radius : hint_range(0.0, 1.9) = 0.2;

// --- Efeitos CRT ---
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.2;
uniform float barrel_distortion : hint_range(0.0, 0.5) = 0.15;
uniform float chromatic_aberration : hint_range(0.0, 0.01) = 0.005;
uniform float crt_vignette_power : hint_range(0.0, 5.0) = 2.0; 

// --- Resolução e Cor ---
uniform int pixel_resolution_x : hint_range(32, 1980) = 320;
uniform int pixel_resolution_y : hint_range(24, 1080) = 240;
uniform bool enable_color_quantization = true;
uniform float color_quant_steps : hint_range(2.0, 64.0) = 32.0;

// --- Warble (Oscilação) ---
uniform float warble_amount : hint_range(0.0, 0.01) = 0.002;
uniform float warble_speed : hint_range(0.0, 10.0) = 5.0;

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
    vec2 uv = SCREEN_UV;
    vec2 res = vec2(float(pixel_resolution_x), float(pixel_resolution_y));
    
    // 1. Distorção de Barril (feita antes para não quebrar a grade de pixels)
    vec2 centered_uv = uv - 0.5;
    float r2 = dot(centered_uv, centered_uv);
    vec2 distorted_uv = centered_uv * (1.0 + barrel_distortion * r2) + 0.5;

    // 2. Pixelização (aplicada sobre a coordenada já distorcida)
    // O +0.5 garante que o sample pegue o centro do "pixel virtual"
    vec2 pixel_uv = (floor(distorted_uv * res) + 0.5) / res;

    // Verifica bordas da distorção
    if (pixel_uv.x < 0.0 || pixel_uv.x > 1.0 || pixel_uv.y < 0.0 || pixel_uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        // 3. Warble (Oscilação de fita VHS)
        vec2 warble_offset = vec2(
            sin(TIME * warble_speed + pixel_uv.x * 10.0) * cos(TIME * warble_speed * 0.7 + pixel_uv.y * 7.0),
            cos(TIME * warble_speed * 0.8 + pixel_uv.y * 11.0) * sin(TIME * warble_speed * 0.9 + pixel_uv.x * 8.0)
        ) * warble_amount;
        
        vec2 final_uv = clamp(pixel_uv + warble_offset, vec2(0.0), vec2(1.0));

        // 4. Amostragem de Cor e Aberração Cromática
        vec3 col;
        col.r = texture(SCREEN_TEXTURE, final_uv + vec2(chromatic_aberration, 0.0)).r;
        col.g = texture(SCREEN_TEXTURE, final_uv).g;
        col.b = texture(SCREEN_TEXTURE, final_uv - vec2(chromatic_aberration, 0.0)).b;

        if (enable_color_quantization) {
            col = quantize_color(col, color_quant_steps);
        }

        // 5. Grão (Grain) baseado na luminosidade
        float lum = dot(col, vec3(0.299, 0.587, 0.114));
        float factor = 1.0 - smoothstep(min_lum, max_lum, lum);
        vec2 noise_uv = pixel_uv + vec2(sin(TIME * time_scale), cos(TIME * time_scale)) * 20.0;
        
        vec3 grain = vec3(noise(noise_uv), noise(noise_uv + 0.1), noise(noise_uv + 0.2)) * grain_intensity * factor;
        vec3 processed_color = soft_light(col, clamp(vec3(0.5) + grain, 0.0, 1.0));

       // 6. Vinheta (ajustada pelo aspect ratio para não ficar oval)
        vec2 screen_res = 1.0 / SCREEN_PIXEL_SIZE;
        float aspect = screen_res.x / screen_res.y;
        vec2 v_uv = distorted_uv - 0.5;
        v_uv.x *= aspect;
        
        float dist = length(v_uv);
        // CORREÇÃO: Usando os nomes completos das uniforms declaradas no topo
        float inner_rad = min(vignette_inner_radius, vignette_outer_radius - 0.01); 
        float vignette_pct = smoothstep(vignette_outer_radius, inner_rad, dist);
        processed_color *= mix(1.0 - vignette_darkness, 1.0, vignette_pct);

        // 7. Scanlines Sincronizadas (O segredo para remover a grade estranha)
        // Usamos a resolução virtual (res.y) para que a linha siga o pixel, não a tela.
        float scanline_alpha = sin(pixel_uv.y * res.y * PI * 2.0);
        scanline_alpha = clamp(scanline_alpha * 0.5 + 0.5, 0.0, 1.0);
        processed_color *= mix(1.0, 1.0 - scanline_intensity, scanline_alpha);

        // 8. CRT Vignette (escurece os cantos da curvatura)
        float crt_v = pow(1.0 - dot(centered_uv, centered_uv) * 2.0, crt_vignette_power);
        processed_color *= clamp(crt_v, 0.0, 1.0);

        COLOR = vec4(processed_color, 1.0);
    }
}