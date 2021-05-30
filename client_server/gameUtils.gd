extends Node

const SAVE_PATH = "user://config.cfg"
var _config_file = ConfigFile.new()

var sound_volumn : int = 0
var music_volumn : int = 0 
var sound_master : int = 0

var history_playerName = ""
var history_playerHostIP = ""

func _ready():
	var load_configResponse = _config_file.load(SAVE_PATH)
	#print("load status: " + str(load_configResponse))
	if (load_configResponse == OK):
		sound_volumn = _config_file.get_value("gameSection","sound_volumn", sound_volumn)
		music_volumn = _config_file.get_value("gameSection","music_volumn", music_volumn)
		sound_master = _config_file.get_value("gameSection","sound_master", sound_master)
		history_playerName = _config_file.get_value("gameSection","history_playerName", history_playerName)
		history_playerHostIP = _config_file.get_value("gameSection","history_playerHostIP", history_playerHostIP)
		#print(sound_volumn)
	else:
		save_setting()
	pass # Replace with function body.


func save_setting():
	_config_file.set_value("gameSection", "sound_volumn", sound_volumn)
	_config_file.set_value("gameSection", "music_volumn", music_volumn)
	_config_file.set_value("gameSection", "sound_master", sound_master)
	_config_file.set_value("gameSection", "history_playerHostIP", history_playerHostIP)
	_config_file.set_value("gameSection", "history_playerName", history_playerName)
	_config_file.save(SAVE_PATH)

func get_VolumnSound():
	
	pass

func get_VolumnMusic():
	pass
	
