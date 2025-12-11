shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform float strength : hint_range(0.0, 1.0) = 0.0; // lo ligamos a drunk_amount
uniform float time : hint_range(0.0, 1000.0) = 0.0;

void fragment() {
    vec2 uv = SCREEN_UV;

    // Pequeña ondulación vertical
    float wave = sin(uv.x * 20.0 + time * 3.0) * 0.005 * strength;
    uv.y += wave;

    // Doble visión muy sutil: separamos canales
    vec2 off = vec2(0.003 * strength, 0.0);

    vec3 col;
    col.r = texture(SCREEN_TEXTURE, uv + off).r;
    col.g = texture(SCREEN_TEXTURE, uv).g;
    col.b = texture(SCREEN_TEXTURE, uv - off).b;

    COLOR = vec4(col, 1.0);
}