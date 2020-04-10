shader_type canvas_item;

uniform sampler2D noise_texture : hint_albedo;
uniform float texture_offset_amp : hint_range(0.01, 3.0, 0.01);
uniform sampler2D gradient_texture; 
uniform float scroll_speed : hint_range(0.0, 2.0, 0.1);
uniform float pulse_speed : hint_range(0.0, 10.0, 0.1);
uniform sampler2D normal_map : hint_albedo;

void fragment() {
	vec4 noise = texture(noise_texture, vec2(UV.x - TIME * pulse_speed, UV.y));
	vec4 noise2 = texture(noise_texture, vec2(UV.y - TIME * pulse_speed, UV.x));
	vec2 mixed_offset = (vec2(noise.rg * texture_offset_amp) - vec2(noise2.rg * texture_offset_amp));
	vec4 tex = texture(TEXTURE, vec2(UV.x - TIME * scroll_speed, UV.y) + mixed_offset);
	
	vec3 final_color = (tex.a * texture(gradient_texture, vec2(cos(UV.x - TIME * scroll_speed), UV.y) + mixed_offset).rgb);
	float final_alpha = tex.a * noise.a;

	COLOR = vec4(final_color, final_alpha);
	
}