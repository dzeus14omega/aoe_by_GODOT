extends Control


func _ready():
	$backgroundPanel/masterVolumn_label/masterVolumn_slider.max_value = gameUtils.maxSoundMaster
	$backgroundPanel/masterVolumn_label/masterVolumn_slider.value = gameUtils.sound_master
	$backgroundPanel/musicVolumn_label/musicVolumn_slider.value = gameUtils.music_volumn
	$backgroundPanel/soundVolumn_label/soundVolumn_slider.value = gameUtils.sound_volumn
	pass # Replace with function body.


func _on_BackButton_button_up():
	get_tree().change_scene("res://scenes/mainMenu.tscn")
	pass # Replace with function body.


func _on_SaveButton_button_up():
	gameUtils.sound_master = $backgroundPanel/masterVolumn_label/masterVolumn_slider.value
	gameUtils.music_volumn = $backgroundPanel/musicVolumn_label/musicVolumn_slider.value
	gameUtils.sound_volumn = $backgroundPanel/soundVolumn_label/soundVolumn_slider.value
	gameUtils.save_setting()
	get_tree().change_scene("res://scenes/mainMenu.tscn")
	pass # Replace with function body.
