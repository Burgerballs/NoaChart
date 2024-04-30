class_name SongData
var notes:Array[NoteData]
var bpm:float = 97
var songFile:String = ''
var song_name:String = 'song'
func loadSong(name):
	var json_instance = JSON.new()
	var chart = FileAccess.get_file_as_string('res://charts/'+name+'/chart.json')
	var song_data = json_instance.parse_string(chart)
	for i in song_data['song']['notes']:
		for n in i['sectionNotes']:
			var note:NoteData = NoteData.new()
			if n[1] <4:
				note.key = n[1]
				note.pos = n[0]/1000
				note.sustain_length = n[2]/1000
				if n.size() ==4:
					note.type = n[3]
				notes.push_front(note)
	song_name = song_data['song']['song']
	bpm = song_data['song']['bpm']
	print(song_name+': ', notes.size(), ' notes')
