shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_strength : hint_range(0.0, 8.0) = 2.0;

void fragment() {
    vec2 pixel = SCREEN_PIXEL_SIZE * blur_strength;
    vec4 col = vec4(0.0);

    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-pixel.x, -pixel.y));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2( 0.0,     -pixel.y));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2( pixel.x, -pixel.y));

    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-pixel.x,  0.0));
    col += texture(SCREEN_TEXTURE, SCREEN_UV);
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2( pixel.x,  0.0));

    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-pixel.x,  pixel.y));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2( 0.0,      pixel.y));
    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2( pixel.x,  pixel.y));

    COLOR = col / 9.0;
}
