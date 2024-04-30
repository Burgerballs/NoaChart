shader_type canvas_item;
		
uniform vec3 r : source_color;
uniform vec3 g : source_color;
uniform vec3 b : source_color;
uniform float mult;

void fragment() {
	vec4 color = COLOR;
	vec4 newColor = color;
	newColor.rgb = min(color.r * r + color.g * g + color.b * b, vec3(1.0));
	newColor.a = color.a;

	color = mix(color, newColor, mult);

	if(color.a > 0.0) {
		COLOR = vec4(color.rgb, color.a);
	}
	else{
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);	
	}

}