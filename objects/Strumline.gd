extends Sprite2D

@export var scroll_speed = 400 ## milliseconds visible onscreen
@onready var receptors = $HBoxContainer.get_children()

signal held(k:int)
signal pressed(k:int)
signal released(k:int)

var key_pressed = [false,false,false,false]
var key_held = [false,false,false,false]
var key_released = [false,false,false,false]

func _physics_process(event):
	var itr = 0
	for r in receptors:
		if Input.is_action_pressed(r.key):
			held.emit(itr)
		if Input.is_action_just_pressed(r.key):
			pressed.emit(itr)
		if Input.is_action_just_released(r.key):
			released.emit(itr)
		key_held[itr] = Input.is_action_pressed(r.key)
		key_pressed[itr] = Input.is_action_just_pressed(r.key)
		key_released[itr] = Input.is_action_just_released(r.key)
		itr+=1
