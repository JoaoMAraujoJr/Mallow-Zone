shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D curve;
uniform float rotation_speed = -1.0; // rad/s (use radians(...) se quiser inserir graus)

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    vec2 vecToCenter = center - UV;

    // ângulo crescente no tempo
    float angle = TIME * rotation_speed;

    // mat2 espera duas vec2 (colunas). Matriz de rotação:
    // [ cos  -sin ]
    // [ sin   cos ]
    // colunas: vec2(cos, sin), vec2(-sin, cos)
    mat2 rot = mat2(vec2(cos(angle), sin(angle)),
                    vec2(-sin(angle), cos(angle)));

    vec2 rotated = rot * vecToCenter;
    float distToCenter = length(rotated);

    float curveVal = texture(curve, vec2(distToCenter, 0.0)).r;

    // normalização segura (evita divisão por zero no centro)
    vec2 dir = distToCenter > 0.0001 ? rotated / distToCenter : vec2(0.0);
    vec2 diff = dir * 0.6 * curveVal;

    float alpha = smoothstep(0.5, 0.35, distToCenter);

    COLOR = texture(screen_texture, SCREEN_UV + diff);
    COLOR.a = alpha;
}
