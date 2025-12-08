shader_type canvas_item;

uniform float dark_amount : hint_range(0.0, 1.0) = 0.6;
uniform vec3 tint_color : source_color = vec3(0.0, 0.0, 0.0);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Ler o que xa se debuxou na pantalla (escenario)
    vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Escurecer / tinguir
    vec3 darkened = mix(col.rgb, col.rgb * tint_color, dark_amount);

    COLOR = vec4(darkened, col.a);
}