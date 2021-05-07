extends Node

# Default game port. Can be any number between 1024 and 49151.
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 12

# player info.
var player_info = PlayerInfo.new()
#var player_name = "The Warrior"

# Names for remote players in id:name format.
var players = {}
var players_ready = []

#GameResult:
var gameFinalResult : String   ## Victory / Defeated
var total_construction : int = 0 
var total_unitTrain : int = 0
var total_goldEarn : int = 0
var total_pointHold : int = 0


# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)
signal player_colorPane_changed()

# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	#print(id)
	rpc_id(id, "register_player", player_info.player_name, player_info.colorId)

# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/World/kingdoms"): # Game is in progress.
		if get_tree().get_root().get_node("World/kingdoms").get_node(str(id)).has_node("king"):
			if get_tree().is_network_server():
				emit_signal("game_error", "Player " + str(id) + " disconnected")
				end_game()
		else:
			get_tree().get_root().get_node("World/kingdoms").get_node(str(id)).queue_free()
	else: # Game is not in progress
		# Unregister this player.
		unregister_player(id)

# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

# Lobby management functions.
remote func register_player(new_player_name, colorIdUsed):
	var id = get_tree().get_rpc_sender_id()
	var playerInfo = PlayerInfo.new()
	playerInfo.setInfo(new_player_name, colorIdUsed)
	players[id] = playerInfo
	emit_signal("player_list_changed")
	emit_signal("player_colorPane_changed")

func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")

remote func color_picked(colorIdUsed):
	var id = get_tree().get_rpc_sender_id()
	players[id].colorId = colorIdUsed
	emit_signal("player_colorPane_changed")
	#print(colorIdUsed)
	pass

func onColorPaneChange(colorId, colorString):
	player_info.colorId = colorId
	player_info.colorString = colorString
	#print(colorId)
	for orther_player in players:
		#print(orther_player)
		rpc_id(orther_player, "color_picked", colorId)
		pass
	pass

remote func pre_start_game(spawn_points):
	# Change scene.
	var world = load("res://scenes/world.tscn").instance()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("Lobby").hide()

	var player_scene = load("res://actor/Kingdom.tscn")

	for p_id in spawn_points:
		var spawn_pos = world.get_node("SpawnPoints/" + str(spawn_points[p_id])).position
		var player = player_scene.instance()

		player.set_name(str(p_id)) # Use unique ID as node name.
		player.position=spawn_pos
		player.set_network_master(p_id) #set unique id as master.

		if p_id == get_tree().get_network_unique_id():
			# If node for this peer id, set name.
			player.set_player_name(player_info.player_name)
			player.set_player_color(player_info.colorString)
			
		else:
			# Otherwise set name from peer.
			player.set_player_name(players[p_id].player_name)
			player.set_player_color(players[p_id].colorString)
			
		world.get_node("kingdoms").add_child(player)
	
	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!

remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

func host_game(new_player_name, colorId):
	player_info.setInfo(new_player_name, colorId)
	#player_name = new_player_name
	#current_Color = color
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)

func join_game(ip, new_player_name):
	player_info.player_name = new_player_name
	#player_name = new_player_name
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(client)

func get_player_list():
	return players.values()

func get_player_name():
	#return player_name
	return player_info.player_name

func begin_game():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing.
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0.
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points.
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)

	pre_start_game(spawn_points)

func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	emit_signal("game_ended")
	players.clear()

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func reset_GameResult():
	self.total_construction = 0
	self.total_goldEarn = 0
	self.total_unitTrain = 0
	self.total_pointHold = 0
	self.gameFinalResult = ""
	pass

func set_GameFinalResult_and_show(isWin, total_construction, total_unitTrain, total_goldEarn, total_pointHold):
	if (isWin):
		self.gameFinalResult = "Victory"
	else:
		self.gameFinalResult = "Defeated"
		
	self.total_construction = total_construction
	self.total_goldEarn = total_goldEarn
	self.total_unitTrain = total_unitTrain
	self.total_pointHold = total_pointHold
	get_tree().get_root().get_node("World/EndingSceneUI/EndingScene/AnimationEndScene").play("EndingAppear")
	pass
