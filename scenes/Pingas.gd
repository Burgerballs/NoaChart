extends Node2D

var snap = 0.25 # snap
@onready var strums = $Strumline
func _ready():
	Globals.play_sound(load('res://audio/pingas.mp3'),1,0,1)
	
func _unhandled_key_input(event):
	if Conductor.song_paused:
		Conductor.position = snappedf(position+(Input.get_axis('ui_down', 'ui_up')*(Conductor.bps*snap)), Conductor.bps*snap)
