extends Node2D
var checkList:Array:
	get:
		return Array(DirAccess.get_directories_at('res://charts'))
var cachePercent:float:
	get:
		return (float(cachedList.size()) / float(checkList.size())) * 100.0
var cachedList:Array = []
@onready var text = $text
@onready var failed = $failed
@onready var bar = $bar
var finished:bool = false
func _ready():
	await get_tree().create_timer(0.4).timeout
	Globals.play_sound(load('res://audio/SE_select1.ogg'))
	for i in checkList:
		await get_tree().create_timer(0.1).timeout
		Globals.play_sound(load('res://audio/SE_yap.ogg'), 1.0 + (cachePercent/1200))
		call_deferred_thread_group('update_stuff', i)
		call_deferred_thread_group('cache', i)
		call_deferred_thread_group('update_stuff', i)
func _process(delta):
	if !finished && cachePercent == 100:
		text.text = '100% DONE!'
		Globals.play_sound(load('res://audio/SE_select2.ogg'))
		finished = true
func cache(name):
	var songData = SongData.new()
	if FileAccess.file_exists('res://charts/'+name+'/chart.json'):
		songData.loadSong(name)
		call_deferred_thread_group('visibleThing', false)
	else:
		call_deferred_thread_group('visibleThing', true)
	for i in DirAccess.get_files_at('res://charts/'+name):
		if i.ends_with('.ogg') or i.ends_with('.mp3') or i.ends_with('.wav'):
			songData.songFile = 'res://charts/'+name +'/'+ i
	cachedList.push_front(name)
	Globals.cachedCharts.merge({name: songData})
func update_stuff(name):
	text.text = str(cachePercent) + '% "charts/'+name+'"'
	bar.value = cachePercent
func visibleThing(b):
	failed.visible = b
