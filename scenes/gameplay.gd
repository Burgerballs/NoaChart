extends Node2D
@onready var playerStrums = $Strumline
@onready var noteGroup = $NoteGroup
@onready var debugkeys :Array[Dictionary] = Conductor.get_script().get_script_property_list()
var songData:SongData
var dataNotes:Array[NoteData]
var totalPlayed:float = 0
var totalHit:float = 0

var accuracy:float:
	get:
		return (totalHit / totalPlayed) * 100.0

var accuracyStr:String:
	get:
		if accuracy != 0 && !is_nan(accuracy):
			return str(snappedf(accuracy, 0.01))
		return '???'
@onready var accuracyText = $Accuracy

var combo:int = 0
var comboStr:String:
	get:
		return 'x' + str(combo)
@onready var comboText = $Combo

var score:int = 0
var scoreStr:String:
	get:
		var scorething:String = str(score)
		if scorething.length() != 9:
			for i in range(9 - scorething.length()):
				scorething = '0' + scorething
		return scorething
@onready var scoreText = $Score
var misses:int = 0
var missesStr:String:
	get:
		return str(misses)
@onready var missesText = $Misses
var rankStr:String:
	get:
		for i in range(ratings.size()):
			if i+1 > ratings.size()-1 or ratings[i+1][3] == 0 && ratings[i][3] != 0:
				return ratings[i][2]
		return '?'
var gradeStr:String:
	get:
		for i in grades:
			if i[1] <= accuracy:
				return i[0]
		return '?'
@onready var gradeText = $Grade
var rankColor:Color:
	get:
		for i in range(ratings.size()):
			if i+1 > ratings.size()-1 or ratings[i+1][3] == 0 && ratings[i][3] != 0:
				return ratings[i][4]
		return Color.DARK_SLATE_GRAY
@onready var rankText = $Rank
var gradeColor:Color:
	get:
		for i in grades:
			if i[1] <= accuracy:
				return i[2]
		return Color.DARK_SLATE_GRAY
var gradeProgPrecent:float:
	get:
		for i in grades:
			if i[1] <= accuracy && i[1] != grades[0][1]:
				return (accuracy - i[1]) / (grades[i[3]-1][1] - i[1]) * 100
		return 0.0
@onready var gradeProgBar = $Grade/Progress
var timePercent:float:
	get:
		if Conductor.linked_stream:
			return Conductor.position / Conductor.linked_stream.get_stream().get_length() * 100
		return Conductor.position / (Conductor.crotchet*-4)*100;
var timeStr:String:
	get:
		if Conductor.linked_stream:
			return format_to_time(Conductor.position) + '/' +  format_to_time(Conductor.linked_stream.get_stream().get_length())
		return format_to_time(-Conductor.position) + '/' +  format_to_time(Conductor.crotchet*4)
var rankRainbow:bool:
	get:
		return rankColor == Color.WHITE
var gradeRainbow:bool:
	get:
		return gradeColor == Color.WHITE
@onready var timeBar = $ProgressBar
@onready var timeBarLabel = $ProgressBar/Label

var ratings = [ # [name, mult, rank, count, color] (Mult is also used for timings)
	['Cheesy!', 0, ':3', 0, Color.WHITE],
	['Mature', 0.2, ':]', 0, Color.DARK_ORANGE],
	['Moldy', 0.5, ':V', 0, Color.ORANGE_RED],
	['Spoilt', 1, ':c', 0, Color.GRAY],
	['Out-Of-Date', 2, ':(', 0, Color.DARK_SLATE_GRAY],
	['NULL', 2, '?', 0, Color.DARK_SLATE_GRAY],
]
var grades = [ # [name, acc, color]
	['S+', 100, Color.WHITE, 0],
	['S', 98, Color.DARK_CYAN, 1],
	['A+', 96, Color.GREEN, 2],
	['A', 93, Color.SEA_GREEN, 3],
	['B', 90, Color.YELLOW, 4],
	['C', 80, Color.ORANGE, 5],
	['D', 70, Color.DARK_SLATE_GRAY, 6]
]
var stupid_chart_issue = true # disable when testing Friday Night Funkin' Kade Engine charts

var canSkip:
	get:
		return (Conductor.position <= skipTime) && !doingCountdown
var skipTime = 1
@onready var skip_label = $skip_label

@onready var doingCountdown = true
@onready var countdownViewer = $Control
@onready var countdownNumber = $Control/Label
@onready var countdownProgress = $Control/RadialProgress
var shakeStrength = 0
func _ready():
	debugkeys.remove_at(0)
	playerStrums.connect('pressed', pressed_strums)
	playerStrums.connect('released', released_strums)
	playerStrums.connect('held', held_strums)
	Conductor.connect('beat_hit', beat_hit)
	load_song()
	Conductor.position -= Conductor.crotchet*4
	await get_tree().create_timer(Conductor.crotchet*4).timeout
	Globals.play_music(load(songData.songFile))
	doingCountdown = false
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(countdownViewer, ^'modulate:a', 0, Conductor.step_crotchet)
func load_song():
	songData = get_from_cache('ice_soup')
	Conductor.bpm = songData.bpm
	dataNotes = songData.notes.duplicate()
	dataNotes.sort_custom(func(a, b): return a.pos < b.pos)
	skipTime = dataNotes[0].pos - (Conductor.crotchet*2)
var prevNote:Note = null
var noteScene = preload('res://objects/Note.tscn')
func spawn_note_loop():
	if dataNotes.size() != 0:
		var i = dataNotes[0]
		if abs(i.pos - Conductor.position)*1000 <= playerStrums.scroll_speed*1.2:
			var note = noteScene.instantiate()
			note.time_pos = i.pos
			note.type = i.type
			var suslength = i.sustain_length
			if suslength != 0:
				note.sustain_length = i.sustain_length + (Conductor.step_crotchet if stupid_chart_issue else 0)
			note.original_sustain_length = note.sustain_length
			note.key = i.key
			if !prevNote or abs(prevNote.time_pos - note.time_pos) >= 0.002: # prevents duplicates
					noteGroup.add_child(note)
			elif note.key != prevNote.key: # hacky solution but idc
				noteGroup.add_child(note)
			note.doThings()
			dataNotes.remove_at(0)
			prevNote = note
func delete_note_loop():
	for note in noteGroup.notes.filter(func(note): return note.too_late && note.position.y >= 480):
		note.queue_free()
func _unhandled_key_input(event):
	if event.is_action_released('skip') && canSkip:
		Conductor.position = skipTime
		Globals.music.volume_db = -80
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(Globals.music, ^'volume_db', 1, Conductor.step_crotchet)
func pressed_strums(k:int):
	if Conductor.linked_stream:
		Conductor.position = Conductor.linked_stream.get_playback_position()
	var inputs: Array = noteGroup.get_children().filter(func(note: Note):
		return (note.canHitKeys.has(k) and not note.too_late and note.can_hit and not note.note_portion_hit)
	)
	inputs.sort_custom(func(a: Note, b: Note): return a.time_pos < b.time_pos)
	if (inputs.size() != 0):
		inputs[0].note_portion_hit = true
		on_hit(inputs[0].distance, inputs[0])
		if (inputs.size() > 1):
			var funnyInputs = inputs.duplicate()
			funnyInputs.remove_at(0)
			for i in funnyInputs:
				if i.time_pos - inputs[0].time_pos <= 0.006:
					i.queue_free()
		if inputs[0].has_sustain:
			inputs[0].sustain_length += inputs[0].distance
		else:
			inputs[0].queue_free()	
func released_strums(k:int):
	var inputs: Array = noteGroup.get_children().filter(func(note: Note):
		return (note.note_portion_hit and (note.has_sustain or note.had_sustain) and note.can_release and !note.too_late and k == note.key and note.draining_sustain)
	)
	inputs.sort_custom(func(a: Note, b: Note): return a.time_pos < b.time_pos)
	if (inputs.size() != 0):
		inputs[0].queue_free()
func held_strums(k:int):
	pass
	

func get_from_cache(name):
	if Globals.cachedCharts.has(name):
		return Globals.cachedCharts[name]
	else:
		var tempData = SongData.new()
		tempData.loadSong(name)
		for i in DirAccess.get_files_at('res://charts/'+name+'/'):
			if i.ends_with('.ogg') or i.ends_with('.mp3') or i.ends_with('.wav'):
				tempData.songFile = 'res://charts/'+name +'/'+ i
				break
		return tempData
func on_hit(note_distance:float, note:Note):
	var diff = abs(note.distance_ms)
	var tempthing = range(ratings.size())
	tempthing.reverse()
	for ra in tempthing:
		var r = ratings[-ra]
		if diff > (Conductor.hit_time*r[1]):
			r[3] += 1
			totalHit += 1 - r[1] # add accuracy mult
			totalPlayed += 1 
			break
	score+= float(350) * diff_mult(diff)
	combo += 1
	
func diff_mult(diff):
	return (-diff + Conductor.hit_time) / Conductor.hit_time
func miss(note:Note):
	totalPlayed += 1
	misses += 1
	combo=0
	note.missed = true
	pass

func update_text():
	accuracyText.text = accuracyStr
	scoreText.text = scoreStr
	rankText.text = rankStr
	gradeText.text = gradeStr
	missesText.text = missesStr
	gradeText.self_modulate = gradeColor
	rankText.self_modulate = rankColor
	timeBar.value = timePercent
	timeBarLabel.text = timeStr
	gradeProgBar.value = gradeProgPrecent
	comboText.text = comboStr
	gradeText.material.set_shader_parameter('enabled', gradeRainbow)
	rankText.material.set_shader_parameter('enabled', rankRainbow)
func beat_hit(b):
	if b <= 0 && doingCountdown:
		countdownNumber.text = str(-b)
		if b == 0:
			countdownNumber.text = 'GO!'
		countdownViewer.shake_amplitude = 2 * (4 + b)
		Globals.play_sound(load("res://audio/SE_jumpBlock.ogg"))
func _process(delta):
	spawn_note_loop()
	delete_note_loop()
	update_text()
	if Conductor.position < 0:
		Conductor.position += delta
	if doingCountdown:
		countdownProgress.progress = Conductor.position / (Conductor.crotchet*4)
	$Label.text =''
	for key in debugkeys:
		$Label.text+=key.name +': '+ str(Conductor.get(key.name)) + '\n'
	for note in noteGroup.notes:
		note.draining_sustain = note.note_portion_hit and note.has_sustain and !note.too_late and playerStrums.key_held[note.key]
		if !note.draining_sustain && note.note_portion_hit && note.has_sustain:
			note.too_late = true
		if note.too_late && !note.missed:
			miss(note)
	skip_label.modulate.a = lerpf(skip_label.modulate.a,1 if canSkip else 0,0.1-delta)
	
# Thanks Gabi :3333 Modified slightly by me
func format_to_time(value: float) -> String:
	var formatter: String = "%02d:%02d:%02d" % [
		float_to_minute(value),
		float_to_seconds(value),
		float_to_ms(value)
	]
	
	var hours: int = float_to_hours(value)
	if hours != 0: # append hours if needed
		formatter = ("%02d:" % hours) + formatter
	return formatter
func float_to_hours(value: float) -> int: return int(value / 3600.0)
func float_to_minute(value: float) -> int: return int(value / 60) % 60
func float_to_seconds(value: float) -> float: return fmod(value, 60)
func float_to_ms(value: float) -> float: return fmod(value * 1000, 1000)
