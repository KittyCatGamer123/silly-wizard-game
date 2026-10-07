shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 sprite_size = vec2(32.0, 32.0); // sprite size in px
uniform vec2 origin = vec2(0.0, 0.0); // burn start
uniform float borderWidth = 6.0;
uniform float burnMult = 12.0;
uniform float pixel_size = 1.0;
uniform float blend_steps = 4.0;

uniform sampler2D noiseTexture : repeat_enable;
uniform vec4 burnColor : source_color = vec4(1.0, 0.4, 0.05, 1.0);
uniform vec4 charColor : source_color = vec4(0.1, 0.05, 0.05, 1.0);

varying vec2 local_pos;

void vertex() {
    local_pos = VERTEX;
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec2 p = floor(local_pos / pixel_size) * pixel_size;
    float n = texture(noiseTexture, p / sprite_size + 0.5).r;
    float dist = length(p - origin) + n * burnMult;
    float max_reach = length(sprite_size) + burnMult + borderWidth;
    float radius = progress * max_reach - borderWidth;
    float edge = 1.0 - clamp((dist - radius) / borderWidth, 0.0, 1.0);
    edge = floor(edge * blend_steps) / blend_steps;
    vec3 col = mix(tex.rgb, charColor.rgb, smoothstep(0.0, 0.5, edge));
    col = mix(col, burnColor.rgb, smoothstep(0.5, 1.0, edge));
    COLOR = vec4(col, tex.a);
    COLOR.a *= step(radius, dist);
}