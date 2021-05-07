extends Control

func _ready():
	# Called every time the node is added to the scene.
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")
	gamestate.connect("player_colorPane_changed", self, "refresh_colorPane")
	# Set the player name according to the system username. Fallback to the path.
	if OS.has_environment("USERNAME"):
		$Connect/Name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		$Connect/Name.text = desktop_path[desktop_path.size() - 2]


func _on_host_pressed():
	if gamestate.players.size() == 0:
		$Players/Leave.visible = true
	else:
		$Players/Leave.visible = false
	
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return
	
	#set Default color
	gamestate.player_info.colorId = "color1"
	$ColorPane/GridContainer.get_node(gamestate.player_info.colorId).pressed = true
	gamestate.player_info.colorString = $ColorPane/GridContainer/color1.modulate.to_html(false)
	
	$Connect.hide()
	$Players.show()
	$AnimationPlayer.play("colorPane_in")
	$Connect/ErrorLabel.text = ""

	var player_name = $Connect/Name.text
	gamestate.host_game(player_name, gamestate.player_info.colorId)
	
	#$Players/HostIP.text = str(IP.get_local_addresses())
	
	#print(IP.get_instance_id())
	#print(IP.get_local_interfaces())
	var ip_info = ""
	for address in IP.get_local_interfaces():
		#print(address.get("friendly"))
		#ip_info += address.get("friendly")  + "\n"
		if address.get("friendly") == "WiFi":
			ip_info += "Wifi: " + address.get("addresses")[1] + "\n"
		if address.get("friendly") == "Ethernet":
			ip_info += "Ethernet: " + address.get("addresses")[1] + "\n"
		if address.get("friendly") == "wlan0":
			ip_info += "wlan0: " + address.get("addresses")[0] + "\n"
	
	$Players/HostIP.text = ip_info
		
	refresh_lobby()


func _on_join_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	var ip = $Connect/IPAddress.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address!"
		return

	$Connect/ErrorLabel.text = ""
	$Connect/Host.visible = false
	$Connect/Join.visible = false

	var player_name = $Connect/Name.text
	gamestate.join_game(ip, player_name)
	


func _on_connection_success():
	$Connect.hide()
	$Players.show()
	$AnimationPlayer.play("colorPane_in")
	if not is_network_master():
		#print("not network master")
		$Players/Leave.visible = true
	else:
		#print("is master")
		$Players/Label.visible = false


func _on_connection_failed():
	$Connect/Host.visible = true
	$Connect/Join.visible = true
	$Connect/ErrorLabel.set_text("Connection failed.")

func _on_game_ended():
	get_tree().get_network_peer().close_connection(200)
	show()
	$Connect.show()
	$Players.hide()
	$AnimationPlayer.play_backwards("colorPane_in")
	$Connect/Host.visible = true
	$Connect/Join.visible = true


func _on_game_error(errtxt):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered_minsize()
	$Connect/Host.visible = true
	$Connect/Join.visible = true


func refresh_lobby():
	if get_tree().is_network_server():
		if gamestate.players.size() == 0:
			$Players/Leave.visible = true
		else:
			$Players/Leave.visible = false
	
	var players = gamestate.get_player_list()
	players.sort()
	$Players/List.clear()
	$Players/List.add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		$Players/List.add_item(p.player_name)

	$Players/Start.visible = get_tree().is_network_server()

func refresh_colorPane():
	for button in $ColorPane/GridContainer.get_children():
		button.disabled = false
	
	for other_playerInfo in gamestate.players:
		if gamestate.players[other_playerInfo].colorId != "":
			#print(gamestate.players[other_playerInfo].colorId)
			$ColorPane/GridContainer.get_node(gamestate.players[other_playerInfo].colorId).disabled = true
			gamestate.players[other_playerInfo].colorString = $ColorPane/GridContainer.get_node(gamestate.players[other_playerInfo].colorId).modulate.to_html(false)
		#$ColorPane/GridContainer/color1.modulate.to_html(false)
	
	#set default color for new player connected
	if (gamestate.player_info.colorId == ""):
		for button in $ColorPane/GridContainer.get_children():
			if button.disabled == false:
				gamestate.player_info.colorId = button.get_name()
				button.pressed = true
				button.emit_signal("button_down")
	pass

func reset_colorPane():
	for button in $ColorPane/GridContainer.get_children():
		button.disabled = false
		button.pressed = false

func _on_start_released():
	gamestate.begin_game()

func _on_Leave_pressed():
	gamestate.end_game()
	pass # Replace with function body.

func _on_Color_selected():
	pass
	
func _on_BackMenu_pressed():
	reset_colorPane()
	get_tree().change_scene("res://scenes/mainMenu.tscn")
	pass # Replace with function body.

#===========================Button Control======================================
func _on_color1_button_down():
	#if (!$ColorPane/GridContainer/color1.pressed):
	var colorString = $ColorPane/GridContainer/color1.modulate.to_html(false)
	gamestate.onColorPaneChange("color1", colorString)
		#print($ColorPane/GridContainer/color1.get_name())
	pass # Replace with function body.

func _on_color2_button_down():
	#if (!$ColorPane/GridContainer/color2.pressed):
	var colorString = $ColorPane/GridContainer/color2.modulate.to_html(false)
	gamestate.onColorPaneChange("color2", colorString)
		#print("ok")
	pass # Replace with function body.

func _on_color3_button_down():
	#if (!$ColorPane/GridContainer/color3.pressed):
	var colorString = $ColorPane/GridContainer/color3.modulate.to_html(false)
	gamestate.onColorPaneChange("color3", colorString)
	pass # Replace with function body.

func _on_color4_button_down():
	#if (!$ColorPane/GridContainer/color4.pressed):
	var colorString = $ColorPane/GridContainer/color4.modulate.to_html(false)
	gamestate.onColorPaneChange("color4", colorString)
	pass # Replace with function body.

func _on_color5_button_down():
	#if (!$ColorPane/GridContainer/color5.pressed):
	var colorString = $ColorPane/GridContainer/color5.modulate.to_html(false)
	gamestate.onColorPaneChange("color5", colorString)
	pass # Replace with function body.

func _on_color6_button_down():
	#if (!$ColorPane/GridContainer/color6.pressed):
	var colorString = $ColorPane/GridContainer/color6.modulate.to_html(false)
	gamestate.onColorPaneChange("color6", colorString)
	pass # Replace with function body.

func _on_color7_button_down():
	#if (!$ColorPane/GridContainer/color7.pressed):
	var colorString = $ColorPane/GridContainer/color7.modulate.to_html(false)
	gamestate.onColorPaneChange("color7", colorString)
	pass # Replace with function body.

func _on_color8_button_down():
	#if (!$ColorPane/GridContainer/color8.pressed):
	var colorString = $ColorPane/GridContainer/color8.modulate.to_html(false)
	gamestate.onColorPaneChange("color8", colorString)
	pass # Replace with function body.

func _on_color9_button_down():
	#if (!$ColorPane/GridContainer/color9.pressed):
	var colorString = $ColorPane/GridContainer/color9.modulate.to_html(false)
	gamestate.onColorPaneChange("color9", colorString)
	pass # Replace with function body.

func _on_color10_button_down():
	#if (!$ColorPane/GridContainer/color10.pressed):
	var colorString = $ColorPane/GridContainer/color10.modulate.to_html(false)
	gamestate.onColorPaneChange("color10", colorString)
	pass # Replace with function body.

func _on_color11_button_down():
	#if (!$ColorPane/GridContainer/color11.pressed):
	var colorString = $ColorPane/GridContainer/color11.modulate.to_html(false)
	gamestate.onColorPaneChange("color11", colorString)
	pass # Replace with function body.
