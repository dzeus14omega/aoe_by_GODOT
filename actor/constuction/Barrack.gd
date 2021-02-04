class_name Barrack extends Construction

var curUnitType : Unit
var statement : int   # 0:free, 1: training
var maxTrainAmount
var listTraining : Array
var mKing

var soldier = preload("res://actor/unit/Soldier.tscn")
var archer = preload("res://actor/unit/Archer.tscn")
var giant = preload("res://actor/unit/Giant.tscn")

var trainButton = preload("res://actor/player/ui_component/TrainingButton.tscn")

func _init():
	self._hp = 300
	self._buildTime = 3
	self._cost = 100

func _ready():
	self.maxTrainAmount = $spawnList.get_child_count()
	
	if(mKing != null):
		#mKing.get_node("UI").get_node("tacticalControl").addButtonTrain(self)
		pass
	#print(maxTrainAmount)
	#trainAmry(soldier.instance())

	
	pass # Replace with function body.

func trainAmry(unit : Unit):
	if listTraining.size() <= maxTrainAmount:
		var new_unit
		if unit is Soldier:
			new_unit = soldier.instance()
		if unit is Archer:
			new_unit = archer.instance()
		if unit is Giant:
			new_unit = giant.instance()
		listTraining.append(new_unit)
		
		if listTraining.size() == 1:
			curUnitType = unit
			$Timer.wait_time = unit.getTrainTime()
			_on_timeTrainingUpdate($Timer.wait_time)
			$trainingProgress.visible = true
			$Timer.start()
		if listTraining.size() > 1:
			var new_waitTime = $Timer.time_left + unit.getTrainTime()
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
			var new_unit = listTraining.pop_back()
			new_unit.position = p.global_position
			rpc("setup_unit", new_unit)
			#add_child(new_unit)
		else:
			$trainingProgress.visible = false
			break
		pass
	pass # Replace with function body.

sync func setup_unit(new_unit):
	get_node("../Army").add_child(new_unit)
	pass


func _process(delta):
	if $Timer.time_left != 0 :
		_on_total_time_trainingUpdate($Timer.time_left)
	pass
