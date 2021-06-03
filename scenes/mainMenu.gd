extends Control

func _ready():
	gameUtils.playAudioMenu()
	$AnimationPlayer.play("title_fade_in")
	pass # Replace with function body.

func _on_btn_play_button_up():
	get_tree().change_scene("res://scenes/lobby.tscn")
	pass # Replace with function body.

func _on_btn_setting_button_up():
	get_tree().change_scene("res://scenes/Setting.tscn")
	pass # Replace with function body.

func _on_btn_quit_button_up():
	get_tree().quit()
	pass # Replace with function body.
