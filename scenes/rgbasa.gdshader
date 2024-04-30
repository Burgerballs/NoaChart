shader_type canvas_item;
render_mode blend_mix;


uniform bool enabled = true;
// PerlinNoise2D
#include "res://addons/shaderV/rgba/noise/perlin2d.gdshaderinc"

void fragment() {
// Input:5
	vec4 n_out5p0 = COLOR;


// Input:3
	vec2 n_out3p0 = SCREEN_UV;


	float n_out11p0;
// ScaledTIME:11
	float n_in11p0 = 0.60000;
	{
		n_out11p0 = n_in11p0 * TIME;
	}


	float n_out2p0;
// PerlinNoise2D:2
	float n_in2p2 = 1.00000;
	vec3 n_in2p3 = vec3(3.00000, 0.00000, 0.00000);
	{
		n_out2p0 = _perlin2dNoiseFunc((vec3(n_out3p0, 0.0).xy+vec3(n_out11p0).xy)*n_in2p2, n_in2p3.xy);
	}


	float n_out10p0;
// ScaledTIME:10
	float n_in10p0 = 0.40000;
	{
		n_out10p0 = n_in10p0 * TIME;
	}


	float n_out7p0;
// PerlinNoise2D:7
	float n_in7p2 = 1.00000;
	vec3 n_in7p3 = vec3(3.00000, 8.00000, 0.00000);
	{
		n_out7p0 = _perlin2dNoiseFunc((vec3(n_out3p0, 0.0).xy+vec3(n_out10p0).xy)*n_in7p2, n_in7p3.xy);
	}


	float n_out9p0;
// ScaledTIME:9
	float n_in9p0 = 0.20000;
	{
		n_out9p0 = n_in9p0 * TIME;
	}


	float n_out8p0;
// PerlinNoise2D:8
	float n_in8p2 = 1.00000;
	vec3 n_in8p3 = vec3(3.00000, 7.00000, 0.00000);
	{
		n_out8p0 = _perlin2dNoiseFunc((vec3(n_out3p0, 0.0).xy+vec3(n_out9p0).xy)*n_in8p2, n_in8p3.xy);
	}


// VectorCompose:6
	vec3 n_out6p0 = vec3(n_out2p0, n_out7p0, n_out8p0);


// VectorOp:4
	vec3 n_out4p0 = vec3(n_out5p0.xyz) * n_out6p0;


// Output:0
	if (enabled) {
		COLOR.rgb = n_out4p0;	
	}


}
