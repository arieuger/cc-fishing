shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float intensity : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    vec4 dst = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec4 src = texture(TEXTURE, UV);
    if (src.a <= 0.0) {
        COLOR = dst;
    } else {
        vec3 soft = (1.0 - 2.0 * src.rgb) * dst.rgb * dst.rgb
                    + 2.0 * src.rgb * dst.rgb;

        float strength = clamp(src.a * intensity, 0.0, 1.0);
        vec3 final_rgb = mix(dst.rgb, soft, strength);
        COLOR = vec4(final_rgb, dst.a);
    }
}
