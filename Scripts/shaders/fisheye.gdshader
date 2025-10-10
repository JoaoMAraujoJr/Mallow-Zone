shader_type canvas_item;

// adicione esta linha para ter acesso ao "screen texture" em Godot 4:
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform bool use_screen = true;               // true = amostra a tela; false = amostra TEXTURE do ColorRect
uniform vec2 center = vec2(0.5, 0.5);         // centro do efeito em UV (0..1)
uniform float strength : hint_range(-2.0, 2.0) = 0.6;
uniform float radius : hint_range(0.0, 2.0) = 1.0;
uniform float zoom : hint_range(0.0, 1.0) = 0.0;
uniform float aspect : hint_range(0.1, 10.0) = 1.0; // largura/altura do viewport (ajuste por script)

void fragment() {
    // Fonte de UV: SCREEN_UV para a tela, ou UV para a textura local
    vec2 uv = use_screen ? SCREEN_UV : UV;
    vec2 p = uv - center;

    // corrige por aspect ratio
    p.x *= aspect;
    float r = length(p);

    if (r > 0.0 && r < radius) {
        // mapeamento não-linear para efeito "barrel/fisheye"
        float rn = r * (1.0 + strength * r * r);
        p = (p / r) * rn;
    }

    // desfaz correção de aspect
    p.x /= aspect;

    // aplica zoom (puxa a amostra para o centro)
    vec2 sampled = center + p * (1.0 - zoom);
    sampled = clamp(sampled, vec2(0.0), vec2(1.0));

    // amostra da tela ou da textura
    vec4 col = use_screen ? texture(SCREEN_TEXTURE, sampled) : texture(TEXTURE, sampled);
    COLOR = col;
}
