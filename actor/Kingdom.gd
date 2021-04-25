class_name Kingdom extends Node2D

var _mainTarget = null
var _networkID

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
		calculateClosestEnemy()
		#print(_mainTarget)
	pass

func set_player_name(new_name):
	$king/Label.set_text(new_name)

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
	
func get_mainTarget():
	return _mainTarget

func get_networkID():
	return _networkID

func setOrderCommand(state):
	#print("command change" + str(state))
	pass
