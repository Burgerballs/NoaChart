extends Node
# A modified version of code by CrowPlexus!!
var _cfg_file :ConfigFile
var _defaults :Dictionary = {}
const _CFG_PATH = "user://freakyfile.cfg"
var game_scale = 3:
	set(v): 
		var window = get_window()
		window.size = Vector2i(640 * v, 480 * v)
		window.position = DisplayServer.screen_get_size()/2 - (window.size/2)
		game_scale = v
var framerate_cap :int = 120:
	set(v): Engine.max_fps = v; framerate_cap = v
var vsync :bool = true:
	set(v):
		var vsync_mode := DisplayServer.VSYNC_ADAPTIVE if v == true else DisplayServer.VSYNC_DISABLED
		DisplayServer.window_set_vsync_mode(vsync_mode)
		vsync = v

func _ready() -> void:
	load_settings()


## Loads your settings file and sets settings to their respective values
func load_settings() -> void:
	if _cfg_file == null: _cfg_file = ConfigFile.new()

	_cfg_file.load(_CFG_PATH)
	

	var settings_keys :Array[Dictionary] = get_script().get_script_property_list()
	settings_keys.remove_at(0)

	for key in settings_keys:
		if key.name.begins_with("_"): continue
		_defaults[key.name] = get(key.name)

		if _cfg_file.has_section_key("Settings", key.name):
			var new_v = _cfg_file.get_value("Settings", key.name, get(key.name))
			set(key.name, new_v)
		else:
			_cfg_file.set_value("Settings", key.name, get(key.name))
	save_settings()

	_cfg_file.clear()
	_cfg_file.unreference()

## Saves the current state of your settings to your settings file
func save_settings() -> void:
	if _cfg_file == null:
		_cfg_file = ConfigFile.new()
		_cfg_file.load(_CFG_PATH)

	var settings_keys :Array[Dictionary] = get_script().get_script_property_list()
	settings_keys.remove_at(0)

	for key in settings_keys:
		if key.name.begins_with("_"): continue
		_cfg_file.set_value("Settings", key.name, get(key.name))
	

	_cfg_file.save(_CFG_PATH)
	print(FileAccess.file_exists(_CFG_PATH))

	_cfg_file.clear()
	_cfg_file.unreference()
