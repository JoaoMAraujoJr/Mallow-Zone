shader_type particles;

uniform float emitter_rotation = 0.0; // em radianos

void process() {
    float cos_r = cos(emitter_rotation);
    float sin_r = sin(emitter_rotation);

    // TRANSFORM é uma matriz 2x2 + posição interna
    // Multiplicamos só a parte linear (rotação + escala)
    mat2 rot = mat2(cos_r, -sin_r,
                    sin_r, cos_r);

    TRANSFORM[0] = rot * TRANSFORM[0]; // linha X
    TRANSFORM[1] = rot * TRANSFORM[1]; // linha Y
}
