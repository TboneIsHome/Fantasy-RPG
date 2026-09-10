shader_type canvas_item;
varying vec4 sprite_tint;
void vertex() { sprite_tint = COLOR; }
// A restrained ink edge keeps the mage readable against foliage.
void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	float edge = 0.0;
	edge = max(edge, texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0.0)).a);
	edge = max(edge, texture(TEXTURE, UV - vec2(TEXTURE_PIXEL_SIZE.x, 0.0)).a);
	edge = max(edge, texture(TEXTURE, UV + vec2(0.0, TEXTURE_PIXEL_SIZE.y)).a);
	edge = max(edge, texture(TEXTURE, UV - vec2(0.0, TEXTURE_PIXEL_SIZE.y)).a);
	COLOR = (pixel.a > 0.1 ? pixel : vec4(0.12, 0.16, 0.23, edge * 0.8)) * sprite_tint;
}
