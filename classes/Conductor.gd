extends Node
## Param Variables
var time_sig = [4,4] ## beats per bar, steps per beat
var bpm:float = 97## in decimal
var bps:float:
	get:
		return bpm / 60
## Performance Variables
static var position = 0.0 ## in secondsd
var step:float:
	get:
		return (position * bps) * time_sig[1]
var beat:float:
	get:
		return position * bps
var bar:float:
	get:
		return (position * bps) / time_sig[0]
var step_f:int:
	get:
		return floor(step)
var beat_f:int:
	get:
		return floor(beat)
var bar_f:int:
	get:
		return floor(bar)
## Computation Variables
var prev_step = 0
var prev_beat = 0
var prev_bar = 0


var crotchet: float:
	get:
		return (60.0 / bpm)
var step_crotchet: float:
	get:
		return (60.0 / bpm) / time_sig[1]

var song_paused = false
var debug_metronome = false

var linked_stream:AudioStreamPlayer

signal bar_hit(bar:int)
signal beat_hit(beat:int)
signal step_hit(step:int)

## Input Variables

var hit_time = (10.0 / 60) * 1000
func _ready():
	connect('beat_hit', debug_metronome_func)
	
func _physics_process(delta):
	if (linked_stream!=null and not song_paused):
		position += delta
		if absf(position - linked_stream.get_playback_position()) >= 0.015:
			linked_stream.seek(position)
	if step_f != prev_step:
		step_hit.emit(step_f)
	if beat_f != prev_beat:
		beat_hit.emit(beat_f)
	if bar_f != prev_bar:
		bar_hit.emit(bar_f)
	prev_step = step_f
	prev_beat = beat_f
	prev_bar = bar_f
func link(stream_player:AudioStreamPlayer):
	linked_stream = stream_player
	linked_stream.connect('finished', func(): linked_stream = null)
	step_hit.emit(0)
	beat_hit.emit(0)
	bar_hit.emit(0)
func debug_metronome_func(b):
	if debug_metronome:
		Globals.play_sound(load("res://audio/metronome_tick.mp3"), 2 if b % time_sig[0] == 0 else 1)
		
