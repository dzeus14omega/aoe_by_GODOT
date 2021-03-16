class_name TrainingButton extends PanelContainer

var _barrackLink : Barrack

var cur_unitSelect = 0 # 0:soldier 1:archer 2:giant
var cur_unitCost : int = 0
var _soldier : Soldier
var _archer : Archer
var _giant : Giant

var main_parent #King


func _ready():
	main_parent = get_node("../../../../../")
	#print(main_parent)
	_soldier = _barrackLink.soldier
	_archer = _barrackLink.archer
	_giant = _barrackLink.giant
	
	$PanelContainer/CenterContainer/train/cost.set_text(String(_soldier.getCost()))
	cur_unitCost = _soldier.getCost()
	#$PanelContainer/CenterContainer/train.set_normal_texture("")
	pass # Replace with function body.

func _process(delta):
	var numTrain = _barrackLink.listTraining.size()
	if numTrain == 0:
		$PanelContainer/CenterContainer/train/num.set_text("")
	else :
		$PanelContainer/CenterContainer/train/num.set_text(String(numTrain))
	pass

func removeWithBarrack():
	hide()
	get_parent().remove_child(self)
	queue_free()

func set_link_barrack(barrack):
	_barrackLink = barrack
	
	pass


func _on_changeUnit_button_up():
	if cur_unitSelect == 2:
		cur_unitSelect = 0
	else :
		cur_unitSelect += 1
	
	match cur_unitSelect:
		#TODO: Set texture for button
		0:
			$PanelContainer/CenterContainer/train/cost.set_text(String(_soldier.getCost()))
			cur_unitCost = _soldier.getCost()
			$PanelContainer/CenterContainer/train.set_normal_texture(load("res://assets/icon/soldier_icon.png"))
		1:
			$PanelContainer/CenterContainer/train/cost.set_text(String(_archer.getCost()))
			cur_unitCost = _archer.getCost()
			$PanelContainer/CenterContainer/train.set_normal_texture(load("res://assets/icon/archer_icon.png"))
		2:
			$PanelContainer/CenterContainer/train/cost.set_text(String(_giant.getCost()))
			cur_unitCost = _giant.getCost()
			$PanelContainer/CenterContainer/train.set_normal_texture(load("res://assets/icon/giant_icon.png"))
	pass # Replace with function body.


func _on_train_button_up():
	if main_parent.spendGold_If_Possible(cur_unitCost):
		_barrackLink.trainAmry(cur_unitSelect)
	pass # Replace with function body.

