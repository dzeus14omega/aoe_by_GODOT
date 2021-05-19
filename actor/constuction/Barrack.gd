class_name Barrack extends Construction

var curUnitType : int
var statement : int   # 0:free, 1: training
var maxTrainAmount
var listTraining : Array
var _mKing

var id_unit = 0

var soldier = preload("res://actor/unit/Soldier.tscn").instance()
var archer = preload("res://actor/unit/Archer.tscn").instance()
var giant = preload("res://actor/unit/Giant.tscn").instance()

var link_trainButton

func _init():
	self._hp = 300
	self._buildTime = 3
	self._cost = 100

func _ready():
	print(get_network_master())
	#print(is_network_master())
	self.maxTrainAmount = $spawnList.get_child_count()
	
	if(get_parent() != null and is_network_master()):
		_mKing = get_node("../../king")
		if _mKing.get_node("UI") != null:
			_mKing.get_node("UI").get_node("tacticalControl").addButtonTrain(self)
		pass
	
#	soldier.init(_mKing)
#	archer.init(_mKing)
#	giant.init(_mKing)
	
	$healthBar.max_value = _hp
	#print(maxTrainAmount)
	#trainAmry(soldier.instance())

	
	pass # Replace with function body.

func trainAmry(unitID : int):
	if listTraining.size() <= maxTrainAmount - 1:
		var new_unit
		if unitID == 0:
			new_unit = soldier
		if unitID == 1:
			new_unit = archer
		if unitID == 2:
			new_unit = giant
		listTraining.append(unitID)
		
		if listTraining.size() == 1:
			#curUnitType = unit
			$Timer.wait_time = new_unit.getTrainTime()
			_on_timeTrainingUpdate($Timer.wait_time)
			$trainingProgress.visible = true
			$Timer.start()
		if listTraining.size() > 1:
			var new_waitTime = $Timer.time_left + new_unit.getTrainTime()
			_on_timeTrainingUpdate(new_waitTime)
			$Timer.start(new_waitTime)
		pass
	pass

func _on_total_time_trainingUpdate(time_left):
	$trainingProgress.value = $trainingProgress.max_value - time_left
	pass

func _on_timeTrainingUpdate(total_time):
	$trainingProgress.max_value = total_time
	pass

func _on_Timer_timeout():
	for p in $spawnList.get_children():
		if listTraining.size() > 0:
			print(listTraining)
			var new_unitId = listTraining.pop_back()
			_mKing.add_total_armyUnit()
#			new_unit.position = p.global_position
			call_deferred("rpc", "setup_unit", new_unitId, p.global_position, get_network_master(), id_unit)
			id_unit += 1
			#rpc("setup_unit", new_unitId, p.global_position, get_network_master())
			#add_child(new_unit)
		else:
			break
		pass
	$trainingProgress.visible = false
	pass # Replace with function body.

sync func setup_unit(unitID, pos, peerID, idUnit):
	#print(unit)
	var new_unit : Unit
	if unitID == 0:
		new_unit = soldier.duplicate()
	if unitID == 1:
		new_unit = archer.duplicate()
	if unitID == 2:
		new_unit = giant.duplicate()
	new_unit.position = pos
	new_unit.set_name(self.get_name() + String(idUnit))
	new_unit.set_network_master(peerID)
	new_unit.init(_mKing)
	new_unit.set_colorFromKing(self._colorString)
	
#	if is_network_master():
#		new_unit.set_colorFromKing(gamestate.player_info.colorString)
#	else:
#		new_unit.set_colorFromKing(gamestate.players[peerID].colorString)
	
	get_node("../../Army").add_child(new_unit)
	pass


func _process(delta):
	if self._hp <= 0 and is_network_master():
		if is_network_master():
			link_trainButton.removeWithBarrack()
		rpc("destroy")
		
	if self._hp < $healthBar.max_value:
		$healthBar.visible = true
		if self._hp < 0:
			$healthBar.value = 0
		else :
			$healthBar.value = self._hp
	
	if $Timer.time_left != 0 :
		_on_total_time_trainingUpdate($Timer.time_left)
	pass


func set_mKing(king):
	_mKing = king
	pass

func set_link_trainButton(buttonTrain):
	link_trainButton = buttonTrain
	pass

func destruction():
	if is_network_master():
		link_trainButton.removeWithBarrack()
	.destruction()
	pass

func set_BarrackName(name : String):
	$Label.set_text(name)
	self.set_name(name)

func damaged(dam):
	self._hp -= dam
	pass


