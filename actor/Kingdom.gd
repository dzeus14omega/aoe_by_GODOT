class_name Kingdom extends Node2D

var _mainTarget = null
var _networkID
var colorString : String
#var state_command : int
var max_pointHolding = 0

func _ready():
	_networkID = get_tree().get_network_unique_id()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not self.has_node("king"):
		set_process(false)
		#TODO: play lost animation
		#...
		return
		
	if is_network_master():
		if (check_winCondition()):
			$king.game_Victory()
			set_process(false)
		calculateClosestEnemy()
		#print(_mainTarget)
		
		var totalConstruct = 0
		for construct in $Construction.get_children():
			if not construct is Wall:
				totalConstruct += 1
		if totalConstruct > max_pointHolding:
			max_pointHolding = totalConstruct
	pass

func check_winCondition() -> bool:
	if get_parent() != null:
		for kingdom in get_parent().get_children() :
			#print(str(kingdom.name) + " " + str(self.name))
			if kingdom.name != self.name :
				if kingdom.has_node("king"):
					return false
	return true

func set_player_name(new_name):
	$king/Label.set_text(new_name)

func set_player_color(colorString : String):
	self.colorString = colorString
	$king.set_colorFromKingdom(colorString)

func calculateClosestEnemy():
	var min_dis = 100000
	var tmp_targetKingdom = null
	for kingdom in self.get_parent().get_children():
		if kingdom != self:
			if kingdom.has_node("king"):
				var dis = self.get_node("king").get_global_position().distance_to(kingdom.get_node("king").get_global_position())
				if min_dis > dis:
					min_dis = dis
					tmp_targetKingdom = kingdom
	if tmp_targetKingdom != null:
		_mainTarget = tmp_targetKingdom.get_node("king")
	pass

func destroy_All():
	for unit in $Army.get_children():
		if (unit.has_method("force_Kill")):
			unit.force_Kill()
	for construct in $Construction.get_children():
		if (construct.has_method("force_Destroy")):
			construct.force_Destroy()
	pass

func get_mainTarget():
	return _mainTarget

func get_networkID():
	return _networkID

func get_max_pointHolding():
	return max_pointHolding

func setOrderCommand(state):
	#state_command = state
	$king.set_command_State(state)
	
	#print("command change" + str(state))
	pass
