extends Panel

## the key that will be used for hitting the receptor's designated lane.
@export var key = 'k1'
func _process(delta):
	modulate.a = 0.7 if Input.is_action_pressed(key) else 1
