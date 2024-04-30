extends Control
var shake_position = Vector2(0,0)
var shake_amplitude = 0;

func _physics_process(delta):
	position.x = shake_position.x + randf_range(-shake_amplitude, shake_amplitude)
	position.y = shake_position.y + randf_range(-shake_amplitude, shake_amplitude)
	shake_amplitude = lerpf(shake_amplitude,0,0.1-delta)
