extends Control

var _buttonTrain = preload("res://actor/player/ui_component/TrainingButton.tscn")

func addButtonTrain(barrack):
	var buttonTrain = _buttonTrain.instance()
	buttonTrain.get_node("PanelContainer/Label").set_text(barrack.get_name())
	#linking barrack and button train
	buttonTrain.set_link_barrack(barrack)
	barrack.set_link_trainButton(buttonTrain)
	$HScrollBar/listButton.add_child(buttonTrain)
	pass

func _ready():
	
	pass # Replace with function body.

