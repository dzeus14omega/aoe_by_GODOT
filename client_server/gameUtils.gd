extends Node


const SAVE_PATH = "user://config.cfg"
const maxSoundMaster = 40

var _config_file = ConfigFile.new()

var sound_volumn : float = 100
var music_volumn : float = 100
var sound_master : float = maxSoundMaster

var history_playerName = ""
var history_playerHostIP = ""

#for calculate and return
var output_sound_volumn = 0.0
var output_music_volumn = 0.0

#flag
var _flagBeginGame = true


func _ready():
	var load_configResponse = _config_file.load(SAVE_PATH)
	#print("load status: " + str(load_configResponse))
	if (load_configResponse == OK):
		sound_volumn = _config_file.get_value("gameSection","sound_volumn", sound_volumn)
		music_volumn = _config_file.get_value("gameSection","music_volumn", music_volumn)
		sound_master = _config_file.get_value("gameSection","sound_master", sound_master)
		history_playerName = _config_file.get_value("gameSection","history_playerName", history_playerName)
		history_playerHostIP = _config_file.get_value("gameSection","history_playerHostIP", history_playerHostIP)
		#print(music_volumn)
		
		output_sound_volumn = -(maxSoundMaster - (sound_master * sound_volumn / 100.0))
		output_music_volumn = -(maxSoundMaster - (sound_master * music_volumn / 100.0))
		#print(output_music_volumn)
		update_volumn()
		playAudioMenu()
	else:
		output_sound_volumn = -(maxSoundMaster - (sound_master * sound_volumn / 100.0))
		output_music_volumn = -(maxSoundMaster - (sound_master * music_volumn / 100.0))
		save_setting()
		playAudioMenu()
	
	
	#print("output sound= " + str(output_sound_volumn))
	#print("output music= " +str(output_music_volumn))
	pass # Replace with function body.

#func _process(delta):
#	if _flagBeginGame:
#		_flagBeginGame = false
#		playAudioMenu()

func save_setting():
	_config_file.set_value("gameSection", "sound_volumn", sound_volumn)
	_config_file.set_value("gameSection", "music_volumn", music_volumn)
	_config_file.set_value("gameSection", "sound_master", sound_master)
	_config_file.set_value("gameSection", "history_playerHostIP", history_playerHostIP)
	_config_file.set_value("gameSection", "history_playerName", history_playerName)
	_config_file.save(SAVE_PATH)
	
	#calculate real sound and music volumn return
	output_sound_volumn = -(maxSoundMaster - (sound_master * sound_volumn / 100.0))
	output_music_volumn = -(maxSoundMaster - (sound_master * music_volumn / 100.0))
	update_volumn()

func get_VolumnSound():
	return output_sound_volumn

func get_VolumnMusic():
	return output_music_volumn



func update_volumn():
	$backgroundAudioMenu.volume_db = output_music_volumn
	$backgroundAudioLobby.volume_db = output_music_volumn
	$backgroundAudioEndGame.volume_db = output_music_volumn

func playAudioMenu():
	print("playAudio1")
	$backgroundAudioLobby.stream_paused = true
	$backgroundAudioEndGame.stream_paused = true
	if !$backgroundAudioMenu.playing || $backgroundAudioMenu.stream_paused:
		$backgroundAudioMenu.stream_paused = false
		$backgroundAudioMenu.play()
	

func playAudioLobby():
	print("playAudio2")
	$backgroundAudioMenu.stream_paused = true
	$backgroundAudioEndGame.stream_paused = true
	if !$backgroundAudioLobby.playing || $backgroundAudioLobby.stream_paused:
		$backgroundAudioLobby.stream_paused = false
		$backgroundAudioLobby.play()


func playAudioEndgame():
	$backgroundAudioEndGame.play()
	$backgroundAudioMenu.stop()
	$backgroundAudioLobby.stop()

func stopAllAudio():
	$backgroundAudioEndGame.stop()
	$backgroundAudioMenu.stop()
	$backgroundAudioLobby.stop()

func _on_backgroundAudioMenu_finished():
	$backgroundAudioMenu.play()
	pass # Replace with function body.

func _on_backgroundAudioLobby_finished():
	pass # Replace with function body.

func _on_backgroundAudioEndGame_finished():
	pass # Replace with function body.
