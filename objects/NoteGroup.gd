extends Node2D
@onready var game = $'../'
@onready var playerStrums = $'../Strumline'
@onready var notes:
	get:
		return get_children()
func _physics_process(delta):
	var scroll_speed = playerStrums.scroll_speed
	for note in notes:
		var note_y_math = ((-note.distance) * (playerStrums.global_position.y * (1000.0/scroll_speed))) if not note.draining_sustain else 0
		note.global_position.y = floor(playerStrums.global_position.y + note_y_math)
		note.global_position.x = playerStrums.receptors[note.canHitKeys[0]].global_position.x + 16
		if note.has_sustain == true:
			var sustainRendLength = floor(note.sustain_length * (playerStrums.global_position.y * (1000.0/scroll_speed)))
			note.renderer_sus.position.y = -sustainRendLength
			note.renderer_sus.size.y = sustainRendLength
