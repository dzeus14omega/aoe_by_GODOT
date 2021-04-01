extends Control

var icon_attack = preload("res://assets/ui/icon_attack.png")
var icon_defense = preload("res://assets/ui/icon_defense.png")
var status : int  #1: attack   0: defense

func _ready():
	status = 1
	pass # Replace with function body.


func _on_TouchScreenButton_pressed():
	if (status == 1):
		status = 0
		$touchButton.set_texture(icon_defense)
		get_node("../../../").setOrderCommand(status)
		#print(get_node("../../../"))
	else:
		status = 1
		$touchButton.set_texture(icon_attack)
		get_node("../../../").setOrderCommand(status)
		#print(get_node("../../../"))
	pass # Replace with function body.
