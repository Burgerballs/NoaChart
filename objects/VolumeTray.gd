extends Panel

@onready var label = $Label
@onready var animThing = $AnimationPlayer
@onready var bars = $Node2D.get_children()
@onready var volicon = $"Volume-icons"
var busses = ['Master', 'Music', 'SFX']
var bussprite = [0, 2, 1]
var curBus = 0
var show = false
var timerthing = 0.0
var percentage:
	get:
		return (AudioServer.get_bus_volume_db(curBus) + 80) / 80 * 100
func _ready():
	modulate.a = 0
func _process(delta):
	modulate.a = lerpf(modulate.a,1 if show else 0,0.1-delta)
	show = timerthing > 0
	timerthing -= delta
func _unhandled_key_input(event):
	if Input.is_action_just_pressed('volbusminus'):
		bus_change(-1)
	if Input.is_action_just_pressed('volbusplus'):
		bus_change(1)
	if Input.is_action_just_pressed('volminus'):
		volume_change(-8)
	if Input.is_action_just_pressed('volplus'):
		volume_change(8)
func bus_change(change:int = 0):
	curBus = wrapi(curBus + change, 0, busses.size())
	preview()
func volume_change(change:float = 0):
	animThing.stop()
	animThing.play('bounce')
	AudioServer.set_bus_volume_db(curBus, clamp(AudioServer.get_bus_volume_db(curBus) + change, -80, 0))
	preview()
func preview():
	timerthing = 1
	volicon.frame_coords.x = bussprite[curBus]
	Globals.play_sound(load('res://audio/SE_yap.ogg'), 1, 0, 1, busses[curBus])
	for i in range(bars.size()):
		var bar = bars[i]
		bar.modulate = Color.DARK_GRAY if i >= percentage/10 else Color.WHITE
	label.text = '<Z '+busses[curBus] + ' - ' + str(percentage) + '% X>' 
