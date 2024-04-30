class_name Note
extends Node2D

@onready var renderer = $renderer
@onready var renderer_sus = $"renderer-sus"
@onready var renderer_lmr = $"renderer-lmr"
var time_pos:float = 0.0 ## in seconds
var original_sustain_length:float = 0.0
var sustain_length:float = 0.0
var key:int = 0
var type:String = ''
var has_sustain:
	get:
		return sustain_length >= Conductor.step_crotchet/32
var had_sustain:
	get:
		return !has_sustain && original_sustain_length >= Conductor.step_crotchet/32
var can_hit = false
var too_late = false
var draining_sustain = false
var can_release = false
var missed = false
var note_portion_hit = false

var distance:float:
	get:
		return time_pos - Conductor.position
var distance_ms:float:
	get:
		return (time_pos - Conductor.position) * 1000.0
var distance_from_end:float:
	get:
		return (time_pos + original_sustain_length) - Conductor.position
		
var velocity:float = 1.0 # funny var im too bored to talk about
var canHitKeys: #used for lmr
	get:
		match (type):
			'lmr':
				if key == 0:
					return [0, 1]
				elif key == 1 or key == 2:
					return [1,2]
				else:
					return [2,3]
			_:
				return [key]
		return [key]
		
var lmrPalletes = [
	[Color('0000ff'), Color('5b00ff'), Color('ffffff')], # left
	[Color('21b454'), Color('40e000'), Color('ffffff')], # middle
	[Color('ff0000'), Color('ff6b35'), Color('ffffff')], # right
]
func doThings():
	if type == 'lmr':
		sustain_length = 0
		renderer_lmr.material.set_shader_parameter('r', lmrPalletes[canHitKeys[1]-1][0])
		renderer_lmr.material.set_shader_parameter('g', lmrPalletes[canHitKeys[1]-1][1])
		renderer_lmr.material.set_shader_parameter('b', lmrPalletes[canHitKeys[1]-1][2])
func _physics_process(delta):
	renderer_sus.visible = has_sustain && type != 'lmr'
	renderer.visible = !has_sustain && type != 'lmr'
	renderer_lmr.visible = type == 'lmr'
	can_hit = abs(distance_ms) <= Conductor.hit_time
	can_release = abs(distance_from_end*1000) <= Conductor.hit_time
	if note_portion_hit && has_sustain && draining_sustain:
			sustain_length -= delta
	if !can_hit && distance_ms <= -Conductor.hit_time && !note_portion_hit:
		too_late = true
