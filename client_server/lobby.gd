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

	$Connect.hide()
	$Players.show()
	$AnimationPlayer.play("colorPane_in")
	$Connect/ErrorLabel.text = ""

	var player_name = $Connect/Name.text
	gamestate.host_game(player_name)
	
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
		$Players/List.add_item(p)

	$Players/Start.visible = get_tree().is_network_server()

func refresh_colorPane():
	pass

func _on_start_released():
	gamestate.begin_game()


func _on_Leave_pressed():
	gamestate.end_game()
	get_tree().get_network_peer().close_connection(200)
	
	pass # Replace with function body.


func _on_BackMenu_pressed():
	pass # Replace with function body.
